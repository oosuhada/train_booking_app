import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'package:intl/intl.dart';
import 'train_schedule.dart';

class SeatPage extends StatefulWidget {
  final String departureStation;
  final String arrivalStation;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;
  final DateTime selectedDate;
  final TrainSchedule departureSchedule;
  final TrainSchedule? returnSchedule;

  SeatPage({
    required this.departureStation,
    required this.arrivalStation,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
    required this.selectedDate,
    required this.departureSchedule,
    this.returnSchedule,
  });

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<List<bool>> seats = List.generate(20, (_) => List.filled(4, false));
  Set<String> selectedSeats = {};
  late DateTime selectedDate;
  late List<TrainSchedule> schedules;
  int currentScheduleIndex = 0;
  bool isSelectingReturn = false;
  Set<String> selectedReturnSeats = {};

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    schedules = TrainScheduleService.getSchedules(
      widget.departureStation,
      widget.arrivalStation,
      selectedDate,
    );
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNoTrainAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changeTrainSchedule(int direction) {
    setState(() {
      int newIndex = currentScheduleIndex + direction;
      if (newIndex >= 0 && newIndex < schedules.length) {
        currentScheduleIndex = newIndex;
      } else {
        _showNoTrainAlert(direction > 0 ? '다음 열차가 없습니다.' : '이전 열차가 없습니다.');
      }
    });
  }

  void _selectSeat(int row, int col) {
    setState(() {
      if (seats[row][col]) {
        seats[row][col] = false;
        (isSelectingReturn ? selectedReturnSeats : selectedSeats)
            .remove('${row + 1}${String.fromCharCode(65 + col)}');
      } else if ((isSelectingReturn ? selectedReturnSeats : selectedSeats)
              .length <
          widget.adultCount + widget.childCount + widget.seniorCount) {
        seats[row][col] = true;
        (isSelectingReturn ? selectedReturnSeats : selectedSeats)
            .add('${row + 1}${String.fromCharCode(65 + col)}');
      }

      if (selectedSeats.isNotEmpty || selectedReturnSeats.isNotEmpty) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _proceedToNextStep() {
    if (widget.isRoundTrip && !isSelectingReturn) {
      setState(() {
        isSelectingReturn = true;
        seats = List.generate(20, (_) => List.filled(4, false));
        selectedReturnSeats.clear();
        selectedDate = selectedDate.add(Duration(days: 1));
        schedules = TrainScheduleService.getSchedules(
          widget.arrivalStation,
          widget.departureStation,
          selectedDate,
        );
        currentScheduleIndex = 0;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            departure: widget.departureStation,
            arrival: widget.arrivalStation,
            seatNumbers: selectedSeats.toList(),
            // returnSeatNumbers와 returnDate는 새로 추가된 매개변수입니다.
            // 이 매개변수들이 PaymentPage에 정의되어 있는지 확인해주세요.
            returnSeatNumbers: selectedReturnSeats.toList(),
            returnDate: isSelectingReturn ? selectedDate : null,
            isRoundTrip: widget.isRoundTrip,
            travelDate: widget.selectedDate,
            adultCount: widget.adultCount,
            childCount: widget.childCount,
            seniorCount: widget.seniorCount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좌석 선택')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  // 열차 정보 위젯
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: currentScheduleIndex > 0
                              ? () => _changeTrainSchedule(-1)
                              : null,
                          color: currentScheduleIndex > 0
                              ? null
                              : Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Text(
                              schedules[currentScheduleIndex].trainNumber,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${DateFormat('HH:mm').format(schedules[currentScheduleIndex].departureTime)} - ${DateFormat('HH:mm').format(schedules[currentScheduleIndex].arrivalTime)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: currentScheduleIndex < schedules.length - 1
                              ? () => _changeTrainSchedule(1)
                              : null,
                          color: currentScheduleIndex < schedules.length - 1
                              ? null
                              : Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 좌석 선택 UI
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: seats.length * 5,
                    itemBuilder: (context, index) {
                      if (index % 5 == 2) {
                        int row = index ~/ 5 + 1;
                        return Center(
                          child: Text(row.toString(),
                              style: TextStyle(fontSize: 18)),
                        );
                      }
                      int row = index ~/ 5;
                      int col = index % 5 > 2 ? index % 5 - 1 : index % 5;
                      if (col >= seats[row].length) return SizedBox();
                      return GestureDetector(
                        onTap: () => _selectSeat(row, col),
                        child: Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: seats[row][col]
                                ? Colors.purple
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '선택한 좌석: ${(isSelectingReturn ? selectedReturnSeats : selectedSeats).join(", ")}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '어른: ${widget.adultCount}, 어린이: ${widget.childCount}, 경로: ${widget.seniorCount}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (isSelectingReturn
                                      ? selectedReturnSeats
                                      : selectedSeats)
                                  .length ==
                              widget.adultCount +
                                  widget.childCount +
                                  widget.seniorCount
                          ? _proceedToNextStep
                          : null,
                      child: Text(
                        isSelectingReturn ? '예매 하기' : '다음',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
