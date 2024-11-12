import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'station_list.dart'; // PriceInfo 클래스가 포함된 파일

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
  late Map<String, int> priceDetails;
  int totalPrice = 0;
  String? selectedCoupon;

  @override
  void initState() {
    super.initState();
    calculatePrice();
  }

  void calculatePrice() {
    priceDetails = PriceCalculateInfo.getPriceDetails(
      widget.departure,
      widget.arrival,
      widget.isRoundTrip,
      widget.adultCount,
      widget.childCount,
      widget.seniorCount,
    );
    totalPrice = priceDetails['total']!;
  }

  void applyCoupon(String? coupon) {
    setState(() {
      selectedCoupon = coupon;
      if (coupon != null) {
        totalPrice = PriceCalculateInfo.applyCoupon(totalPrice, coupon);
      } else {
        calculatePrice();
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
                '기본 편도 가격: ${PriceInfo.getPrice(widget.departure, widget.arrival)}원',
                '어른 (${widget.adultCount}명): ${priceDetails['adult']}원',
                '어린이 (${widget.childCount}명): ${priceDetails['child']}원',
                '경로 (${widget.seniorCount}명): ${priceDetails['senior']}원',
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

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...items.map((item) => Text(item)).toList(),
      ],
    );
  }
}

// PriceCalculateInfo 클래스 수정
class PriceCalculateInfo {
  static Map<String, int> getPriceDetails(String departure, String arrival,
      bool isRoundTrip, int adultCount, int childCount, int seniorCount) {
    int basePrice = PriceInfo.getPrice(departure, arrival);

    int adultPrice = basePrice * adultCount;
    int childPrice = (basePrice * 0.5).round() * childCount;
    int seniorPrice = (basePrice * 0.7).round() * seniorCount;

    int totalPrice = adultPrice + childPrice + seniorPrice;

    if (isRoundTrip) {
      adultPrice *= 2;
      childPrice *= 2;
      seniorPrice *= 2;
      totalPrice *= 2;
    }

    return {
      'adult': adultPrice,
      'child': childPrice,
      'senior': seniorPrice,
      'total': totalPrice,
    };
  }

  static int applyCoupon(int price, String coupon) {
    switch (coupon) {
      case '10% 할인':
        return (price * 0.9).round();
      case '15% 할인':
        return (price * 0.85).round();
      case '20% 할인':
        return (price * 0.8).round();
      default:
        return price;
    }
  }
}
