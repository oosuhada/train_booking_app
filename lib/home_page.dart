import 'package:flutter/material.dart';
import 'station_list.dart';
import 'seat_page.dart';
import 'passenger_selection.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('K Rail')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('승차권 예매',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
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
                ],
              ),
              SizedBox(height: 20),
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
                      }),
                    ),
                    IconButton(
                      icon: Icon(Icons.swap_horiz),
                      onPressed: () {
                        setState(() {
                          final temp = departureStation;
                          departureStation = arrivalStation;
                          arrivalStation = temp;
                        });
                      },
                    ),
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
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                '인원 선택',
                style: TextStyle(fontSize: 14, color: Colors.purple),
              ),
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
                  '어른 $adultCount명${childCount > 0 ? ', 어린이 $childCount명' : ''}${seniorCount > 0 ? ', 경로 $seniorCount명' : ''}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (departureStation != null && arrivalStation != null)
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeatPage(
                                    departureStation!, // 출발역
                                    arrivalStation!, // 도착역
                                    adultCount, // 성인 수 (예시로 추가)
                                    childCount, // 어린이 수 (예시로 추가)
                                    seniorCount, // 노인 수 (예시로 추가)
                                    isRoundTrip, // 왕복 여부
                                  ),
                                ),
                              );
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
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Text('이미지 위젯 공간'),
                ),
              ),
            ],
          ),
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
          FittedBox(
            child: Text(
              station ?? '선택',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}
