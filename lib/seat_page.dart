import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';
import 'train_schedule.dart';
import 'app_localizations.dart';

// Part 1 - 클래스 선언
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
  final bool isSelectingReturn;

  // 언어 설정 정보
  final Locale selectedLocale;

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
    required this.isSelectingReturn,
    required this.selectedLocale,
  }) : super(key: key);

  @override
  _SeatPageState createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage>
    with SingleTickerProviderStateMixin {
  // Part2. 변수 선언
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
  // 승객 유형별 선택된 좌석수를 추적하는 맵
  late Map<String, List<String>> selectedSeatsByType;
  // 승객 유형별 좌석 지정 순서
  List<String> passengerOrder = ['어른', '어린이', '경로'];

  // Part 3. initState 메서드
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

    // allSchedules 초기화
    allSchedules = TrainScheduleService.getSchedules(widget.departure,
        widget.arrival, selectedDepartureDate, selectedReturnDate);

    departureSchedules = allSchedules['departure'] ?? [];

    if (widget.isRoundTrip && selectedReturnDate != null) {
      returnSchedules = allSchedules['return'];
      returnSchedule = widget.returnSchedule ?? returnSchedules?.first;
    }

    // selectedSeatsByType 초기화
    selectedSeatsByType = {
      '어른': [],
      '어린이': [],
      '경로': [],
    };

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

  // Part 4 - build 메서드
  @override
  Widget build(BuildContext context) {
    final TrainSchedule? currentSchedule;
    if (isSelectingReturn) {
      currentSchedule = returnSchedule;
    } else {
      currentSchedule = departureSchedule;
    }
    final schedules = isSelectingReturn ? returnSchedules : departureSchedules;

    void _selectSeat(int row, int col) {
      setState(() {
        String seatNumber = '${row + 1}${String.fromCharCode(65 + col)}';
        if (isSelectingReturn) {
          if (seats[row][col]) {
            seats[row][col] = false;
            selectedReturnSeats.remove(seatNumber);
            _removeSeat(seatNumber);
          } else {
            if (_canSelectMoreSeats()) {
              seats[row][col] = true;
              selectedReturnSeats.add(seatNumber);
              _addSeat(seatNumber);
            }
          }
        } else {
          if (seats[row][col]) {
            seats[row][col] = false;
            selectedSeats.remove(seatNumber);
            _removeSeat(seatNumber);
          } else {
            if (_canSelectMoreSeats()) {
              seats[row][col] = true;
              selectedSeats.add(seatNumber);
              _addSeat(seatNumber);
            }
          }
        }

        if (_getTotalSelectedSeats() == 0) {
          _controller.reverse();
        } else if (!_controller.isCompleted) {
          _controller.forward();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)
            .translate(isSelectingReturn ? '도착편 좌석 선택' : '출발편 좌석 선택')),
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
                              '${AppLocalizations.of(context).translate('출발')}: ${DateFormat('HH:mm').format(currentSchedule!.departureTime)} '
                              ' - '
                              '${AppLocalizations.of(context).translate('도착')}: ${DateFormat('HH:mm').format(currentSchedule!.arrivalTime)}',
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
                                _showNoTrainAlert(AppLocalizations.of(context)
                                    .translate('더 이전 날짜는 선택할 수 없습니다.'));
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
                            AppLocalizations.of(context).translate('이전날'),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            DateFormat(
                                    getLocalizedDateFormat(context),
                                    Localizations.localeOf(context)
                                        .languageCode)
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
                            AppLocalizations.of(context).translate('다음날'),
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
                      Text(AppLocalizations.of(context).translate('선택됨')),
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
                      Text(AppLocalizations.of(context).translate('선택안됨')),
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
                      int col = index % (seats[0].length + 1);

                      // 통로 열인 경우 빈 컨테이너 반환
                      if (col == 2) {
                        return Container();
                      }

                      // 실제 열 번호 조정
                      if (col > 2) col--;

                      return GestureDetector(
                        onTap: () => _selectSeat(row, col),
                        child: Container(
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelectingReturn
                                ? (selectedReturnSeats.contains(
                                        '${row + 1}${String.fromCharCode(65 + col)}')
                                    ? Colors.purple
                                    : Colors.grey[300])
                                : (selectedSeats.contains(
                                        '${row + 1}${String.fromCharCode(65 + col)}')
                                    ? Colors.purple
                                    : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

// Part 5. - UI 관련 메서드들
  // 열차 스케줄 정보를 표시하는 위젯 생성
  Widget _buildScheduleInfo() {
    TrainSchedule? currentSchedule = widget.isSelectingReturn
        ? widget.returnSchedule!
        : widget.departureSchedule;
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${currentSchedule?.trainNumber}'),
          Text(
              '${AppLocalizations.of(context).translate('출발')}: ${DateFormat('HH:mm').format(currentSchedule!.departureTime)} ${AppLocalizations.of(context).translate('도착')}: ${DateFormat('HH:mm').format(currentSchedule!.arrivalTime)}'),
        ],
      ),
    );
  }

  // 하단 패널 위젯 빌드 메서드
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
                ? Colors.grey[800]
                : Colors.white,
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
              ..._buildPassengerTypeInfo(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isAllSeatsSelected()
                    ? () {
                        if (widget.isRoundTrip && !isSelectingReturn) {
                          setState(() {
                            isSelectingReturn = true;
                            seats =
                                List.generate(20, (_) => List.filled(4, false));
                            selectedReturnSeats.clear();
                            _getPassengerTypeCount;
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
                                selectedLocale: widget.selectedLocale,
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: Text(
                  AppLocalizations.of(context)
                      .translate(isSelectingReturn ? '예매하기' : '다음'),
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

  //좌석 선택 시 bottom panel에 실시간으로 선택 좌석 표시하는 메서드
  List<Widget> _buildPassengerTypeInfo() {
    List<Widget> widgets = [];

    for (String type in passengerOrder) {
      int count = _getPassengerTypeCount(type);
      if (count > 0) {
        List<String> typeSeats = selectedSeatsByType[type] ?? [];
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '$type: $count명 (선택된 좌석: ${typeSeats.isEmpty ? "-" : typeSeats.join(", ")})',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    }

    return widgets;
  }

// Part6. 좌석 선택 관련 메서드들
  // 좌석을 선택하거나 선택 해제하는 메서드 - 도착편 좌석 선택도 가능하게 수정
  void _selectSeat(int row, int col) {
    String seatNumber = '${row + 1}${String.fromCharCode(65 + col)}';

    setState(() {
      if (isSelectingReturn) {
        if (seats[row][col]) {
          // 이미 선택된 좌석 해제
          seats[row][col] = false;
          selectedReturnSeats.remove(seatNumber);
          _removeSeat(seatNumber);
        } else if (_canSelectMoreSeats()) {
          // 새로운 좌석 선택
          seats[row][col] = true;
          selectedReturnSeats.add(seatNumber);
          _addSeat(seatNumber);
        }
      } else {
        if (seats[row][col]) {
          // 이미 선택된 좌석 해제
          seats[row][col] = false;
          selectedSeats.remove(seatNumber);
          _removeSeat(seatNumber);
        } else if (_canSelectMoreSeats()) {
          // 새로운 좌석 선택
          seats[row][col] = true;
          selectedSeats.add(seatNumber);
          _addSeat(seatNumber);
        }
      }

      // 애니메이션 컨트롤러 업데이트
      if (_getTotalSelectedSeats() == 0) {
        _controller.reverse();
      } else if (!_controller.isCompleted) {
        _controller.forward();
      }
    });
  }

  // 선택된 좌석을 추가하는 메서드 수정
  void _addSeat(String seatNumber) {
    for (String type in passengerOrder) {
      int typeCount = _getPassengerTypeCount(type);
      List<String> typeSeats = selectedSeatsByType[type] ?? [];

      if (typeSeats.length < typeCount) {
        setState(() {
          selectedSeatsByType[type] ??= [];
          selectedSeatsByType[type]!.add(seatNumber);
        });
        break;
      }
    }
  }

  // 선택된 좌석을 제거하는 메서드 수정
  void _removeSeat(String seatNumber) {
    setState(() {
      for (String type in passengerOrder) {
        if (selectedSeatsByType[type]?.contains(seatNumber) ?? false) {
          selectedSeatsByType[type]!.remove(seatNumber);
          break;
        }
      }
    });
  }

  // 모든 좌석이 선택되었는지 확인하는 새로운 메서드 추가
  bool _isAllSeatsSelected() {
    int totalRequiredSeats =
        widget.adultCount + widget.childCount + widget.seniorCount;
    if (isSelectingReturn) {
      return selectedReturnSeats.length == totalRequiredSeats;
    } else {
      return selectedSeats.length == totalRequiredSeats;
    }
  }

  // 더 많은 좌석을 선택할 수 있는지 확인하는 메서드
  bool _canSelectMoreSeats() {
    int totalSeats = widget.adultCount + widget.childCount + widget.seniorCount;
    return isSelectingReturn
        ? selectedReturnSeats.length < totalSeats
        : selectedSeats.length < totalSeats;
  }

  // 총 선택된 좌석 수를 반환하는 메서드
  int _getTotalSelectedSeats() {
    return selectedSeatsByType.values
        .map((seats) => seats.length)
        .fold(0, (a, b) => a + b);
  }

// Part7. 열차 스케줄 관련 메서드들
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
          _showNoTrainAlert(direction > 0
              ? AppLocalizations.of(context).translate('다음 열차가 없습니다.')
              : AppLocalizations.of(context).translate('이전 열차가 없습니다.'));
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

  // 이전, 다음 열차가 없을 때 알림을 표시하는 메서드
  void _showNoTrainAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('알림')),
          content: Text(AppLocalizations.of(context).translate(message)),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).translate('확인')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Part8. 유틸리티 메서드들
  // 승객 유형별 총 인원 수 반환 메서드
  int _getPassengerTypeCount(String type) {
    switch (type) {
      case '어른':
        return widget.adultCount;
      case '어린이':
        return widget.childCount;
      case '경로':
        return widget.seniorCount;
      default:
        return 0;
    }
  }

  //날짜 표시 양식 번역 연동
  String getLocalizedDateFormat(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'en':
        return 'MMM d, yyyy';
      case 'ja':
        return 'yyyy年MM月dd日';
      case 'zh':
        return 'yyyy年MM月dd日';
      default:
        return 'yy년 MM월 dd일';
    }
  }
}
