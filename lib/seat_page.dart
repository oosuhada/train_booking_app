import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';
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
  late TabController _tabController;
  List<List<bool>> seats = List.generate(20, (_) => List.filled(4, false));
  Set<String> selectedSeats = {};
  Set<String> selectedReturnSeats = {};
  late DateTime selectedDate;
  late List<TrainSchedule> schedules;
  int currentScheduleIndex = 0;
  bool isSelectingReturn = false;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    schedules = TrainScheduleService.getSchedules(
      widget.departureStation,
      widget.arrivalStation,
      selectedDate,
    );
    _tabController = TabController(
      length: widget.isRoundTrip ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRoundTrip ? '왕복 좌석 선택' : '좌석 선택'),
        bottom: widget.isRoundTrip
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: '출발편 좌석'),
                  Tab(text: '도착편 좌석'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: widget.isRoundTrip
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSeatSelection(false),
                      _buildSeatSelection(true),
                    ],
                  )
                : _buildSeatSelection(false),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(Duration(days: 1));
                    schedules = TrainScheduleService.getSchedules(
                      widget.departureStation,
                      widget.arrivalStation,
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
                DateFormat('dd').format(selectedDate),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('yy년 MM월').format(selectedDate),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.add(Duration(days: 1));
                    schedules = TrainScheduleService.getSchedules(
                      widget.departureStation,
                      widget.arrivalStation,
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
    );
  }

  Widget _buildSeatSelection(bool isReturn) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 80,
      itemBuilder: (context, index) {
        int row = index ~/ 4;
        int col = index % 4;
        String seatNumber = '${String.fromCharCode(65 + row)}${col + 1}';
        bool isSelected = isReturn
            ? selectedReturnSeats.contains(seatNumber)
            : selectedSeats.contains(seatNumber);

        return GestureDetector(
          onTap: () => _selectSeat(seatNumber, isReturn),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(seatNumber)),
          ),
        );
      },
    );
  }

  void _selectSeat(String seatNumber, bool isReturn) {
    setState(() {
      if (isReturn) {
        if (selectedReturnSeats.contains(seatNumber)) {
          selectedReturnSeats.remove(seatNumber);
        } else {
          selectedReturnSeats.add(seatNumber);
        }
      } else {
        if (selectedSeats.contains(seatNumber)) {
          selectedSeats.remove(seatNumber);
        } else {
          selectedSeats.add(seatNumber);
        }
      }
    });
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text('예매하기'),
        onPressed: () {
          if (widget.isRoundTrip && selectedSeats.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('출발편 좌석을 선택해주세요.')),
            );
          } else if (widget.isRoundTrip && selectedReturnSeats.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('도착편 좌석을 선택해주세요.')),
            );
          } else if (!widget.isRoundTrip && selectedSeats.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('좌석을 선택해주세요.')),
            );
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
                  travelDate: selectedDate,
                  returnDate: widget.isRoundTrip
                      ? widget.returnSchedule?.departureTime
                      : null,
                  adultCount: widget.adultCount,
                  childCount: widget.childCount,
                  seniorCount: widget.seniorCount,
                  departureSchedule:
                      schedules[currentScheduleIndex], // 현재 선택된 스케줄
                  returnSchedule:
                      widget.isRoundTrip ? widget.returnSchedule : null,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
