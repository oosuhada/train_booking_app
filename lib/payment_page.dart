import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String departure;
  final String arrival;
  final String seatNumber;

  PaymentPage(
      {required this.departure,
      required this.arrival,
      required this.seatNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('결제하기')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('예매 정보',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('출발역: $departure'),
            Text('도착역: $arrival'),
            Text('좌석: $seatNumber'),
            SizedBox(height: 40),
            Text('결제 금액: 50,000원'), // 예시 금액
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 여기에 실제 결제 로직을 구현합니다.
                  // 결제가 완료되면 홈 페이지로 돌아갑니다.
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('결제하기', style: TextStyle(fontSize: 18)),
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
    );
  }
}
