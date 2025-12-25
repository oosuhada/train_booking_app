import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'train_schedule.dart';
import 'station_list.dart';
import 'app_localizations.dart';

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
  final TrainSchedule? departureSchedule;
  final TrainSchedule? returnSchedule;
  final DateTime selectedDepartureDate;
  final DateTime? selectedReturnDate;
  final Locale selectedLocale;

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
    required this.selectedLocale,
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
      context,
    );
  }

  void applyCoupon(String? coupon) {
    setState(() {
      selectedCoupon = coupon;
      calculatePrice();
    });
  }

  //가격 표시 포맷을 위한 유틸리티 함수
  String formatPrice(dynamic price) {
    NumberFormat numberFormat = NumberFormat('#,###');
    return numberFormat.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('결제하기'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).translate('예약 정보'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildSectionWithDivider(
                  AppLocalizations.of(context).translate('일정 정보'), [
                '${AppLocalizations.of(context).translate('출발역')}: ${AppLocalizations.of(context).translate(widget.departure)}',
                '${AppLocalizations.of(context).translate('도착역')}: ${AppLocalizations.of(context).translate(widget.arrival)}',
                '${AppLocalizations.of(context).translate('출발편')}: ${widget.departureSchedule?.trainNumber}',
                '${AppLocalizations.of(context).translate('출발')}: ${DateFormat('HH:mm').format(widget.departureSchedule!.departureTime)} ${AppLocalizations.of(context).translate('도착')}: ${DateFormat('HH:mm').format(widget.departureSchedule!.arrivalTime)}',
                if (widget.isRoundTrip && widget.returnSchedule != null) ...[
                  '', // 빈 문자열을 추가하여 간격 생성
                  '${AppLocalizations.of(context).translate('출발역')}: ${AppLocalizations.of(context).translate(widget.arrival)}',
                  '${AppLocalizations.of(context).translate('도착역')}: ${AppLocalizations.of(context).translate(widget.departure)}',
                  '${AppLocalizations.of(context).translate('도착편')}: ${widget.returnSchedule!.trainNumber}',
                  '${AppLocalizations.of(context).translate('출발')}: ${DateFormat('HH:mm').format(widget.returnSchedule!.departureTime)} ${AppLocalizations.of(context).translate('도착')}: ${DateFormat('HH:mm').format(widget.returnSchedule!.arrivalTime)}',
                ],
              ]),
              SizedBox(height: 10),
              _buildSectionWithDivider(
                  AppLocalizations.of(context).translate('좌석 정보'), [
                '${AppLocalizations.of(context).translate('출발편 좌석')}: ${widget.seatNumbers.join(", ")}',
                if (widget.isRoundTrip)
                  '${AppLocalizations.of(context).translate('도착편 좌석')}: ${widget.returnSeatNumbers.join(", ")}',
                '${AppLocalizations.of(context).translate('어른')}: ${widget.adultCount}, ${AppLocalizations.of(context).translate('어린이')}: ${widget.childCount}, ${AppLocalizations.of(context).translate('경로')}: ${widget.seniorCount}',
              ]),
              SizedBox(height: 10),
              SizedBox(height: 10),
              _buildSectionWithDivider(
                  AppLocalizations.of(context).translate('가격 정보'), [
                '${AppLocalizations.of(context).translate('기본 편도 가격')}: ${formatPrice(PriceInfo.getPrice(widget.departure, widget.arrival))}${AppLocalizations.of(context).translate('원')}',
                if (widget.adultCount > 0)
                  '${AppLocalizations.of(context).translate('어른')} ${widget.adultCount} : ${formatPrice(widget.adultCount * PriceInfo.getPrice(widget.departure, widget.arrival))}${AppLocalizations.of(context).translate('원')}',
                if (widget.childCount > 0)
                  '${AppLocalizations.of(context).translate('어린이')} ${widget.childCount} : ${formatPrice((widget.childCount * PriceInfo.getPrice(widget.departure, widget.arrival) * 0.5).round())}${AppLocalizations.of(context).translate('원')}',
                if (widget.seniorCount > 0)
                  '${AppLocalizations.of(context).translate('경로')} ${widget.seniorCount} : ${formatPrice((widget.seniorCount * PriceInfo.getPrice(widget.departure, widget.arrival) * 0.7).round())}${AppLocalizations.of(context).translate('원')}',
                '${AppLocalizations.of(context).translate('할인 전 가격')}: ${formatPrice(priceInfo.originalPrice)}${AppLocalizations.of(context).translate('원')}',
              ]),
              SizedBox(height: 15),
              Text(AppLocalizations.of(context).translate('쿠폰 선택'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedCoupon,
                items:
                    [null, '10% 할인', '15% 할인', '20% 할인'].map((String? value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value != null
                        ? AppLocalizations.of(context).translate(value)
                        : AppLocalizations.of(context).translate('쿠폰 선택')),
                  );
                }).toList(),
                onChanged: applyCoupon,
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 35, left: 30, right: 30, bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('할인 유형')}:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  priceInfo.discountType,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('최종 가격')}:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${formatPrice(priceInfo.discountedPrice)}${AppLocalizations.of(context).translate('원')}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            ElevatedButton(
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
                    Text(AppLocalizations.of(context).translate('결제하기'),
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
          ],
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
