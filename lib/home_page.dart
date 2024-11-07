import 'package:flutter/material.dart';
import 'station_list.dart';
import 'seat_page.dart';
import 'passenger_selection.dart';
import 'train_schedule.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? departureStation;
  String? arrivalStation;
  bool isRoundTrip = false;
  int adultCount = 1;
  int childCount = 0;
  int seniorCount = 0;
  DateTime? departureDate;
  DateTime? returnDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('K Rail')),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Image.asset(
                            'asset/KRAIL_LOGO.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('승차권 예매',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 20),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.swap_horiz),
                                  onPressed: () {
                                    setState(() {
                                      final temp = departureStation;
                                      departureStation = arrivalStation;
                                      arrivalStation = temp;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: _buildStationSelector(
                                    '출발역',
                                    departureStation,
                                    () async {
                                      final selectedStation =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StationListPage(
                                            selectedStation: arrivalStation,
                                          ),
                                        ),
                                      );
                                      if (selectedStation != null) {
                                        setState(() {
                                          departureStation = selectedStation;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: Colors.grey[400],
                                ),
                                Expanded(
                                  child: _buildStationSelector(
                                    '도착역',
                                    arrivalStation,
                                    () async {
                                      final selectedStation =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StationListPage(
                                            selectedStation: departureStation,
                                          ),
                                        ),
                                      );
                                      if (selectedStation != null) {
                                        setState(() {
                                          arrivalStation = selectedStation;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDateSelector(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PassengerSelectionPage(
                                    adultCount: adultCount,
                                    childCount: childCount,
                                    seniorCount: seniorCount,
                                  ),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  adultCount = result['adult'];
                                  childCount = result['child'];
                                  seniorCount = result['senior'];
                                });
                              }
                            },
                            child: Text(
                              '인원 선택: 어른 $adultCount명${childCount > 0 ? ', 어린이 $childCount명' : ''}${seniorCount > 0 ? ', 경로 $seniorCount명' : ''}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Row(
                            children: [
                              Text('편도'),
                              Switch(
                                value: isRoundTrip,
                                onChanged: (value) {
                                  setState(() {
                                    isRoundTrip = value;
                                    if (!isRoundTrip) {
                                      returnDate = null;
                                    }
                                  });
                                },
                              ),
                              Text('왕복'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (departureStation != null &&
                                  arrivalStation != null &&
                                  departureDate != null &&
                                  (!isRoundTrip ||
                                      (isRoundTrip && returnDate != null)))
                              ? () {
                                  List<TrainSchedule> schedules =
                                      TrainScheduleService.getSchedules(
                                    departureStation!,
                                    arrivalStation!,
                                    departureDate!,
                                  );

                                  if (schedules.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SeatPage(
                                          departureStation!,
                                          arrivalStation!,
                                          adultCount,
                                          childCount,
                                          seniorCount,
                                          isRoundTrip,
                                          selectedDate: departureDate!,
                                          departureTime:
                                              schedules[0].departureTime,
                                          arrivalTime: schedules[0].arrivalTime,
                                          trainNumber: schedules[0].trainNumber,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 스케줄이 없을 경우 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('선택한 날짜에 이용 가능한 열차가 없습니다.')),
                                    );
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              '좌석 선택',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationSelector(String label, String? station, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 10),
          Text(
            station ?? '선택',
            style: TextStyle(fontSize: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜 선택',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: departureDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null && picked != departureDate) {
                    setState(() {
                      departureDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    departureDate == null
                        ? '가는 날'
                        : DateFormat('yyyy-MM-dd').format(departureDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            if (isRoundTrip) ...[
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          returnDate ?? (departureDate ?? DateTime.now()),
                      firstDate: departureDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != returnDate) {
                      setState(() {
                        returnDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      returnDate == null
                          ? '오는 날'
                          : DateFormat('yyyy-MM-dd').format(returnDate!),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
