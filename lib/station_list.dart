import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'v2/v2_glass.dart';

class StationListPage extends StatelessWidget {
  final List<String> stations = [
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
  final String? selectedStation;

  StationListPage({super.key, this.selectedStation});

  @override
  Widget build(BuildContext context) {
    final availableStations =
        stations.where((station) => station != selectedStation).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          AppGlassToolbar(
            title: AppLocalizations.of(context).translate('역 선택'),
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: availableStations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final station = availableStations[index];

                return Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, station),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.train_outlined,
                              color: colorScheme.onPrimaryContainer,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).translate(station),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 가격 정보를 저장하는 클래스
class PriceInfo {
  static Map<String, Map<String, int>> prices = {
    '수서': {
      '동탄': 8000,
      '평택지제': 15000,
      '천안아산': 23000,
      '오송': 28000,
      '대전': 35000,
      '김천구미': 48000,
      '동대구': 55000,
      '경주': 65000,
      '울산': 70000,
      '부산': 80000,
    },
    '동탄': {
      '평택지제': 8000,
      '천안아산': 15000,
      '오송': 20000,
      '대전': 28000,
      '김천구미': 40000,
      '동대구': 48000,
      '경주': 58000,
      '울산': 63000,
      '부산': 73000,
    },
    '평택지제': {
      '천안아산': 8000,
      '오송': 13000,
      '대전': 20000,
      '김천구미': 33000,
      '동대구': 40000,
      '경주': 50000,
      '울산': 55000,
      '부산': 65000,
    },
    '천안아산': {
      '오송': 6000,
      '대전': 13000,
      '김천구미': 25000,
      '동대구': 33000,
      '경주': 43000,
      '울산': 48000,
      '부산': 58000,
    },
    '오송': {
      '대전': 8000,
      '김천구미': 20000,
      '동대구': 28000,
      '경주': 38000,
      '울산': 43000,
      '부산': 53000,
    },
    '대전': {
      '김천구미': 13000,
      '동대구': 20000,
      '경주': 30000,
      '울산': 35000,
      '부산': 45000,
    },
    '김천구미': {
      '동대구': 8000,
      '경주': 18000,
      '울산': 23000,
      '부산': 33000,
    },
    '동대구': {
      '경주': 10000,
      '울산': 15000,
      '부산': 25000,
    },
    '경주': {
      '울산': 6000,
      '부산': 15000,
    },
    '울산': {
      '부산': 10000,
    },
  };
  final int originalPrice;
  final int discountedPrice;
  final String discountType;

  PriceInfo({
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountType,
  });

  static int getPrice(String departure, String arrival) {
    if (prices.containsKey(departure) &&
        prices[departure]!.containsKey(arrival)) {
      return prices[departure]![arrival]!;
    } else if (prices.containsKey(arrival) &&
        prices[arrival]!.containsKey(departure)) {
      return prices[arrival]![departure]!;
    }
    return 0; // 가격 정보가 없는 경우
  }
}

class PriceCalculator {
  static PriceInfo calculatePrice(
    String departure,
    String arrival,
    bool isRoundTrip,
    int adultCount,
    int childCount,
    int seniorCount,
    String? coupon,
    BuildContext context,
  ) {
    int basePrice = PriceInfo.getPrice(departure, arrival);
    int totalPrice = 0;
    totalPrice += basePrice * adultCount;
    totalPrice += (basePrice * 0.5).round() * childCount;
    totalPrice += (basePrice * 0.7).round() * seniorCount;
    if (isRoundTrip) {
      totalPrice *= 2;
    }

    int originalPrice = totalPrice;
    String discountType = AppLocalizations.of(context).translate('할인 없음');

    if (coupon != null) {
      switch (coupon) {
        case '10% 할인':
          totalPrice = (totalPrice * 0.9).round();
          discountType =
              '${AppLocalizations.of(context).translate('10% 할인')} ${AppLocalizations.of(context).translate('쿠폰')}';
          break;
        case '15% 할인':
          totalPrice = (totalPrice * 0.85).round();
          discountType =
              '${AppLocalizations.of(context).translate('15% 할인')} ${AppLocalizations.of(context).translate('쿠폰')}';
          break;
        case '20% 할인':
          totalPrice = (totalPrice * 0.8).round();
          discountType =
              '${AppLocalizations.of(context).translate('20% 할인')} ${AppLocalizations.of(context).translate('쿠폰')}';
          break;
      }
    }

    return PriceInfo(
      originalPrice: originalPrice,
      discountedPrice: totalPrice,
      discountType: discountType,
    );
  }

  static Map<String, int> getPriceDetails(
    String departure,
    String arrival,
    bool isRoundTrip,
    int adultCount,
    int childCount,
    int seniorCount,
  ) {
    int basePrice = PriceInfo.getPrice(departure, arrival);
    int adultPrice = basePrice * adultCount;
    int childPrice = (basePrice * 0.5).round() * childCount;
    int seniorPrice = (basePrice * 0.7).round() * seniorCount;
    int totalPrice = adultPrice + childPrice + seniorPrice;

    if (isRoundTrip) {
      adultPrice *= 2;
      childPrice *= 2;
      seniorPrice *= 2;
      totalPrice *= 2;
    }

    return {
      'adult': adultPrice,
      'child': childPrice,
      'senior': seniorPrice,
      'total': totalPrice,
    };
  }
}
