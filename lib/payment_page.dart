import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'station_list.dart';
import 'train_schedule.dart';
import 'v2/v2_glass.dart';

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

  const PaymentPage({
    super.key,
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
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedCoupon;
  bool _confirmed = false;

  int get _oneWayAdultPrice =>
      PriceInfo.getPrice(widget.departure, widget.arrival);

  int get _originalPrice {
    var total = _oneWayAdultPrice * widget.adultCount;
    total += (_oneWayAdultPrice * 0.5).round() * widget.childCount;
    total += (_oneWayAdultPrice * 0.7).round() * widget.seniorCount;
    return widget.isRoundTrip ? total * 2 : total;
  }

  double get _discountRate {
    if (_selectedCoupon == '10% 할인') return 0.10;
    if (_selectedCoupon == '15% 할인') return 0.15;
    if (_selectedCoupon == '20% 할인') return 0.20;
    return 0;
  }

  int get _discountAmount => (_originalPrice * _discountRate).round();
  int get _finalPrice => _originalPrice - _discountAmount;

  String _price(int value) => NumberFormat('#,###').format(value);

  String get _reservationCode {
    final stamp = DateFormat('yyMMdd').format(widget.selectedDepartureDate);
    final train =
        widget.departureSchedule?.trainNumber.replaceAll(' ', '') ?? 'KTX';
    return 'KR-$stamp-$train';
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmed) return _buildConfirmation();

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          AppGlassToolbar(
            title: AppLocalizations.of(context).translate('결제하기'),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDemoNotice(),
                    const SizedBox(height: 14),
                    _buildJourneyCard(),
                    const SizedBox(height: 14),
                    _buildPassengerCard(),
                    const SizedBox(height: 14),
                    _buildPriceCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPaymentBar(),
    );
  }

  Widget _buildDemoNotice() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 19, color: scheme.onTertiaryContainer),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              AppLocalizations.of(context).translate('데모 안내 문구'),
              style: TextStyle(
                color: scheme.onTertiaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard() {
    final scheme = Theme.of(context).colorScheme;
    final schedule = widget.departureSchedule!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).translate('예약 정보'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  schedule.trainNumber,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _stationTime(schedule.departureStation, schedule.departureTime),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: scheme.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 18, color: scheme.primary),
                      ),
                      Expanded(child: Divider(color: scheme.outlineVariant)),
                    ],
                  ),
                ),
              ),
              _stationTime(schedule.arrivalStation, schedule.arrivalTime),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 17),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy년 M월 d일 (E)', 'ko')
                      .format(widget.selectedDepartureDate),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  widget.isRoundTrip
                      ? AppLocalizations.of(context).translate('왕복')
                      : AppLocalizations.of(context).translate('편도'),
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stationTime(String station, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate(station),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildPassengerCard() {
    final scheme = Theme.of(context).colorScheme;
    final passengerParts = <String>[];
    if (widget.adultCount > 0) {
      passengerParts.add(
          '${AppLocalizations.of(context).translate('어른')} ${widget.adultCount}');
    }
    if (widget.childCount > 0) {
      passengerParts.add(
          '${AppLocalizations.of(context).translate('어린이')} ${widget.childCount}');
    }
    if (widget.seniorCount > 0) {
      passengerParts.add(
          '${AppLocalizations.of(context).translate('경로')} ${widget.seniorCount}');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('좌석 정보'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.person_outline_rounded,
            AppLocalizations.of(context).translate('승객'),
            passengerParts.join(' · '),
          ),
          const SizedBox(height: 11),
          _infoRow(
            Icons.event_seat_outlined,
            AppLocalizations.of(context).translate('선택 좌석'),
            '${AppLocalizations.of(context).translate('3호차')} · ${widget.seatNumbers.join(', ')}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('가격 정보'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          if (widget.adultCount > 0)
            _priceRow(
              '${AppLocalizations.of(context).translate('어른')} × ${widget.adultCount}${widget.isRoundTrip ? ' × 2' : ''}',
              _oneWayAdultPrice *
                  widget.adultCount *
                  (widget.isRoundTrip ? 2 : 1),
            ),
          if (widget.childCount > 0)
            _priceRow(
              '${AppLocalizations.of(context).translate('어린이')} × ${widget.childCount}${widget.isRoundTrip ? ' × 2' : ''}',
              (_oneWayAdultPrice * 0.5).round() *
                  widget.childCount *
                  (widget.isRoundTrip ? 2 : 1),
            ),
          if (widget.seniorCount > 0)
            _priceRow(
              '${AppLocalizations.of(context).translate('경로')} × ${widget.seniorCount}${widget.isRoundTrip ? ' × 2' : ''}',
              (_oneWayAdultPrice * 0.7).round() *
                  widget.seniorCount *
                  (widget.isRoundTrip ? 2 : 1),
            ),
          const Divider(height: 26),
          DropdownButtonFormField<String?>(
            value: _selectedCoupon,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('쿠폰 선택'),
              prefixIcon: const Icon(Icons.local_offer_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: [null, '10% 할인', '15% 할인', '20% 할인']
                .map(
                  (coupon) => DropdownMenuItem<String?>(
                    value: coupon,
                    child: Text(
                      coupon == null
                          ? AppLocalizations.of(context).translate('할인 없음')
                          : AppLocalizations.of(context).translate(coupon),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCoupon = value),
          ),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 12),
            _priceRow(
              AppLocalizations.of(context).translate('할인 금액'),
              -_discountAmount,
              emphasize: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, int amount, {bool emphasize = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize ? scheme.primary : scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}${_price(amount.abs())}${AppLocalizations.of(context).translate('원')}',
            style: TextStyle(
              color: emphasize ? scheme.primary : null,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBar() {
    return AppGlassBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).translate('총 결제금액'),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${_price(_finalPrice)}${AppLocalizations.of(context).translate('원')}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => _confirmed = true),
              icon: const Icon(Icons.lock_outline_rounded, size: 19),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  AppLocalizations.of(context).translate('데모 결제하기'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    final scheme = Theme.of(context).colorScheme;
    final schedule = widget.departureSchedule!;
    return Scaffold(
      body: Column(
        children: [
          const AppGlassToolbar(title: 'K-Rail'),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 42, color: scheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).translate('예약이 완료되었습니다'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      AppLocalizations.of(context).translate('데모 예약 안내'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('예약번호'),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant),
                              ),
                              const Spacer(),
                              Text(
                                _reservationCode,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: _confirmationStation(
                                  schedule.departureStation,
                                  schedule.departureTime,
                                  CrossAxisAlignment.start,
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded,
                                  color: scheme.primary),
                              Expanded(
                                child: _confirmationStation(
                                  schedule.arrivalStation,
                                  schedule.arrivalTime,
                                  CrossAxisAlignment.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _confirmationLine(
                            AppLocalizations.of(context).translate('열차'),
                            schedule.trainNumber,
                          ),
                          _confirmationLine(
                            AppLocalizations.of(context).translate('날짜'),
                            DateFormat('yyyy.MM.dd')
                                .format(schedule.departureTime),
                          ),
                          _confirmationLine(
                            AppLocalizations.of(context).translate('좌석'),
                            '${AppLocalizations.of(context).translate('3호차')} · ${widget.seatNumbers.join(', ')}',
                          ),
                          _confirmationLine(
                            AppLocalizations.of(context).translate('승객'),
                            '${widget.adultCount + widget.childCount + widget.seniorCount}${AppLocalizations.of(context).translate('명')}',
                          ),
                          const Divider(height: 28),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).translate('결제 금액'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              const Spacer(),
                              Text(
                                '${_price(_finalPrice)}${AppLocalizations.of(context).translate('원')}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            AppLocalizations.of(context).translate('홈으로'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmationStation(
    String station,
    DateTime time,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          AppLocalizations.of(context).translate(station),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _confirmationLine(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
