import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'station_list.dart';

class PaymentPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final List<String> seatNumbers;
  final bool isRoundTrip;

  PaymentPage({
    required this.departure,
    required this.arrival,
    required this.seatNumbers,
    required this.isRoundTrip,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int basePrice = 0;
  int totalPrice = 0;
  String? selectedCoupon;

  @override
  void initState() {
    super.initState();
    calculatePrice();
  }

  void calculatePrice() {
    basePrice = PriceInfo.getPrice(widget.departure, widget.arrival);
    int seatCount = widget.seatNumbers.length;

    if (widget.isRoundTrip) {
      basePrice *= 2;
    }

    totalPrice = basePrice * seatCount;
    applyDiscount(selectedCoupon);
  }

  void applyDiscount(String? coupon) {
    setState(() {
      selectedCoupon = coupon;
      switch (coupon) {
        case '10% 할인':
          totalPrice = (totalPrice * 0.9).round();
          break;
        case '15% 할인':
          totalPrice = (totalPrice * 0.85).round();
          break;
        case '20% 할인':
          totalPrice = (totalPrice * 0.8).round();
          break;
        default:
          // No discount
          break;
      }
    });
  }

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
            Text('출발역: ${widget.departure}'),
            Text('도착역: ${widget.arrival}'),
            Text('좌석: ${widget.seatNumbers.join(", ")}'),
            Text(widget.isRoundTrip ? '왕복' : '편도'),
            SizedBox(height: 20),
            Text('기본 가격: ${basePrice}원'),
            Text('선택한 좌석 수: ${widget.seatNumbers.length}'),
            SizedBox(height: 20),
            Text('쿠폰 선택:'),
            DropdownButton<String>(
              value: selectedCoupon,
              items: [null, '10% 할인', '15% 할인', '20% 할인'].map((String? value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value ?? '쿠폰 선택'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                applyDiscount(newValue);
              },
            ),
            SizedBox(height: 20),
            Text('최종 가격: ${totalPrice}원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
