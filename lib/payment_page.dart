import 'package:flutter/material.dart';
import 'station_list.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final List<String> seatNumbers;
  final bool isRoundTrip;
  final DateTime travelDate;

  PaymentPage({
    required this.departure,
    required this.arrival,
    required this.seatNumbers,
    required this.isRoundTrip,
    required this.travelDate,
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
    totalPrice = basePrice * widget.seatNumbers.length;
    if (widget.isRoundTrip) {
      totalPrice *= 2;
    }
  }

  void applyCoupon(String coupon) {
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
          totalPrice = basePrice * widget.seatNumbers.length;
          if (widget.isRoundTrip) {
            totalPrice *= 2;
          }
      }
    });
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
            Text(
                '날짜: ${DateFormat('yyyy년 MM월 dd일').format(widget.travelDate)}'),
            Text('좌석: ${widget.seatNumbers.join(", ")}'),
            Text(widget.isRoundTrip ? "왕복" : "편도"),
            SizedBox(height: 20),
            Text('기본 편도 가격: ${basePrice}원'),
            Text(
                '선택 가격: ${basePrice * widget.seatNumbers.length}원 (${widget.seatNumbers.length}석)'),
            if (widget.isRoundTrip)
              Text('왕복 가격: ${basePrice * widget.seatNumbers.length * 2}원'),
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
                if (newValue != null) {
                  applyCoupon(newValue);
                } else {
                  setState(() {
                    selectedCoupon = null;
                    totalPrice = basePrice * widget.seatNumbers.length;
                    if (widget.isRoundTrip) {
                      totalPrice *= 2;
                    }
                  });
                }
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
