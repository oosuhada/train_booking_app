import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'package:intl/intl.dart';
import 'train_schedule.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;
  final DateTime selectedDate;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainNumber;

  SeatPage(
    this.departure,
    this.arrival,
    this.adultCount,
    this.childCount,
    this.seniorCount,
    this.isRoundTrip, {
    required this.selectedDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainNumber,
  });

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  List<List<bool>> seats = List.generate(10, (_) => List.filled(4, false));
  Set<String> selectedSeats = {};
  late DateTime selectedDate;
  late List<TrainSchedule> schedules;
  int currentScheduleIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    schedules = [
      TrainSchedule(
        trainNumber: widget.trainNumber,
        departureTime: widget.departureTime,
        arrivalTime: widget.arrivalTime,
        departureStation: '',
        arrivalStation: '',
      )
    ];

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 애니메이션 설정
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 기타 초기화 코드...
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
          actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('좌석 선택')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 날짜 선택 위젯
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(Duration(days: 1));
                            schedules = TrainScheduleService.getSchedules(
                              widget.departure,
                              widget.arrival,
                              selectedDate,
                            );
                            currentScheduleIndex = 0;
                          });
                        },
                      ),
                      Text(
                        DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          setState(() {
                            selectedDate = selectedDate.add(Duration(days: 1));
                            schedules = TrainScheduleService.getSchedules(
                              widget.departure,
                              widget.arrival,
                              selectedDate,
                            );
                            currentScheduleIndex = 0;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // 열차 정보 위젯
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: currentScheduleIndex > 0
                            ? () => _changeTrainSchedule(-1)
                            : null,
                        color:
                            currentScheduleIndex > 0 ? null : Colors.grey[300],
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('선택됨'),
                      SizedBox(width: 20),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text('선택 안됨'),
                      SizedBox(width: 20),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['A', 'B', '', 'C', 'D']
                        .map((label) =>
                            Text(label, style: TextStyle(fontSize: 18)))
                        .toList(),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: seats[0].length + 1,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: seats.length * (seats[0].length + 1),
                    itemBuilder: (context, index) {
                      if (index % (seats[0].length + 1) == 2) {
                        int row = index ~/ (seats[0].length + 1) + 1;
                        return Center(
                          child: Text(row.toString(),
                              style: TextStyle(fontSize: 18)),
                        );
                      }
                      int row = index ~/ (seats[0].length + 1);
                      int col = index % (seats[0].length + 1) > 2
                          ? index % (seats[0].length + 1) - 1
                          : index % (seats[0].length + 1);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (seats[row][col]) {
                              seats[row][col] = false;
                              selectedSeats.remove(
                                  '${row + 1}${String.fromCharCode(65 + col)}');
                            } else if (selectedSeats.length <
                                widget.adultCount +
                                    widget.childCount +
                                    widget.seniorCount) {
                              seats[row][col] = true;
                              selectedSeats.add(
                                  '${row + 1}${String.fromCharCode(65 + col)}');
                            }
                            if (selectedSeats.isNotEmpty) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          });
                        },
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
                      '선택한 좌석: ${selectedSeats.join(", ")}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '어른: ${widget.adultCount}, 어린이: ${widget.childCount}, 경로: ${widget.seniorCount}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: selectedSeats.length ==
                              widget.adultCount +
                                  widget.childCount +
                                  widget.seniorCount
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    departure: widget.departure,
                                    arrival: widget.arrival,
                                    seatNumbers:
                                        selectedSeats.toList(), // Set을 List로 변환
                                    isRoundTrip: widget.isRoundTrip,
                                    travelDate: selectedDate,
                                    adultCount: widget.adultCount,
                                    childCount: widget.childCount,
                                    seniorCount: widget.seniorCount,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        '예매 하기',
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
