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
        body: Container(
          color: Colors.grey[200],
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10), // 여백을 절반으로 줄임
                      Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(
                          child: Image.asset(
                            'assets/KRAIL_LOGO.jpg', // asset 폴더의 이미지 파일 경로
                            fit: BoxFit.contain, // 이미지가 컨테이너에 맞게 조정되도록 설정
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('승차권 예매',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
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
                                      '출발역', departureStation, () async {
                                    final selectedStation =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StationListPage(
                                            selectedStation: arrivalStation),
                                      ),
                                    );
                                    if (selectedStation != null) {
                                      setState(() {
                                        departureStation = selectedStation;
                                      });
                                    }
                                  }),
                                ),
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: Colors.grey[400],
                                ),
                                Expanded(
                                  child: _buildStationSelector(
                                      '도착역', arrivalStation, () async {
                                    final selectedStation =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StationListPage(
                                            selectedStation: departureStation),
                                      ),
                                    );
                                    if (selectedStation != null) {
                                      setState(() {
                                        arrivalStation = selectedStation;
                                      });
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                                  arrivalStation != null)
                              ? () {
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
          ]),
        ));
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
}
