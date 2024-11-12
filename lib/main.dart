import 'package:flutter/material.dart';
import 'home_page.dart'; // HomePage import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기차 예매',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(), // 앱 시작 시 HomePage로 이동
    );
  }
}
