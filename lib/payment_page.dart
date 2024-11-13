import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'station_list.dart';

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
  late PriceInfo priceInfo;
  String? selectedCoupon;

  @override
  void initState() {
    super.initState();
    calculatePrice();
  }

  void calculatePrice() {
    priceInfo = PriceCalculator.calculatePrice(
      widget.departure,
      widget.arrival,
      widget.isRoundTrip,
      widget.adultCount,
      widget.childCount,
      widget.seniorCount,
      selectedCoupon,
    );
  }

  void applyCoupon(String? coupon) {
    setState(() {
      selectedCoupon = coupon;
      calculatePrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('결제하기')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('예약 정보',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildSectionWithDivider(' 일정 정보', [
                ' 출발역: ${widget.departure}',
                ' 도착역: ${widget.arrival}',
                ' 날짜: ${DateFormat('yyyy년 MM월 dd일').format(widget.travelDate)}',
                widget.isRoundTrip ? " 왕복" : " 편도",
              ]),
              SizedBox(height: 10),
              _buildSectionWithDivider(' 좌석 정보', [
                ' 좌석: ${widget.seatNumbers.join(", ")}',
                ' 어른: ${widget.adultCount}명, 어린이: ${widget.childCount}명, 경로: ${widget.seniorCount}명',
              ]),
              SizedBox(height: 10),
              _buildSectionWithDivider(' 가격 정보', [
                ' 기본 편도 가격: ${PriceInfo.getPrice(widget.departure, widget.arrival)}원',
                ' 어른 (${widget.adultCount}명): ${widget.adultCount * PriceInfo.getPrice(widget.departure, widget.arrival)}원',
                ' 어린이 (${widget.childCount}명): ${(widget.childCount * PriceInfo.getPrice(widget.departure, widget.arrival) * 0.5).round()}원',
                ' 경로 (${widget.seniorCount}명): ${(widget.seniorCount * PriceInfo.getPrice(widget.departure, widget.arrival) * 0.7).round()}원',
                ' 할인 전 가격: ${priceInfo.originalPrice}원',
              ]),
              SizedBox(height: 15),
              Text('쿠폰 선택:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              SizedBox(height: 15),
              Text('할인 유형: ${priceInfo.discountType}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('최종 가격: ${priceInfo.discountedPrice}원',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                Icon(Icons.payment, color: Colors.white),
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

  Widget _buildSectionWithDivider(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(color: Colors.grey),
        _buildInfoBox(items),
      ],
    );
  }

  Widget _buildInfoBox(List<String> items) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Text(item)).toList(),
      ),
    );
  }
}
