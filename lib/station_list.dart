import 'package:flutter/material.dart';

class StationListPage extends StatelessWidget {
  final List<String> stations = [
    '수서',
    '동탄',
    '평택지제',
    '천안아산',
    '오송',
    '대전',
    '김천구미',
    '동대구',
    '경주',
    '울산',
    '부산'
  ];

  final String? selectedStation; // 이미 선택된 역 (출발 또는 도착)

  StationListPage({this.selectedStation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('역 선택')),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          if (stations[index] == selectedStation)
            return Container(); // 이미 선택된 역은 표시하지 않음

          return ListTile(
            title: Text(stations[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context, stations[index]); // 역을 선택하고 HomePage로 돌아가기
            },
          );
        },
      ),
    );
  }
}
