import 'package:flutter/material.dart';
import 'station_list.dart';
import 'seat_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? departureStation;
  String? arrivalStation;
  bool isRoundTrip = false;
  int passengerCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('기차 예매')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('승차권 예매',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('편도'),
                Switch(
                  value: isRoundTrip,
                  onChanged: (value) {
                    setState(() {
                      isRoundTrip = value;
                    });
                  },
                ),
                Text('왕복'),
              ],
            ),
            SizedBox(height: 20),
            // 출발역, 도착역 선택 위젯 (기존 코드 유지)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: _buildStationSelector('출발역', departureStation,
                          () async {
                    final selectedStation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StationListPage(
                                selectedStation: arrivalStation)));
                    if (selectedStation != null) {
                      setState(() {
                        departureStation = selectedStation;
                      });
                    }
                  })),
                  Container(width: 2, height: 50, color: Colors.grey[400]),
                  Expanded(
                      child: _buildStationSelector('도착역', arrivalStation,
                          () async {
                    final selectedStation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StationListPage(
                                selectedStation: departureStation)));
                    if (selectedStation != null) {
                      setState(() {
                        arrivalStation = selectedStation;
                      });
                    }
                  })),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('인원: '),
                DropdownButton<int>(
                  value: passengerCount,
                  items:
                      List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        passengerCount = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (departureStation != null && arrivalStation != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeatPage(
                            departure: departureStation!,
                            arrival: arrivalStation!,
                            passengerCount: passengerCount,
                            isRoundTrip: isRoundTrip,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text('좌석 선택'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStationSelector(String label, String? station, Function onTap) {
  return GestureDetector(
      onTap: () => onTap(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            SizedBox(height: 10),
            FittedBox(
                child: Text(station ?? '선택', style: TextStyle(fontSize: 40)))
          ]));
}
