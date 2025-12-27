import 'package:flutter/material.dart';
import 'station_list.dart';
import 'passenger_selection.dart';
import 'train_schedule.dart';
import 'package:intl/intl.dart';
import 'app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'v2/v2_glass.dart';

class HomePage extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const HomePage({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
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
      departureStation = '수서';
      arrivalStation = '부산';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          AppGlassToolbar(
            title: 'K-Rail',
            trailing: IconButton(
              tooltip: 'Language',
              onPressed: _showLanguageDialog,
              icon: const Icon(Icons.language_rounded),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            const Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'K-RAIL · DEMO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context).translate('승차권 예매'),
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '수서에서 부산까지, 원하는 여정을 빠르게 찾아보세요.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '여정 선택',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          isRoundTrip
                                              ? AppLocalizations.of(context)
                                                  .translate('왕복')
                                              : AppLocalizations.of(context)
                                                  .translate('편도'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _buildStationSelector(),
                                  const Divider(height: 32),
                                  _buildDateSelector(),
                                  const Divider(height: 32),
                                  _buildPassengerAndTripTypeSelector(),
                                  const SizedBox(height: 20),
                                  _buildBookButton(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            '빠른 서비스',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildQuickService(
                                Icons.confirmation_number_outlined,
                                AppLocalizations.of(context)
                                    .translate('승차권 관리'),
                              ),
                              const SizedBox(width: 10),
                              _buildQuickService(
                                Icons.train_outlined,
                                AppLocalizations.of(context)
                                    .translate('열차위치 확인'),
                              ),
                              const SizedBox(width: 10),
                              _buildQuickService(
                                Icons.language_rounded,
                                'Language',
                                onTap: _showLanguageDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'asset/KRAIL_LOGO.jpg',
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'K-Rail mobile booking',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '시간표 · 좌석 선택 · 결제까지 이어지는 데모 플로우',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('날짜 선택'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                  AppLocalizations.of(context).translate('가는 날'), departureDate,
                  (picked) {
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
            if (isRoundTrip) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateButton(
                    AppLocalizations.of(context).translate('오는 날'), returnDate,
                    (picked) {
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
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context).translate('확인'),
                            textColor: Theme.of(context).colorScheme.secondary,
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
            ],
          ],
        ),
      ],
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
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: Localizations.localeOf(context),
        );
        if (picked != null && picked != date) {
          onPicked(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          // 다크모드 대응을 위한 배경색 설정
          color: date != null
              ? Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800] // 다크모드에서 선택 시 어두운 회색
                  : Colors.white // 라이트모드에서 선택 시 흰색
              : null,
          border: Border.all(
            // 테두리 색상도 다크모드에 맞게 조정
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[600]! // 다크모드에서의 테두리
                : Colors.grey, // 라이트모드에서의 테두리
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? '선택' : DateFormat('MM월 dd일').format(date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  Widget _buildStationSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildStationButton(
            AppLocalizations.of(context).translate('출발역'),
            departureStation,
            arrivalStation,
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: '출발/도착 바꾸기',
          icon: const Icon(Icons.swap_horiz_rounded),
          onPressed: () {
            setState(() {
              final temp = departureStation;
              departureStation = arrivalStation;
              arrivalStation = temp;
            });
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStationButton(
            AppLocalizations.of(context).translate('도착역'),
            arrivalStation,
            departureStation,
          ),
        ),
      ],
    );
  }

  Widget _buildStationButton(
      String label, String? station, String? otherStation) {
    return AppGlassSurface(
      semanticLabel: '$label ${station ?? '선택'}',
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
      borderRadius: BorderRadius.circular(20),
      blurSigma: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).translate(label),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 7),
          AutoSizeText(
            station != null
                ? AppLocalizations.of(context).translate(station)
                : AppLocalizations.of(context).translate('선택'),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            minFontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerAndTripTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppGlassSurface(
          semanticLabel: _buildPassengerSummary(),
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
          borderRadius: BorderRadius.circular(18),
          blurSigma: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _buildPassengerSummary(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 220,
          child: AppGlassSegmentedControl<bool>(
            values: const [false, true],
            selected: isRoundTrip,
            labelBuilder: (value) =>
                AppLocalizations.of(context).translate(value ? '왕복' : '편도'),
            onSelected: (value) {
              setState(() {
                isRoundTrip = value;
                if (value) {
                  returnDate ??= departureDate?.add(const Duration(days: 1));
                }
              });
            },
          ),
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
      child: FilledButton.icon(
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
        icon: const Icon(Icons.search_rounded),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            AppLocalizations.of(context).translate('예매하기'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickService(IconData icon, String label,
      {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
