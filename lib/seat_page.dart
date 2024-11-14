import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';
import 'train_schedule.dart';

// Part 1 - 클래스 선언부터 build 메서드 시작
class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final String departureStation;
  final String arrivalStation;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;

  // 날짜 관련
  final DateTime? selectedDepartureDate;
  final DateTime? selectedReturnDate;

  // 출발편 정보
  final TrainSchedule? departureSchedule;
  final DateTime departureTime;
  final DateTime departureArrivalTime;

  // 도착편 정보 (왕복인 경우)
  final TrainSchedule? returnSchedule;
  final DateTime? returnDepartureTime;
  final DateTime? returnArrivalTime;

  const SeatPage({
    Key? key,
    required this.departure,
    required this.arrival,
    required this.departureStation,
    required this.arrivalStation,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
    required this.selectedDepartureDate,
    this.selectedReturnDate,
    required this.departureSchedule,
    required this.departureTime,
    required this.departureArrivalTime,
    this.returnSchedule,
    required this.returnDepartureTime,
    required this.returnArrivalTime,
  }) : super(key: key);

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // 출발편과 도착편 스케줄 분리
  late TrainSchedule? departureSchedule;
  TrainSchedule? returnSchedule;

  List<List<bool>> seats = List.generate(20, (_) => List.filled(4, false));
  Set<String> selectedSeats = {};
  Set<String> selectedReturnSeats = {};

  bool isSelectingReturn = false;
  late DateTime selectedDepartureDate;
  DateTime? selectedReturnDate;
  late Map<String, List<TrainSchedule>> allSchedules;
  late List<TrainSchedule> departureSchedules;
  List<TrainSchedule>? returnSchedules;

  @override
  void initState() {
    super.initState();

    departureSchedule = widget.departureSchedule;
    returnSchedule = widget.returnSchedule;
    selectedDepartureDate = widget.selectedDepartureDate!;
    selectedReturnDate = widget.selectedReturnDate;

    // 스케줄 초기화
    Map<String, List<TrainSchedule>> allSchedules =
        TrainScheduleService.getSchedules(widget.departure, widget.arrival,
            selectedDepartureDate, null // returnDate는 null로 설정 (편도 여정이므로)
            );
    departureSchedules = allSchedules['departure'] ?? [];
    if (widget.isRoundTrip && selectedReturnDate != null) {
      returnSchedules = allSchedules['return']!;
    }

    // 애니메이션 컨트롤러 초기화
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
  }

  // _showNoTrainAlert 메소드 추가
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

  // 열차 스케줄 변경 메소드
  void _changeTrainSchedule(int direction) {
    setState(() {
      if (isSelectingReturn &&
          returnSchedules != null &&
          returnSchedule != null) {
        // 도착편 스케줄 변경
        int currentIndex = returnSchedules!.indexWhere(
            (schedule) => schedule.trainNumber == returnSchedule!.trainNumber);
        int newIndex = currentIndex + direction;

        if (newIndex >= 0 && newIndex < returnSchedules!.length) {
          returnSchedule = returnSchedules![newIndex];
        } else {
          _showNoTrainAlert(direction > 0 ? '다음 열차가 없습니다.' : '이전 열차가 없습니다.');
        }
      } else {
        // 출발편 스케줄 변경
        int currentIndex = departureSchedules.indexWhere((schedule) =>
            schedule.trainNumber == departureSchedule!.trainNumber);
        int newIndex = currentIndex + direction;
        if (newIndex >= 0 && newIndex < departureSchedules.length) {
          departureSchedule = departureSchedules[newIndex];
        } else {
          _showNoTrainAlert(direction > 0 ? '다음 열차가 없습니다.' : '이전 열차가 없습니다.');
        }
      }
    });
  }

  // Part 2 - build 메서드
  @override
  Widget build(BuildContext context) {
    final TrainSchedule? currentSchedule;
    if (isSelectingReturn) {
      currentSchedule = returnSchedule;
    } else {
      currentSchedule = departureSchedule;
    }
    final schedules = isSelectingReturn ? returnSchedules : departureSchedules;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingReturn ? '도착편 좌석 선택' : '출발편 좌석 선택'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => _changeTrainSchedule(-1),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${currentSchedule?.trainNumber}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${DateFormat('HH:mm').format(widget.departureTime)} - '
                              '${DateFormat('HH:mm').format(widget.departureArrivalTime)}',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed:
                            (schedules != null && currentSchedule != null)
                                ? (schedules.indexOf(currentSchedule) <
                                        schedules.length - 1
                                    ? () => _changeTrainSchedule(1)
                                    : null)
                                : null,
                        color: schedules != null &&
                                schedules.indexOf(currentSchedule!) <
                                    schedules.length - 1
                            ? null
                            : Colors.grey[300],
                      ),
                    ],
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
                              if (selectedDepartureDate
                                  .isBefore(today.add(Duration(days: 1)))) {
                                _showNoTrainAlert('더 이전 날짜는 선택할 수 없습니다.');
                                return;
                              }
                              setState(() {
                                selectedDepartureDate = selectedDepartureDate
                                    .subtract(Duration(days: 1));
                                allSchedules =
                                    TrainScheduleService.getSchedules(
                                        widget.departure,
                                        widget.arrival,
                                        selectedDepartureDate,
                                        null // returnDate는 null로 설정 (편도 여정이므로)
                                        );
                                departureSchedules =
                                    allSchedules['departure'] ?? [];
                                if (departureSchedules.isNotEmpty) {
                                  departureSchedule = departureSchedules.first;
                                } else {
                                  // 스케줄이 없는 경우 처리
                                  departureSchedule = null;
                                }
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
                            DateFormat('yy년 MM월 dd일')
                                .format(selectedDepartureDate),
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
                                selectedDepartureDate = selectedDepartureDate
                                    .subtract(Duration(days: 1));
                                allSchedules =
                                    TrainScheduleService.getSchedules(
                                        widget.departure,
                                        widget.arrival,
                                        selectedDepartureDate,
                                        null // returnDate는 null로 설정 (편도 여정이므로)
                                        );
                                departureSchedules =
                                    allSchedules['departure'] ?? [];
                                if (departureSchedules.isNotEmpty) {
                                  departureSchedule = departureSchedules.first;
                                } else {
                                  // 스케줄이 없는 경우 처리
                                  departureSchedule = null;
                                }
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

// Part 3 - _buildBottomPanel
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800] // 다크 모드일때 어둡게
                : Colors.white, // 라이트 모드일때
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
                            // 도착편 스케줄 및 좌석 초기화
                            seats =
                                List.generate(20, (_) => List.filled(4, false));
                            selectedReturnSeats.clear();
                            // 필요한 경우 returnSchedule 초기화
                          });
                        } else {
                          // 기존의 결제 페이지로 이동하는 코드
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                departure: widget.departureStation,
                                arrival: widget.arrivalStation,
                                seatNumbers: selectedSeats.toList(),
                                returnSeatNumbers: selectedReturnSeats.toList(),
                                isRoundTrip: widget.isRoundTrip,
                                travelDate: selectedDepartureDate,
                                returnDate: isSelectingReturn
                                    ? selectedReturnDate
                                    : null,
                                adultCount: widget.adultCount,
                                childCount: widget.childCount,
                                seniorCount: widget.seniorCount,
                                departureSchedule: departureSchedule != null
                                    ? TrainSchedule(
                                        trainNumber:
                                            departureSchedule!.trainNumber,
                                        departureStation:
                                            widget.departureStation,
                                        arrivalStation: widget.arrivalStation,
                                        departureTime:
                                            departureSchedule!.departureTime,
                                        arrivalTime:
                                            departureSchedule!.arrivalTime,
                                      )
                                    : null,
                                returnSchedule: returnSchedule,
                                selectedDepartureDate: selectedDepartureDate,
                                selectedReturnDate: isSelectingReturn
                                    ? selectedReturnDate
                                    : null,
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
