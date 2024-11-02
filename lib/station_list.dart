import 'package:flutter/material.dart';

void main() {
  runApp(StationListPage());
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('역 선택')),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(stations[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              // 역 선택 후 HomePage로 돌아가기
              Navigator.pop(context, stations[index]);
            },
          );
        },
      ),
    );
  }
}
