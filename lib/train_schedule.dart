import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'seat_page.dart';
import 'station_list.dart';

class TrainSchedulePage extends StatefulWidget {
  final String departureStation;
  final String arrivalStation;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int adultCount;
  final int childCount;
  final int seniorCount;
  final bool isRoundTrip;

  TrainSchedulePage({
    required this.departureStation,
    required this.arrivalStation,
    required this.departureDate,
    this.returnDate,
    required this.adultCount,
    required this.childCount,
    required this.seniorCount,
    required this.isRoundTrip,
  });

  @override
  _TrainSchedulePageState createState() => _TrainSchedulePageState();
}

class _TrainSchedulePageState extends State<TrainSchedulePage> {
  late List<TrainSchedule> departureSchedules;
  late List<TrainSchedule> returnSchedules;
  bool isShowingReturn = false;
  TrainSchedule? selectedDepartureSchedule;
  TrainSchedule? selectedReturnSchedule;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    departureSchedules = TrainScheduleService.getSchedules(
      widget.departureStation,
      widget.arrivalStation,
      widget.departureDate,
    );
    if (widget.isRoundTrip && widget.returnDate != null) {
      returnSchedules = TrainScheduleService.getSchedules(
        widget.arrivalStation,
        widget.departureStation,
        widget.returnDate!,
      );
    } else {
      returnSchedules = [];
    }
  }

  void _selectSchedule(TrainSchedule schedule, bool isReturn) {
    setState(() {
      if (isReturn) {
        selectedReturnSchedule = schedule;
      } else {
        selectedDepartureSchedule = schedule;
      }
    });

    if (widget.isRoundTrip && !isReturn) {
      // 출발편 선택 후 도착편 선택으로 전환
      setState(() {
        isShowingReturn = true;
      });
    } else {
      // 도착편 선택 완료 또는 편도 여정
      _navigateToSeatSelection();
    }
  }

  void _navigateToSeatSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatPage(
          widget.departureStation,
          widget.arrivalStation,
          widget.adultCount,
          widget.childCount,
          widget.seniorCount,
          widget.isRoundTrip,
          selectedDate: widget.departureDate,
          departureTime: selectedDepartureSchedule!.departureTime,
          arrivalTime: selectedDepartureSchedule!.arrivalTime,
          trainNumber: selectedDepartureSchedule!.trainNumber,
          isReturn: false,
          returnSchedule: selectedReturnSchedule,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.isRoundTrip ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('열차 시간표'),
          bottom: TabBar(
            tabs: [
              Tab(text: '출발편'),
              if (widget.isRoundTrip) Tab(text: '도착편'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScheduleList(departureSchedules, false),
            if (widget.isRoundTrip) _buildScheduleList(returnSchedules, true),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<TrainSchedule> schedules, bool isReturn) {
    if (schedules.isEmpty) {
      return Center(
        child: Text('해당 날짜에 스케줄이 없습니다.'),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        TrainSchedule schedule = schedules[index];
        Duration duration =
            schedule.arrivalTime.difference(schedule.departureTime);
        String durationStr =
            '${duration.inHours}시간 ${duration.inMinutes % 60}분';

        return ListTile(
          title: Text('${schedule.trainNumber}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3),
              Text(
                  '출발: ${DateFormat('HH:mm').format(schedule.departureTime)}, 도착: ${DateFormat('HH:mm').format(schedule.arrivalTime)} 소요시간: $durationStr'),
            ],
          ),
          onTap: () => _selectSchedule(schedule, isReturn),
        );
      },
    );
  }
}

class TrainSchedule {
  final String trainNumber;
  final String departureStation;
  final String arrivalStation;
  final DateTime departureTime;
  final DateTime arrivalTime;

  TrainSchedule({
    required this.trainNumber,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
  });
}

class TrainScheduleService {
  static final List<String> stations = [
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
    '부산'
  ];

  static T? firstWhereOrNull<T>(Iterable<T> iterable, bool Function(T) test) {
    for (var element in iterable) {
      if (test(element)) return element;
    }
    return null;
  }

  static int calculateTravelTime(String departure, String arrival) {
    int totalTime = 0;
    String currentStation = departure;

    while (currentStation != arrival) {
      Map<String, int>? nextStations = travelTimes[currentStation];
      if (nextStations == null) break;

      String? nextStation = firstWhereOrNull(
        nextStations.keys,
        (station) =>
            stations.indexOf(station) > stations.indexOf(currentStation) &&
            stations.indexOf(station) <= stations.indexOf(arrival),
      );

      if (nextStation == null) break;

      totalTime += nextStations[nextStation]!;
      currentStation = nextStation;
    }

    return totalTime;
  }

  static final Map<String, Map<String, int>> travelTimes = {
    '수서': {'동탄': 15, '평택지제': 25},
    '동탄': {'평택지제': 10, '천안아산': 15},
    '평택지제': {'천안아산': 25, '오송': 15},
    '천안아산': {'오송': 10, '대전': 15},
    '오송': {'대전': 30, '김천구미': 30},
    '대전': {'김천구미': 25, '동대구': 25},
    '김천구미': {'동대구': 20, '경주': 15},
    '동대구': {'경주': 15, '울산': 30},
    '경주': {'울산': 30, '부산': 45},
    '울산': {'부산': 15}
  };

  static List<TrainSchedule> getSchedules(
      String departure, String arrival, DateTime date) {
    List<TrainSchedule> schedules = [];
    int travelTime = calculateTravelTime(departure, arrival);

    if (travelTime == 0) {
      return schedules;
    }

    // 06:00부터 22:00까지 1시간 간격으로 열차 스케줄 생성
    for (int hour = 6; hour <= 22; hour++) {
      DateTime depTime = DateTime(date.year, date.month, date.day, hour, 0);
      DateTime arrTime = depTime.add(Duration(minutes: travelTime));

      schedules.add(TrainSchedule(
        departureStation: departure,
        arrivalStation: arrival,
        departureTime: depTime,
        arrivalTime: arrTime,
        trainNumber: 'KTX${100 + schedules.length}',
      ));
    }

    return schedules;
  }

  static List<String> getStations() {
    return stations;
  }

  static int getTotalTravelTime() {
    return calculateTravelTime('수서', '부산');
  }
}
