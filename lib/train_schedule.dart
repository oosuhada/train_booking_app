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
  });

  @override
  _TrainSchedulePageState createState() => _TrainSchedulePageState();
}

class _TrainSchedulePageState extends State<TrainSchedulePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<TrainSchedule> departureSchedules;
  late List<TrainSchedule> returnSchedules;
  bool isShowingReturn = false;
  TrainSchedule? selectedDepartureSchedule;
  TrainSchedule? selectedReturnSchedule;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.isRoundTrip ? 2 : 1, vsync: this);
    _loadSchedules();
  }

  void _loadSchedules() {
    Map<String, List<TrainSchedule>> allSchedules =
        TrainScheduleService.getSchedules(
      widget.departureStation,
      widget.arrivalStation,
      widget.departureDate,
      widget.isRoundTrip ? (widget.returnDate) : null,
    );
    departureSchedules = allSchedules['departure']!;
    if (widget.isRoundTrip) {
      returnSchedules = allSchedules['return']!;
    }
  }

  void _selectSchedule(TrainSchedule schedule, bool isReturn) {
    setState(() {
      if (isReturn) {
        // 같은 스케줄을 다시 클릭한 경우 선택 해제
        if (selectedReturnSchedule?.trainNumber == schedule.trainNumber) {
          selectedReturnSchedule = null;
        } else {
          selectedReturnSchedule = schedule;
        }
      } else {
        // 같은 스케줄을 다시 클릭한 경우 선택 해제
        if (selectedDepartureSchedule?.trainNumber == schedule.trainNumber) {
          selectedDepartureSchedule = null;
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
          selectedDepartureDate:
              isReturn ? widget.returnDate : widget.departureDate,
          selectedReturnDate: widget.returnDate,
          departureSchedule: selectedDepartureSchedule!,
          returnSchedule: selectedReturnSchedule,
          departureTime: currentSchedule.departureTime,
          departureArrivalTime: currentSchedule.arrivalTime,
          returnDepartureTime: isReturn ? currentSchedule.departureTime : null,
          returnArrivalTime: isReturn ? currentSchedule.arrivalTime : null,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: _buildScheduleList(departureSchedules, false),
          ),
          if (widget.isRoundTrip)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: _buildScheduleList(returnSchedules, true),
            ),
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
              child: Text('좌석 선택하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
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
          color: isSelected
              ? Colors.purple //선택되었을때 보라색 UI
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white // 다크 모드일때 흰색 UI
                  : Colors.black, // 라이트 모드일때 검은색 UI
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

  static Map<String, List<TrainSchedule>> getSchedules(
    String departure,
    String arrival,
    DateTime departureDate,
    DateTime? returnDate,
  ) {
    Map<String, List<TrainSchedule>> allSchedules = {
      'departure': [],
      'return': [],
    };

    // 출발편 스케줄 생성
    allSchedules['departure'] =
        _generateSchedules(departure, arrival, departureDate, false);

    // 도착편 스케줄 생성 (왕복인 경우)
    if (returnDate != null) {
      allSchedules['return'] =
          _generateSchedules(arrival, departure, returnDate, true);
    }

    return allSchedules;
  }

  static List<TrainSchedule> _generateSchedules(
      String departure, String arrival, DateTime date, bool isReturn) {
    List<TrainSchedule> schedules = [];
    int travelTime = calculateTravelTime(departure, arrival);
    if (travelTime == 0) {
      return schedules;
    }

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
      int trainNumber =
          isReturn ? 200 + schedules.length : 100 + schedules.length;
      schedules.add(TrainSchedule(
        departureStation: departure,
        arrivalStation: arrival,
        departureTime: depTime,
        arrivalTime: arrTime,
        trainNumber: 'KTX$trainNumber',
      ));
    }

    return schedules;
  }
}
