import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';
import 'train_schedule.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final String departureStation;
  final String arrivalStation;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;
  final DateTime selectedDate;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainNumber;
  final TrainSchedule departureSchedule;
  final TrainSchedule? returnSchedule;
  final TrainSchedule selectedSchedule;

  SeatPage({
    required this.departure,
    required this.arrival,
    required this.departureStation,
    required this.arrivalStation,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
    required this.selectedDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainNumber,
    required this.departureSchedule,
    this.returnSchedule,
    required this.selectedSchedule,
    required DateTime selectedDepartureDate,
    DateTime? selectedReturnDate,
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
  Set<String> selectedReturnSeats = {};
  late DateTime selectedDate;
  bool isSelectingReturn = false;
  late TrainSchedule currentSchedule;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // 현재 선택된 스케줄이 출발편인지 도착편인지 확인
    isSelectingReturn = widget.returnSchedule != null &&
        widget.selectedSchedule.trainNumber ==
            widget.returnSchedule!.trainNumber;
    currentSchedule = widget.selectedSchedule;
  }

  // 스케줄 변경 메소드 수정
  void _changeTrainSchedule(int direction) {
    setState(() {
      List<TrainSchedule> availableSchedules =
          TrainScheduleService.getSchedules(
        widget.departure,
        widget.arrival,
        selectedDate,
      );

      // 현재 선택된 스케줄의 인덱스 찾기
      int currentIndex = availableSchedules.indexWhere(
          (schedule) => schedule.trainNumber == currentSchedule.trainNumber);

      int newIndex = currentIndex + direction;
      if (newIndex >= 0 && newIndex < availableSchedules.length) {
        currentSchedule = availableSchedules[newIndex];
      } else {
        _showNoTrainAlert(
          direction > 0 ? '다음 열차가 없습니다.' : '이전 열차가 없습니다.',
        );
      }
    });
  }

  // 열차 정보 위젯 수정
  Widget _buildTrainInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                currentSchedule.trainNumber,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${DateFormat('HH:mm').format(currentSchedule.departureTime)} - '
                '${DateFormat('HH:mm').format(currentSchedule.arrivalTime)}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
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

  // 스케줄 변경 메소드 수정
  void _changeTrainSchedule(int direction) {
    setState(() {
      List<TrainSchedule> availableSchedules =
          TrainScheduleService.getSchedules(
        widget.departure,
        widget.arrival,
        selectedDate,
      );

      // 현재 선택된 스케줄의 인덱스 찾기
      int currentIndex = availableSchedules.indexWhere((schedule) =>
          schedule.trainNumber == schedules[currentScheduleIndex].trainNumber);

      int newIndex = currentIndex + direction;
      if (newIndex >= 0 && newIndex < availableSchedules.length) {
        schedules = [availableSchedules[newIndex]];
        currentScheduleIndex = 0;
      } else {
        _showNoTrainAlert(
          direction > 0 ? '다음 열차가 없습니다.' : '이전 열차가 없습니다.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingReturn ? '도착편 좌석 선택' : '출발편 좌석 선택'),
      ),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                  // 날짜 선택 위젯
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 12),
                            onPressed: () {
                              DateTime today = DateTime.now();
                              if (selectedDate
                                  .isBefore(today.add(Duration(days: 1)))) {
                                _showNoTrainAlert('더 이전 날짜는 선택할 수 없습니다.');
                                return;
                              }
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
                            '이전날',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat('yy년 MM월 dd일').format(selectedDate),
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 12),
                            onPressed: () {
                              setState(() {
                                selectedDate =
                                    selectedDate.add(Duration(days: 1));
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
                            '다음날',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // 좌석 범례
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
                  // 좌석 레이블
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['A', 'B', '', 'C', 'D']
                        .map((label) =>
                            Text(label, style: TextStyle(fontSize: 18)))
                        .toList(),
                  ),
                  // 좌석 그리드
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
                              String seatNumber =
                                  '${row + 1}${String.fromCharCode(65 + col)}';
                              if (isSelectingReturn) {
                                selectedReturnSeats.remove(seatNumber);
                              } else {
                                selectedSeats.remove(seatNumber);
                              }
                              if ((isSelectingReturn
                                      ? selectedReturnSeats
                                      : selectedSeats)
                                  .isEmpty) {
                                _controller.reverse();
                              }
                            } else if ((isSelectingReturn
                                        ? selectedReturnSeats
                                        : selectedSeats)
                                    .length <
                                widget.adultCount +
                                    widget.childCount +
                                    widget.seniorCount) {
                              seats[row][col] = true;
                              String seatNumber =
                                  '${row + 1}${String.fromCharCode(65 + col)}';
                              if (isSelectingReturn) {
                                selectedReturnSeats.add(seatNumber);
                              } else {
                                selectedSeats.add(seatNumber);
                              }
                              if (!_controller.isCompleted) {
                                _controller.forward();
                              }
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
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    ? () {
                        if (widget.isRoundTrip && !isSelectingReturn) {
                          setState(() {
                            isSelectingReturn = true;
                            seats =
                                List.generate(20, (_) => List.filled(4, false));
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
                                returnSeatNumbers: selectedReturnSeats.toList(),
                                isRoundTrip: widget.isRoundTrip,
                                travelDate: widget.selectedDate,
                                returnDate:
                                    isSelectingReturn ? selectedDate : null,
                                adultCount: widget.adultCount,
                                childCount: widget.childCount,
                                seniorCount: widget.seniorCount,
                                departureSchedule: TrainSchedule(
                                  trainNumber: currentSchedule.trainNumber,
                                  departureStation: widget.departureStation,
                                  arrivalStation: widget.arrivalStation,
                                  departureTime: currentSchedule.departureTime,
                                  arrivalTime: currentSchedule.arrivalTime,
                                ),
                                returnSchedule: widget.returnSchedule,
                                // 추가된 부분
                                selectedDepartureDate: widget.selectedDate,
                                selectedReturnDate:
                                    isSelectingReturn ? selectedDate : null,
                              ),
                            ),
                          );
                        }
                      }
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
    );
  }
}
