import 'package:flutter/material.dart';

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

  StationListPage({this.selectedStation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('역 선택')),
      body: ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          if (stations[index] == selectedStation) {
            return Container(); // 이미 선택된 역은 표시하지 않음
          }
          return ListTile(
            title: Text(stations[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context, stations[index]);
            },
          );
        },
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

class PriceCalculateInfo {
  static int getPrice(String departure, String arrival, bool isRoundTrip,
      int adultCount, int childCount, int seniorCount) {
    int basePrice = PriceInfo.getPrice(departure, arrival);

    // 성인 가격 계산
    int adultPrice = basePrice * adultCount;

    // 어린이 가격 계산 (50% 할인)
    int childPrice = (basePrice * 0.5).round() * childCount;

    // 노약자 가격 계산 (30% 할인)
    int seniorPrice = (basePrice * 0.7).round() * seniorCount;

    // 총 가격 계산
    int totalPrice = adultPrice + childPrice + seniorPrice;

    // 왕복인 경우 2배
    if (isRoundTrip) {
      totalPrice *= 2;
    }

    return totalPrice;
  }

  // 각 승객 유형별 가격을 개별적으로 계산하는 메소드 (필요시 사용)
  static Map<String, int> getPriceDetails(String departure, String arrival,
      bool isRoundTrip, int adultCount, int childCount, int seniorCount) {
    int basePrice = PriceInfo.getPrice(departure, arrival);

    int adultPrice = basePrice * adultCount;
    int childPrice = (basePrice * 0.5).round() * childCount;
    int seniorPrice = (basePrice * 0.7).round() * seniorCount;

    if (isRoundTrip) {
      adultPrice *= 2;
      childPrice *= 2;
      seniorPrice *= 2;
    }

    return {
      'adult': adultPrice,
      'child': childPrice,
      'senior': seniorPrice,
      'total': adultPrice + childPrice + seniorPrice,
    };
  }
}
