import 'package:flutter/material.dart';
import 'station_list.dart';
import 'passenger_selection.dart';
import 'train_schedule.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const HomePage({
    Key? key,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? departureStation;
  String? arrivalStation;
  bool isRoundTrip = false;
  int adultCount = 1;
  int childCount = 0;
  int seniorCount = 0;
  DateTime? departureDate;
  DateTime? returnDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      departureStation;
      arrivalStation;
      departureDate = DateTime.now();
      returnDate = DateTime.now().add(const Duration(days: 1));
      adultCount = 1;
      childCount = 0;
      seniorCount = 0;
      isRoundTrip = false;
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CountryFlag.fromCountryCode(
                  'KR',
                  height: 24,
                  width: 40,
                ),
                title: const Text('한국어'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('ko'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CountryFlag.fromCountryCode(
                  'GB',
                  height: 24,
                  width: 40,
                ),
                title: const Text('English'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CountryFlag.fromCountryCode(
                  'JP',
                  height: 24,
                  width: 40,
                ),
                title: const Text('日本語'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('ja'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CountryFlag.fromCountryCode(
                  'CN',
                  height: 24,
                  width: 40,
                ),
                title: const Text('中文'),
                onTap: () {
                  widget.onLanguageChanged(const Locale('zh'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('K-Rail 간편 서비스'),
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 162, 50, 181),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    // 승차권 예매 탭
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('승차권 예매'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Convenient Booking',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    // 승차권 관리 탭
                    _buildTabItem(context, Icons.article, '승차권 관리'),
                    // 열차위치 확인 탭
                    _buildTabItem(context, Icons.location_on, '열차위치 확인'),
                    // 언어 선택 탭
                    _buildTabItem(context, Icons.language, 'Language',
                        onTap: _showLanguageDialog),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            _buildDateSelector(),
                            Divider(height: 30),
                            _buildStationSelector(),
                            Divider(height: 30),
                            _buildPassengerAndTripTypeSelector(),
                            SizedBox(height: 20),
                            _buildBookButton(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('더보기'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 18),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _buildLogoContainer(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).translate('날짜 선택'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildDateButton(
                    AppLocalizations.of(context).translate('가는 날'),
                    departureDate, (picked) {
                  setState(() {
                    departureDate = picked;
                    // 가는 날이 오는 날보다 늦으면 오는 날을 null로 설정
                    if (isRoundTrip &&
                        returnDate != null &&
                        picked!.isAfter(returnDate!)) {
                      returnDate = null;
                    }
                  });
                }),
              ),
            ),
            if (isRoundTrip) ...[
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildDateButton(
                      AppLocalizations.of(context).translate('오는 날'),
                      returnDate, (picked) {
                    setState(() {
                      if (departureDate != null &&
                          !picked!.isBefore(departureDate!)) {
                        returnDate = picked;
                      } else {
                        // 오는 날이 가는 날보다 빠르면 경고 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)
                                  .translate('오는 날은 가는 날 이후여야 합니다.'),
                              style: TextStyle(
                                fontSize: 18, // 글자 크기를 키웁니다
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800] // 다크 테마일 때의 배경색
                                    : Colors.grey[200], // 라이트 테마일 때의 배경색
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(16),
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            duration: Duration(seconds: 4),
                            action: SnackBarAction(
                              label:
                                  AppLocalizations.of(context).translate('확인'),
                              textColor:
                                  Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    });
                  }),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTabItem(BuildContext context, IconData icon, String text,
      {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(8), // 모든 방향으로 패딩 추가
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Text(
                      text == 'Language'
                          ? text
                          : AppLocalizations.of(context).translate(text),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10, // 폰트 크기를 약간 줄임
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(
      String label, DateTime? date, Function(DateTime?) onPicked) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 365)),
          locale: Localizations.localeOf(context),
        );
        if (picked != null && picked != date) {
          onPicked(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: date != null ? Colors.white : null, // 날짜 선택 시 흰색 배경
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date == null ? label : DateFormat(' yyyy-MM-dd').format(date),
          style: TextStyle(
            fontSize: 16,
            color: date == null
                ? Colors.grey // 날짜 미선택 시 회색
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.black87 // 다크 모드에서 날짜 선택 시 진한 검정
                    : Colors.black87, // 라이트 모드에서 날짜 선택 시 진한 검정
          ),
        ),
      ),
    );
  }

  Widget _buildStationSelector() {
    return Container(
      height: 150, // 높이를 200에서 150으로 줄임
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10, // 위치를 위로 조정
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = departureStation;
                    departureStation = arrivalStation;
                    arrivalStation = temp;
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildStationButton(
                    AppLocalizations.of(context).translate('출발역'),
                    departureStation,
                    arrivalStation),
              ),
              Container(
                width: 2,
                height: 40, // 높이를 50에서 40으로 줄임
                color: Colors.grey[400],
              ),
              Expanded(
                child: _buildStationButton(
                    AppLocalizations.of(context).translate('도착역'),
                    arrivalStation,
                    departureStation),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationButton(
      String label, String? station, String? otherStation) {
    return GestureDetector(
      onTap: () async {
        final selectedStation = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StationListPage(selectedStation: otherStation),
          ),
        );
        if (selectedStation != null) {
          setState(() {
            if (label == AppLocalizations.of(context).translate('출발역')) {
              departureStation = selectedStation;
            } else {
              arrivalStation = selectedStation;
            }
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).translate(label),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Container(
            height: 60,
            width: 150,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Center(
              child: AutoSizeText(
                station != null
                    ? AppLocalizations.of(context).translate(station)
                    : AppLocalizations.of(context).translate('선택'),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2, // 줄 간격 조정
                  color: station != null ? Colors.black : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 18,
                stepGranularity: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPassengerAndTripTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PassengerSelectionPage(
                  adultCount: adultCount,
                  childCount: childCount,
                  seniorCount: seniorCount,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                adultCount = result['adult'];
                childCount = result['child'];
                seniorCount = result['senior'];
              });
            }
          },
          child: Text(
            _buildPassengerSummary(),
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).translate('편도')),
            SizedBox(width: 20),
            Switch(
              value: isRoundTrip,
              onChanged: (value) {
                setState(() {
                  isRoundTrip = value;
                  if (isRoundTrip) {
                    returnDate = departureDate?.add(Duration(days: 1));
                  }
                });
              },
            ),
            SizedBox(width: 20),
            Text(AppLocalizations.of(context).translate('왕복')),
          ],
        ),
      ],
    );
  }

  String _buildPassengerSummary() {
    List<String> parts = [];
    if (adultCount > 0) {
      parts.add('${AppLocalizations.of(context).translate('어른')} $adultCount');
    }
    if (childCount > 0) {
      parts.add('${AppLocalizations.of(context).translate('어린이')} $childCount');
    }
    if (seniorCount > 0) {
      parts.add('${AppLocalizations.of(context).translate('경로')} $seniorCount');
    }
    return '${AppLocalizations.of(context).translate('인원 선택')}: ${parts.join(', ')}';
  }

  Widget _buildBookButton() {
    bool canBook = departureStation != null &&
        arrivalStation != null &&
        departureDate != null &&
        (!isRoundTrip || (isRoundTrip && returnDate != null));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canBook
            ? () {
                if (isRoundTrip && returnDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('return_date_error')),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainSchedulePage(
                      departureStation: departureStation!,
                      arrivalStation: arrivalStation!,
                      departureDate: departureDate!,
                      returnDate: isRoundTrip ? returnDate : null,
                      adultCount: adultCount,
                      childCount: childCount,
                      seniorCount: seniorCount,
                      isRoundTrip: isRoundTrip,
                      selectedLocale:
                          Localizations.localeOf(context), // 현재 선택된 언어 전달
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text(
            AppLocalizations.of(context).translate('예매하기'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: Image.asset(
          'asset/KRAIL_LOGO.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
