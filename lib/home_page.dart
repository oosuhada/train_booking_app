import 'package:flutter/material.dart';
import 'station_list.dart';
import 'seat_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? departureStation; // 출발역 저장 변수
  String? arrivalStation; // 도착역 저장 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('기차 예매')),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // 출발역 및 도착역을 감싸는 박스
              Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 출발역 선택 영역
                        Expanded(
                            child: _buildStationSelector(
                                '출발역', departureStation, () async {
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

                        // 세로선 고정
                        Container(
                            width: 2, height: 50, color: Colors.grey[400]),

                        // 도착역 선택 영역
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
                        }))
                      ])),

              SizedBox(height: 20),

              // 좌석 선택 버튼
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (departureStation != null &&
                              arrivalStation != null)
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SeatPage(
                                          departureStation!, arrivalStation!)));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text('좌석 선택',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)))))
            ])));
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
}
