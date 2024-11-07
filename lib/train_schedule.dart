import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'seat_page.dart';

class TrainSchedulePage extends StatefulWidget {
  final String departure;
  final String arrival;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;

  TrainSchedulePage({
    required this.departure,
    required this.arrival,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
  });

  @override
  _TrainSchedulePageState createState() => _TrainSchedulePageState();
}

class _TrainSchedulePageState extends State<TrainSchedulePage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();
    generateSchedules();
  }

  void generateSchedules() {
    schedules = List.generate(5, (index) {
      return {
        'departureTime': DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 6 + index * 2, 0),
        'arrivalTime': DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, 8 + index * 2, 30),
        'trainNumber': 'KTX${100 + index}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('기차 스케줄')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.subtract(Duration(days: 1));
                      generateSchedules();
                    });
                  },
                ),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedDate.add(Duration(days: 1));
                      generateSchedules();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return ListTile(
                  title: Text('${schedule['trainNumber']}'),
                  subtitle: Text(
                    '${DateFormat('HH:mm').format(schedule['departureTime'])} - ${DateFormat('HH:mm').format(schedule['arrivalTime'])}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatPage(
                          widget.departure,
                          widget.arrival,
                          widget.adultCount,
                          widget.childCount,
                          widget.seniorCount,
                          widget.isRoundTrip,
                          selectedDate: selectedDate,
                          departureTime: schedule['departureTime'],
                          arrivalTime: schedule['arrivalTime'],
                          trainNumber: schedule['trainNumber'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
