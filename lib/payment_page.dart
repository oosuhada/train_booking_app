import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final List<String> seatNumbers;
  final bool isRoundTrip;
  final DateTime travelDate;
  final int adultCount;
  final int childCount;
  final int seniorCount;

  PaymentPage({
    required this.departure,
    required this.arrival,
    required this.seatNumbers,
    required this.isRoundTrip,
    required this.travelDate,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
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
    basePrice = PriceInfo.getPrice(widget.departure, widget.arrival);
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    int adultPrice = basePrice * widget.adultCount;
    int childPrice = (basePrice * 0.5).round() * widget.childCount;
    int seniorPrice = (basePrice * 0.7).round() * widget.seniorCount;
    totalPrice = adultPrice + childPrice + seniorPrice;
    if (widget.isRoundTrip) {
      totalPrice *= 2;
    }
  }

  void applyCoupon(String? coupon) {
    setState(() {
      selectedCoupon = coupon;
      calculateTotalPrice();
      if (coupon != null) {
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
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('결제하기')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('예약 정보',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildInfoSection('예약 정보', [
                '출발역: ${widget.departure}',
                '도착역: ${widget.arrival}',
                '날짜: ${DateFormat('yyyy년 MM월 dd일').format(widget.travelDate)}',
                '좌석: ${widget.seatNumbers.join(", ")}',
                widget.isRoundTrip ? "왕복" : "편도",
              ]),
              SizedBox(height: 20),
              _buildInfoSection('가격 정보', [
                '기본 편도 가격: ${basePrice}원',
                '어른 (${widget.adultCount}명): ${basePrice * widget.adultCount}원',
                '어린이 (${widget.childCount}명): ${(basePrice * 0.5).round() * widget.childCount}원',
                '경로 (${widget.seniorCount}명): ${(basePrice * 0.7).round() * widget.seniorCount}원',
                if (widget.isRoundTrip) '왕복 요금: ${totalPrice}원',
              ]),
              SizedBox(height: 20),
              Text('쿠폰 선택:'),
              DropdownButton<String>(
                value: selectedCoupon,
                items:
                    [null, '10% 할인', '15% 할인', '20% 할인'].map((String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value ?? '쿠폰 선택'),
                  );
                }).toList(),
                onChanged: applyCoupon,
              ),
              SizedBox(height: 20),
              Text(
                '최종 가격: ${totalPrice}원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            // 결제 로직 구현
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

Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...items.map((item) => Text(item)).toList(),
      ],
    );
  }
}

class PriceInfo {
  static int getPrice(String departure, String arrival)
}