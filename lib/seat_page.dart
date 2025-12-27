import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'payment_page.dart';
import 'station_list.dart';
import 'train_schedule.dart';
import 'v2/v2_glass.dart';

class SeatPage extends StatefulWidget {
  final String departure;
  final String arrival;
  final String departureStation;
  final String arrivalStation;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;
  final DateTime? selectedDepartureDate;
  final DateTime? selectedReturnDate;
  final TrainSchedule? departureSchedule;
  final DateTime departureTime;
  final DateTime departureArrivalTime;
  final TrainSchedule? returnSchedule;
  final DateTime? returnDepartureTime;
  final DateTime? returnArrivalTime;
  final bool isSelectingReturn;
  final Locale selectedLocale;

  const SeatPage({
    super.key,
    required this.departure,
    required this.arrival,
    required this.departureStation,
    required this.arrivalStation,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
    required this.selectedDepartureDate,
    this.selectedReturnDate,
    required this.departureSchedule,
    required this.departureTime,
    required this.departureArrivalTime,
    this.returnSchedule,
    required this.returnDepartureTime,
    required this.returnArrivalTime,
    required this.isSelectingReturn,
    required this.selectedLocale,
  });

  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  static const int _rowCount = 8;
  static const Set<String> _unavailableSeats = {
    '1B',
    '2C',
    '3D',
    '4A',
    '5D',
    '6B',
    '7C',
    '8A',
  };

  final Set<String> _selectedDepartureSeats = {};
  final Set<String> _selectedReturnSeats = {};
  late bool _isSelectingReturn;

  @override
  void initState() {
    super.initState();
    _isSelectingReturn = widget.isSelectingReturn && widget.isRoundTrip;
  }

  int get _requiredSeats =>
      widget.adultCount + widget.childCount + widget.seniorCount;

  Set<String> get _currentSelection =>
      _isSelectingReturn ? _selectedReturnSeats : _selectedDepartureSeats;

  TrainSchedule get _currentSchedule => _isSelectingReturn
      ? (widget.returnSchedule ?? widget.departureSchedule!)
      : widget.departureSchedule!;

  int get _totalPrice => PriceCalculator.calculatePrice(
        widget.departure,
        widget.arrival,
        widget.isRoundTrip,
        widget.adultCount,
        widget.childCount,
        widget.seniorCount,
        null,
        context,
      ).discountedPrice;

  void _toggleSeat(String seat) {
    if (_unavailableSeats.contains(seat)) return;
    setState(() {
      if (_currentSelection.contains(seat)) {
        _currentSelection.remove(seat);
      } else if (_currentSelection.length < _requiredSeats) {
        _currentSelection.add(seat);
      }
    });
  }

  void _continue() {
    if (_currentSelection.length != _requiredSeats) return;

    if (widget.isRoundTrip && !_isSelectingReturn) {
      setState(() => _isSelectingReturn = true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          departure: widget.departure,
          arrival: widget.arrival,
          seatNumbers: _selectedDepartureSeats.toList()..sort(),
          returnSeatNumbers: _selectedReturnSeats.toList()..sort(),
          isRoundTrip: widget.isRoundTrip,
          travelDate: widget.selectedDepartureDate!,
          returnDate: widget.selectedReturnDate,
          adultCount: widget.adultCount,
          childCount: widget.childCount,
          seniorCount: widget.seniorCount,
          departureSchedule: widget.departureSchedule,
          returnSchedule: widget.returnSchedule,
          selectedDepartureDate: widget.selectedDepartureDate!,
          selectedReturnDate: widget.selectedReturnDate,
          selectedLocale: widget.selectedLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          AppGlassToolbar(
            title: AppLocalizations.of(context).translate(
              _isSelectingReturn ? '도착편 좌석 선택' : '출발편 좌석 선택',
            ),
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
                    _buildTripSummary(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('좌석 배치'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        _pill(
                          Icons.train_rounded,
                          AppLocalizations.of(context).translate('3호차 · 일반실'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildLegend(),
                    const SizedBox(height: 14),
                    _buildSeatMap(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTripSummary() {
    final scheme = Theme.of(context).colorScheme;
    final schedule = _currentSchedule;
    final duration = schedule.arrivalTime.difference(schedule.departureTime);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                schedule.trainNumber,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('M월 d일 (E)', 'ko').format(schedule.departureTime),
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _timeStation(schedule.departureTime, schedule.departureStation),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${duration.inHours}${AppLocalizations.of(context).translate('시간')} ${duration.inMinutes % 60}${AppLocalizations.of(context).translate('분')}',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            scheme.onPrimaryContainer.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(child: Divider(color: scheme.primary)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: scheme.primary,
                          ),
                        ),
                        Expanded(child: Divider(color: scheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              _timeStation(schedule.arrivalTime, schedule.arrivalStation),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeStation(DateTime time, String station) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(
            AppLocalizations.of(context).translate(station),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(text,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _legendItem('선택 가능', SeatVisualState.available),
        _legendItem('선택됨', SeatVisualState.selected),
        _legendItem('선택 불가', SeatVisualState.unavailable),
      ],
    );
  }

  Widget _legendItem(String key, SeatVisualState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _seatSwatch(state),
        const SizedBox(width: 5),
        Text(
          AppLocalizations.of(context).translate(key),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _seatSwatch(SeatVisualState state) {
    final scheme = Theme.of(context).colorScheme;
    Color color;
    if (state == SeatVisualState.selected) {
      color = scheme.primary;
    } else if (state == SeatVisualState.unavailable) {
      color = scheme.outlineVariant;
    } else {
      color = scheme.surfaceContainerHighest;
    }
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildSeatMap() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              AppLocalizations.of(context).translate('열차 진행 방향'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              SizedBox(width: 24),
              Expanded(child: _SeatColumnLabel('A')),
              SizedBox(width: 6),
              Expanded(child: _SeatColumnLabel('B')),
              SizedBox(width: 32),
              Expanded(child: _SeatColumnLabel('C')),
              SizedBox(width: 6),
              Expanded(child: _SeatColumnLabel('D')),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 1; row <= _rowCount; row++) ...[
            _buildSeatRow(row),
            if (row != _rowCount) const SizedBox(height: 7),
          ],
        ],
      ),
    );
  }

  Widget _buildSeatRow(int row) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$row',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: _seatButton('$row' 'A')),
        const SizedBox(width: 6),
        Expanded(child: _seatButton('$row' 'B')),
        const SizedBox(width: 32),
        Expanded(child: _seatButton('$row' 'C')),
        const SizedBox(width: 6),
        Expanded(child: _seatButton('$row' 'D')),
      ],
    );
  }

  Widget _seatButton(String seat) {
    final scheme = Theme.of(context).colorScheme;
    final isUnavailable = _unavailableSeats.contains(seat);
    final isSelected = _currentSelection.contains(seat);
    final background = isUnavailable
        ? scheme.outlineVariant
        : isSelected
            ? scheme.primary
            : scheme.surfaceContainerHighest;
    final foreground = isSelected
        ? scheme.onPrimary
        : isUnavailable
            ? scheme.onSurfaceVariant.withValues(alpha: 0.42)
            : scheme.onSurface;

    return Semantics(
      button: true,
      enabled: !isUnavailable,
      selected: isSelected,
      label: seat,
      child: InkWell(
        onTap: isUnavailable ? null : () => _toggleSeat(seat),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 39,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
            border:
                isSelected ? Border.all(color: scheme.primary, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            seat,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final scheme = Theme.of(context).colorScheme;
    final complete = _currentSelection.length == _requiredSeats;
    final seats = _currentSelection.toList()..sort();

    return AppGlassBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('선택 좌석'),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      seats.isEmpty
                          ? AppLocalizations.of(context).translate('좌석을 선택하세요')
                          : seats.join(', '),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('예상 결제금액'),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(_totalPrice)}${AppLocalizations.of(context).translate('원')}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: complete ? _continue : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  widget.isRoundTrip && !_isSelectingReturn
                      ? AppLocalizations.of(context).translate('돌아오는 편 좌석 선택')
                      : AppLocalizations.of(context).translate('다음'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatColumnLabel extends StatelessWidget {
  final String label;

  const _SeatColumnLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum SeatVisualState { available, selected, unavailable }
