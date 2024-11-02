import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'train_booking_app',
      theme: ThemeData(),
      home: MyHomePage(title: 'train_booking_app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기차 예매'),
      ),
      body: Center(
        child: Text('기차 예매 서비스에 오신 것을 환영합니다!'),
      ),
    );
  }
}
