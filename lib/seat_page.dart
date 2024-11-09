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
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainNumber;
  final bool isReturn;
  final TrainSchedule? returnSchedule;
  final DateTime? returnDate;

  SeatPage({
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
    required this.isReturn,
    this.returnSchedule,
    this.returnDate,
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
  bool isSelectingReturnSeat = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    schedules = [
      TrainSchedule(
        trainNumber: widget.trainNumber,
        departureStation: widget.departureStation,
        arrivalStation: widget.arrivalStation,
        departureTime: widget.departureTime,
        arrivalTime: widget.arrivalTime,
      )
    ];

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

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingReturnSeat ? '도착편 좌석 선택' : '출발편 좌석 선택'),
      ),
      body: Column(
        children: [
          // 열차 정보 위젯
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.trainNumber}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${DateFormat('HH:mm').format(widget.departureTime)} - ${DateFormat('HH:mm').format(widget.arrivalTime)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // 좌석 선택 UI
          Expanded(
            child: SlideTransition(
              position: _offsetAnimation,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemCount: seats.length * seats[0].length,
                itemBuilder: (context, index) {
                  int row = index ~/ seats[0].length;
                  int col = index % seats[0].length;
                  return GestureDetector(
                    onTap: () => _toggleSeat(row, col),
                    child: Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: seats[row][col] ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child:
                            Text('${row + 1}${String.fromCharCode(65 + col)}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 선택된 좌석 정보
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              '선택된 좌석: ${selectedSeats.join(", ")}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // 왕복 여정 관련 버튼
          if (widget.isRoundTrip && !isSelectingReturnSeat)
            ElevatedButton(
              child: Text('도착편 좌석 선택'),
              onPressed: () {
                setState(() {
                  isSelectingReturnSeat = true;
                  // 도착편 스케줄로 업데이트
                  schedules = TrainScheduleService.getSchedules(
                    widget.arrivalStation,
                    widget.departureStation,
                    widget.returnDate!,
                  );
                  currentScheduleIndex = 0;
                  seats = List.generate(20, (_) => List.filled(4, false));
                  selectedSeats.clear();
                });
                _controller.forward(from: 0.0);
              },
            ),

          if (isSelectingReturnSeat || !widget.isRoundTrip)
            ElevatedButton(
              child: Text('예약 완료'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      departure: widget.departureStation,
                      arrival: widget.arrivalStation,
                      seatNumbers: selectedSeats.toList(),
                      isRoundTrip: widget.isRoundTrip,
                      travelDate: selectedDate,
                      adultCount: widget.adultCount,
                      childCount: widget.childCount,
                      seniorCount: widget.seniorCount,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _toggleSeat(int row, int col) {
    setState(() {
      seats[row][col] = !seats[row][col];
      String seatName = '${row + 1}${String.fromCharCode(65 + col)}';
      if (seats[row][col]) {
        selectedSeats.add(seatName);
      } else {
        selectedSeats.remove(seatName);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
