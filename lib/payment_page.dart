import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentPage extends StatelessWidget {
  final String departure;
  final String arrival;
  final String seatNumber;

  PaymentPage({
    required this.departure,
    required this.arrival,
    required this.seatNumber,
  });

  Future<void> initializePaymentSheet() async {
    try {
      // 여기에서 서버로부터 결제 정보를 받아와야 합니다.
      // 이 예시에서는 하드코딩된 값을 사용합니다.
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: 'your_payment_intent_client_secret',
          merchantDisplayName: '기차 예매 서비스',
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제가 완료되었습니다!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 중 오류가 발생했습니다.')),
      );
    }
  }

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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () async {
            await initializePaymentSheet();
            await displayPaymentSheet(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment),
                SizedBox(width: 10),
                Text('결제하기',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
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
    );
  }
}
