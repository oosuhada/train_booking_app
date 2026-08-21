import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'seat_page.dart';
import 'station_list.dart';
import 'v2/v2_glass.dart';

class TrainSchedulePage extends StatefulWidget {
  final String departureStation;
  final String arrivalStation;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;
  final Locale selectedLocale;

  const TrainSchedulePage({
    super.key,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureDate,
    this.returnDate,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
    required this.selectedLocale,
  });

  @override
  State<TrainSchedulePage> createState() => _TrainSchedulePageState();
}

class _TrainSchedulePageState extends State<TrainSchedulePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<TrainSchedule> departureSchedules;
  late final List<TrainSchedule> returnSchedules;
  TrainSchedule? selectedDepartureSchedule;
  TrainSchedule? selectedReturnSchedule;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.isRoundTrip ? 2 : 1, vsync: this);
    final schedules = TrainScheduleService.getSchedules(
      widget.departureStation,
      widget.arrivalStation,
      widget.departureDate,
      widget.isRoundTrip ? widget.returnDate : null,
    );
    departureSchedules = schedules['departure'] ?? const [];
    returnSchedules = schedules['return'] ?? const [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _passengerCount =>
      widget.adultCount + widget.childCount + widget.seniorCount;

  void _selectSchedule(TrainSchedule schedule, bool isReturn) {
    setState(() {
      if (isReturn) {
        selectedReturnSchedule = schedule;
      } else {
        selectedDepartureSchedule = schedule;
      }
    });

    if (!widget.isRoundTrip) {
      _startSeatSelection();
      return;
    }

    if (!isReturn) {
      _tabController.animateTo(1);
    } else {
      _startSeatSelection();
    }
  }

  void _startSeatSelection() {
    if (selectedDepartureSchedule == null) return;
    if (widget.isRoundTrip && selectedReturnSchedule == null) return;

    final currentSchedule = selectedDepartureSchedule!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatPage(
          departure: widget.departureStation,
          arrival: widget.arrivalStation,
          departureStation: currentSchedule.departureStation,
          arrivalStation: currentSchedule.arrivalStation,
          adultCount: widget.adultCount,
          childCount: widget.childCount,
          seniorCount: widget.seniorCount,
          isRoundTrip: widget.isRoundTrip,
          selectedDepartureDate: widget.departureDate,
          selectedReturnDate: widget.returnDate,
          departureSchedule: selectedDepartureSchedule,
          returnSchedule: selectedReturnSchedule,
          departureTime: currentSchedule.departureTime,
          departureArrivalTime: currentSchedule.arrivalTime,
          returnDepartureTime: selectedReturnSchedule?.departureTime,
          returnArrivalTime: selectedReturnSchedule?.arrivalTime,
          isSelectingReturn: false,
          selectedLocale: widget.selectedLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppGlassToolbar(
            title: AppLocalizations.of(context).translate('열차시간표'),
            onBack: () => Navigator.of(context).maybePop(),
            bottom: widget.isRoundTrip
                ? TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: AppLocalizations.of(context).translate('출발편')),
                      Tab(text: AppLocalizations.of(context).translate('도착편')),
                    ],
                  )
                : null,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildJourneyHeader(),
                  Expanded(
                    child: widget.isRoundTrip
                        ? TabBarView(
                            controller: _tabController,
                            children: [
                              _buildScheduleList(departureSchedules, false),
                              _buildScheduleList(returnSchedules, true),
                            ],
                          )
                        : _buildScheduleList(departureSchedules, false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyHeader() {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('M월 d일 (E)', 'ko').format(widget.departureDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: AppGlassSurface(
        borderRadius: BorderRadius.circular(24),
        blurSigma: 14,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _stationSummary(
                    AppLocalizations.of(context).translate('출발'),
                    widget.departureStation,
                    CrossAxisAlignment.start,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: scheme.primary,
                  ),
                ),
                Expanded(
                  child: _stationSummary(
                    AppLocalizations.of(context).translate('도착'),
                    widget.arrivalStation,
                    CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppGlassSurface(
              borderRadius: BorderRadius.circular(14),
              blurSigma: 8,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 17),
                  const SizedBox(width: 8),
                  Text(date,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const Icon(Icons.person_outline_rounded, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    '$_passengerCount${AppLocalizations.of(context).translate('명')}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isRoundTrip
                        ? AppLocalizations.of(context).translate('왕복')
                        : AppLocalizations.of(context).translate('편도'),
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stationSummary(
    String label,
    String station,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppLocalizations.of(context).translate(station),
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildScheduleList(List<TrainSchedule> schedules, bool isReturn) {
    if (schedules.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).translate('운행 열차가 없습니다.')),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildScheduleCard(schedules[index], isReturn, index),
    );
  }

  Widget _buildScheduleCard(
    TrainSchedule schedule,
    bool isReturn,
    int index,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final duration = schedule.arrivalTime.difference(schedule.departureTime);
    final isSelected = isReturn
        ? selectedReturnSchedule?.trainNumber == schedule.trainNumber
        : selectedDepartureSchedule?.trainNumber == schedule.trainNumber;
    final price = PriceInfo.getPrice(
      schedule.departureStation,
      schedule.arrivalStation,
    );
    final availableSeats = 7 + ((index * 11 + 9) % 34);

    return Material(
      color: isSelected ? scheme.primaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _selectSchedule(schedule, isReturn),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      schedule.trainNumber,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (index == 0) ...[
                    const SizedBox(width: 8),
                    _smallBadge(
                      AppLocalizations.of(context).translate('추천'),
                      Icons.auto_awesome_rounded,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '$availableSeats${AppLocalizations.of(context).translate('석 남음')}',
                    style: TextStyle(
                      color: scheme.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _timeBlock(schedule.departureTime, schedule.departureStation),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${duration.inHours}${AppLocalizations.of(context).translate('시간')} ${duration.inMinutes % 60}${AppLocalizations.of(context).translate('분')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: scheme.outlineVariant)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.train_rounded,
                                size: 17,
                                color: scheme.primary,
                              ),
                            ),
                            Expanded(
                                child: Divider(color: scheme.outlineVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _timeBlock(schedule.arrivalTime, schedule.arrivalStation),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.event_seat_outlined,
                      size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).translate('일반실'),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat('#,###').format(price)}${AppLocalizations.of(context).translate('원')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.chevron_right_rounded, color: scheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallBadge(String label, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 3),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _timeBlock(DateTime time, String station) {
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            AppLocalizations.of(context).translate(station),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class TrainSchedule {
  final String trainNumber;
  final String departureStation;
  final String arrivalStation;
  final DateTime departureTime;
  final DateTime arrivalTime;

  const TrainSchedule({
    required this.trainNumber,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
  });
}

class TrainScheduleService {
  static const List<String> stations = [
    '수서',
    '동탄',
    '평택지제',
    '천안아산',
    '오송',
    '대전',
    '김천구미',
    '동대구',
    '경주',
    '울산',
    '부산',
  ];

  static int calculateTravelTime(String departure, String arrival) {
    final departureIndex = stations.indexOf(departure);
    final arrivalIndex = stations.indexOf(arrival);
    if (departureIndex < 0 ||
        arrivalIndex < 0 ||
        departureIndex == arrivalIndex) {
      return 0;
    }

    final lower = departureIndex < arrivalIndex ? departureIndex : arrivalIndex;
    final upper = departureIndex < arrivalIndex ? arrivalIndex : departureIndex;
    var totalMinutes = 0;
    for (var index = lower; index < upper; index++) {
      totalMinutes += _segmentMinutes[index];
    }
    return totalMinutes;
  }

  static const List<int> _segmentMinutes = [
    15,
    10,
    15,
    10,
    30,
    25,
    25,
    15,
    30,
    15,
  ];

  static Map<String, List<TrainSchedule>> getSchedules(
    String departure,
    String arrival,
    DateTime departureDate,
    DateTime? returnDate,
  ) {
    return {
      'departure': _generateSchedules(departure, arrival, departureDate, false),
      'return': returnDate == null
          ? <TrainSchedule>[]
          : _generateSchedules(arrival, departure, returnDate, true),
    };
  }

  static List<TrainSchedule> _generateSchedules(
    String departure,
    String arrival,
    DateTime date,
    bool isReturn,
  ) {
    final travelMinutes = calculateTravelTime(departure, arrival);
    if (travelMinutes == 0) return const [];

    // Demo data is deterministic so the portfolio flow remains usable at any
    // time of day while still reflecting the date chosen by the user.
    const departureMinutes = [370, 450, 530, 610, 690, 770, 850, 930, 1010];
    return List.generate(departureMinutes.length, (index) {
      final minuteOfDay = departureMinutes[index];
      final departureTime = DateTime(
        date.year,
        date.month,
        date.day,
        minuteOfDay ~/ 60,
        minuteOfDay % 60,
      );
      final number = (isReturn ? 200 : 100) + index * 2 + 1;
      return TrainSchedule(
        trainNumber: 'KTX $number',
        departureStation: departure,
        arrivalStation: arrival,
        departureTime: departureTime,
        arrivalTime: departureTime.add(Duration(minutes: travelMinutes)),
      );
    });
  }
}
