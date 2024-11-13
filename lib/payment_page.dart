import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'train_schedule.dart';
import 'station_list.dart';

class PaymentPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final List<String> seatNumbers;
  final List<String> returnSeatNumbers;
  final DateTime travelDate;
  final DateTime? returnDate;
  final bool isRoundTrip;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final TrainSchedule departureSchedule;
  final TrainSchedule? returnSchedule;
  final DateTime selectedDepartureDate;
  final DateTime? selectedReturnDate;

  PaymentPage({
    required this.departure,
    required this.arrival,
    required this.seatNumbers,
    required this.returnSeatNumbers,
    required this.travelDate,
    this.returnDate,
    required this.isRoundTrip,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.departureSchedule,
    this.returnSchedule,
    required this.selectedDepartureDate,
    this.selectedReturnDate,
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
              _buildSectionWithDivider('일정 정보', [
                '출발역: ${widget.departure}',
                '도착역: ${widget.arrival}',
                '출발편: ${widget.departureSchedule.trainNumber} (${DateFormat('yyyy년 MM월 dd일 HH:mm').format(widget.selectedDepartureDate)})',
                if (widget.isRoundTrip && widget.returnSchedule != null)
                  '도착편: ${widget.returnSchedule!.trainNumber} (${DateFormat('yyyy년 MM월 dd일 HH:mm').format(widget.selectedReturnDate!)})',
              ]),
              SizedBox(height: 10),
              _buildSectionWithDivider('좌석 정보', [
                '출발편 좌석: ${widget.seatNumbers.join(", ")}',
                if (widget.isRoundTrip)
                  '도착편 좌석: ${widget.returnSeatNumbers.join(", ")}',
                '어른: ${widget.adultCount}명, 어린이: ${widget.childCount}명, 경로: ${widget.seniorCount}명',
              ]),
              SizedBox(height: 10),
              _buildSectionWithDivider('일정 정보', [
                '출발편: ${widget.departureSchedule.trainNumber} (${DateFormat('yyyy년 MM월 dd일 HH:mm').format(widget.departureSchedule.departureTime)} - ${DateFormat('HH:mm').format(widget.departureSchedule.arrivalTime)})',
                if (widget.isRoundTrip && widget.returnSchedule != null)
                  '도착편: ${widget.returnSchedule!.trainNumber} (${DateFormat('yyyy년 MM월 dd일 HH:mm').format(widget.returnSchedule!.departureTime)} - ${DateFormat('HH:mm').format(widget.returnSchedule!.arrivalTime)})',
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
