import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'seat_page.dart';

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

class _TrainSchedulePageState extends State<TrainSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<TrainSchedule> departureSchedules;
  late List<TrainSchedule> returnSchedules;
  bool isShowingReturn = false;
  TrainSchedule? selectedDepartureSchedule;
  TrainSchedule? selectedReturnSchedule;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isRoundTrip ? 2 : 1,
      vsync: this,
    );
    _loadSchedules();
  }

  void _loadSchedules() {
    // 가상의 스케줄 생성
    final baseTime = DateTime(
      widget.departureDate.year,
      widget.departureDate.month,
      widget.departureDate.day,
      6, // 첫차 시간을 06:00로 설정
      0,
    );

    departureSchedules = [];

    // 06:00부터 22:00까지 1시간 간격으로 스케줄 생성
    for (int i = 0; i < 17; i++) {
      final departureTime = baseTime.add(Duration(hours: i));
      final travelMinutes = TrainScheduleService.calculateTravelTime(
        widget.departureStation,
        widget.arrivalStation,
      );
      final arrivalTime = departureTime.add(Duration(minutes: travelMinutes));

      departureSchedules.add(
        TrainSchedule(
          trainNumber: 'KTX ${100 + i}',
          departureStation: widget.departureStation,
          arrivalStation: widget.arrivalStation,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
        ),
      );
    }

    // 왕복인 경우 돌아오는 스케줄도 생성
    if (widget.isRoundTrip && widget.returnDate != null) {
      final baseReturnTime = DateTime(
        widget.returnDate!.year,
        widget.returnDate!.month,
        widget.returnDate!.day,
        6,
        0,
      );

      returnSchedules = [];

      for (int i = 0; i < 17; i++) {
        final departureTime = baseReturnTime.add(Duration(hours: i));
        final travelMinutes = TrainScheduleService.calculateTravelTime(
          widget.arrivalStation,
          widget.departureStation,
        );
        final arrivalTime = departureTime.add(Duration(minutes: travelMinutes));

        returnSchedules.add(
          TrainSchedule(
            trainNumber: 'KTX ${200 + i}',
            departureStation: widget.arrivalStation,
            arrivalStation: widget.departureStation,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
          ),
        );
      }
    } else {
      returnSchedules = [];
    }
  }

  void _selectSchedule(TrainSchedule schedule, bool isReturn) {
    setState(() {
      if (isReturn) {
        selectedReturnSchedule = schedule;
        // 도착편 선택 후 버튼으로 좌석 선택 진행
      } else {
        selectedDepartureSchedule = schedule;
        if (!widget.isRoundTrip) {
          _startSeatSelection();
        } else {
          // 왕복인 경우 도착편 탭으로 전환
          isShowingReturn = true;
          _tabController.animateTo(1);
        }
      }
    });
  }

// 좌석 선택 시작 메서드 추가
  void _startSeatSelection() {
    if (widget.isRoundTrip && selectedReturnSchedule == null) return;

    // 출발편 좌석 선택부터 시작
    _navigateToSeatSelection(isReturn: false);
  }

  void _navigateToSeatSelection({required bool isReturn}) {
    TrainSchedule currentSchedule =
        isReturn ? selectedReturnSchedule! : selectedDepartureSchedule!;

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
          selectedDate: widget.departureDate,
          departureTime: currentSchedule.departureTime,
          arrivalTime: currentSchedule.arrivalTime,
          trainNumber: currentSchedule.trainNumber,
          departureSchedule: selectedDepartureSchedule!,
          returnSchedule: selectedReturnSchedule,
          selectedSchedule: currentSchedule,
          selectedDepartureDate: widget.departureDate,
          selectedReturnDate: widget.returnDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('열차 시간표'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '출발편'),
            if (widget.isRoundTrip) Tab(text: '도착편'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleList(departureSchedules, false),
          if (widget.isRoundTrip) _buildScheduleList(returnSchedules, true),
        ],
      ),
    );
  }

  // 도착편 선택 후 좌석 선택 버튼 위젯
  Widget _buildScheduleList(List<TrainSchedule> schedules, bool isReturn) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) =>
                _buildScheduleItem(schedules[index], isReturn),
          ),
        ),
        if (isReturn && selectedReturnSchedule != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _startSeatSelection,
              child: Text('좌석 선택하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleItem(TrainSchedule schedule, bool isReturn) {
    Duration duration = schedule.arrivalTime.difference(schedule.departureTime);
    String durationStr = '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    bool isSelected = isReturn
        ? selectedReturnSchedule?.trainNumber == schedule.trainNumber
        : selectedDepartureSchedule?.trainNumber == schedule.trainNumber;

    return ListTile(
      title: Text(
        schedule.trainNumber,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.purple : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 3),
          Text('출발: ${DateFormat('HH:mm').format(schedule.departureTime)}, '
              '도착: ${DateFormat('HH:mm').format(schedule.arrivalTime)} '
              '소요시간: $durationStr'),
        ],
      ),
      onTap: () => _selectSchedule(schedule, isReturn),
      tileColor: isSelected ? Colors.purple.withOpacity(0.1) : null,
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
    bool isReverse = stations.indexOf(departure) > stations.indexOf(arrival);

    while (currentStation != arrival) {
      Map<String, int>? nextStations = travelTimes[currentStation];
      if (nextStations == null) break;

      String? nextStation;
      if (isReverse) {
        nextStation = firstWhereOrNull(
          nextStations.keys,
          (station) =>
              stations.indexOf(station) < stations.indexOf(currentStation) &&
              stations.indexOf(station) >= stations.indexOf(arrival),
        );
      } else {
        nextStation = firstWhereOrNull(
          nextStations.keys,
          (station) =>
              stations.indexOf(station) > stations.indexOf(currentStation) &&
              stations.indexOf(station) <= stations.indexOf(arrival),
        );
      }

      if (nextStation == null) break;
      totalTime += nextStations[nextStation]!;
      currentStation = nextStation;
    }

    return totalTime;
  }

  static final Map<String, Map<String, int>> travelTimes = {
    '수서': {
      '동탄': 15,
      '평택지제': 25,
      '천안아산': 40,
      '오송': 50,
      '대전': 80,
      '김천구미': 105,
      '동대구': 130,
      '경주': 145,
      '울산': 175,
      '부산': 190
    },
    '동탄': {
      '수서': 15,
      '평택지제': 10,
      '천안아산': 25,
      '오송': 35,
      '대전': 65,
      '김천구미': 90,
      '동대구': 115,
      '경주': 130,
      '울산': 160,
      '부산': 175
    },
    '평택지제': {
      '수서': 25,
      '동탄': 10,
      '천안아산': 15,
      '오송': 25,
      '대전': 55,
      '김천구미': 80,
      '동대구': 105,
      '경주': 120,
      '울산': 150,
      '부산': 165
    },
    '천안아산': {
      '수서': 40,
      '동탄': 25,
      '평택지제': 15,
      '오송': 10,
      '대전': 40,
      '김천구미': 65,
      '동대구': 90,
      '경주': 105,
      '울산': 135,
      '부산': 150
    },
    '오송': {
      '수서': 50,
      '동탄': 35,
      '평택지제': 25,
      '천안아산': 10,
      '대전': 30,
      '김천구미': 55,
      '동대구': 80,
      '경주': 95,
      '울산': 125,
      '부산': 140
    },
    '대전': {
      '수서': 80,
      '동탄': 65,
      '평택지제': 55,
      '천안아산': 40,
      '오송': 30,
      '김천구미': 25,
      '동대구': 50,
      '경주': 65,
      '울산': 95,
      '부산': 110
    },
    '김천구미': {
      '수서': 105,
      '동탄': 90,
      '평택지제': 80,
      '천안아산': 65,
      '오송': 55,
      '대전': 25,
      '동대구': 25,
      '경주': 40,
      '울산': 70,
      '부산': 85
    },
    '동대구': {
      '수서': 130,
      '동탄': 115,
      '평택지제': 105,
      '천안아산': 90,
      '오송': 80,
      '대전': 50,
      '김천구미': 25,
      '경주': 15,
      '울산': 45,
      '부산': 60
    },
    '경주': {
      '수서': 145,
      '동탄': 130,
      '평택지제': 120,
      '천안아산': 105,
      '오송': 95,
      '대전': 65,
      '김천구미': 40,
      '동대구': 15,
      '울산': 30,
      '부산': 45
    },
    '울산': {
      '수서': 175,
      '동탄': 160,
      '평택지제': 150,
      '천안아산': 135,
      '오송': 125,
      '대전': 95,
      '김천구미': 70,
      '동대구': 45,
      '경주': 30,
      '부산': 15
    },
    '부산': {
      '수서': 190,
      '동탄': 175,
      '평택지제': 165,
      '천안아산': 150,
      '오송': 140,
      '대전': 110,
      '김천구미': 85,
      '동대구': 60,
      '경주': 45,
      '울산': 15
    }
  };

  static List<TrainSchedule> getSchedules(
      String departure, String arrival, DateTime date) {
    List<TrainSchedule> schedules = [];
    int travelTime = calculateTravelTime(departure, arrival);

    if (travelTime == 0) {
      return schedules;
    }

    // 현재 시간 이후의 스케줄만 생성
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // 선택한 날짜가 오늘 이전이면 오늘 날짜로 설정
    if (date.isBefore(today)) {
      date = today;
    }

    // 06:00부터 22:00까지 1시간 간격으로 열차 스케줄 생성
    for (int hour = 6; hour <= 22; hour++) {
      DateTime depTime = DateTime(date.year, date.month, date.day, hour, 0);

      // 오늘 날짜일 경우 현재 시간 이후의 스케줄만 생성
      if (date.isAtSameMomentAs(today) && depTime.isBefore(now)) {
        continue;
      }

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
