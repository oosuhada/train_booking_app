import 'package:flutter/material.dart';

// main.dart supportedLocales: 에 추후 추가하는 언어 추가해야 작동함!
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class AppLocalizations {
  final Locale locale;
  static AppLocalizations? _current;

  AppLocalizations(this.locale) {
    _current = this;
  }

  // 안전한 싱글톤 접근자
  static AppLocalizations get current {
    if (_current == null) {
      _current = AppLocalizations(const Locale('ko')); // 기본값으로 한국어 설정
    }
    return _current!;
  }

  // context를 사용한 안전한 접근자
  static AppLocalizations of(BuildContext context) {
    try {
      final localizations =
          Localizations.of<AppLocalizations>(context, AppLocalizations);
      if (localizations != null) {
        return localizations;
      }
      // Localizations가 아직 초기화되지 않은 경우
      debugPrint(
          'Warning: Localizations not initialized, using default locale (ko)');
      return current;
    } catch (e) {
      debugPrint('Error accessing localizations: $e');
      return current;
    }
  }

  // 안전한 번역 메서드
  String translate(String key, {String? fallback}) {
    try {
      final languageCode = locale.languageCode;
      final translations =
          _localizedValues[languageCode] ?? _localizedValues['ko']!;
      return translations[key] ?? fallback ?? key;
    } catch (e) {
      debugPrint('Translation error for key "$key": $e');
      return fallback ?? key;
    }
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      '승차권 예매': '승차권 예매',
      'K-Rail 간편 서비스': 'K-Rail 간편 서비스',
      '승차권 관리': '승차권 관리',
      '열차위치 확인': '열차위치',
      '출발역': '출발역',
      '도착역': '도착역',
      '선택': '선택',
      '날짜 선택': '날짜 선택',
      '편도': '편도',
      '왕복': '왕복',
      '예매하기': '예매하기',
      '더보기': '더보기',
      '인원 선택': '인원 선택',
      '수서': '수서',
      '동탄': '동탄',
      '평택지제': '평택지제',
      '천안아산': '천안아산',
      '오송': '오송',
      '대전': '대전',
      '김천구미': '김천구미',
      '동대구': '동대구',
      '경주': '경주',
      '울산': '울산',
      '부산': '부산',
      '출발': '출발',
      '도착': '도착',
      '소요시간': '소요시간',
      '열차시간표': '열차시간표',
      '출발편': '출발편',
      '도착편': '도착편',
      '출발편 좌석 선택': '출발편 좌석 선택',
      '도착편 좌석 선택': '도착편 좌석 선택',
      '선택됨': '선택됨',
      '선택안됨': '선택안됨',
      '선택한 좌석': '선택한 좌석',
      '어른': '어른',
      '어린이': '어린이',
      '경로': '경로',
      '다음': '다음',
      '결제하기': '결제하기',
      '예약 정보': '예약 정보',
      '일정 정보': '일정 정보',
      '좌석 정보': '좌석 정보',
      '가격 정보': '가격 정보',
      '쿠폰 선택': '쿠폰 선택',
      '할인 유형': '할인 유형',
      '취소': '취소',
      '확인': '확인',
      '이전날': '이전날',
      '다음날': '다음날',
      '알림': '알림',
      '다음 열차가 없습니다.': '다음 열차가 없습니다.',
      '이전 열차가 없습니다.': '이전 열차가 없습니다.',
      '더 이전 날짜는 선택할 수 없습니다.': '더 이전 날짜는 선택할 수 없습니다.',
      '기본 편도 가격': '기본 편도 가격',
      '할인 전 가격': '할인 전 가격',
      '최종 가격': '최종 가격',
      '할인 없음': '할인 없음',
      '역 선택': '역 선택',
      '만 13세 이상': '만 13세 이상',
      '만 6세 ~ 만 12세': '만 6세 ~ 만 12세',
      '만 65세 이상': '만 65세 이상',
      '열차 시간표': '열차 시간표',
      '좌석 선택하기': '좌석 선택하기',
      '명': '명',
      '원': '원',
      '10% 할인': '10% 할인',
      '15% 할인': '15% 할인',
      '20% 할인': '20% 할인',
      '쿠폰': '쿠폰',
      '시간': '시간',
      '분': '분',
      '출발편 좌석': '출발편 좌석',
      '도착편 좌석': '도착편 좌석',
    },
    'en': {
      '승차권 예매': 'Book Ticket',
      'K-Rail 간편 서비스': 'K Rail Booking Service',
      '승차권 관리': 'Ticket Management',
      '열차위치 확인': 'Train Location',
      '출발역': 'Departure Station',
      '도착역': 'Arrival Station',
      '선택': 'Select',
      '날짜 선택': 'Select Date',
      '편도': 'One-way',
      '왕복': 'Round-trip',
      '예매하기': 'Book Now',
      '더보기': 'More Options',
      '인원 선택': 'Select Passengers',
      '수서': 'Suseo',
      '동탄': 'Dongtan',
      '평택지제': 'Pyeongtaek Jije',
      '천안아산': 'Cheonan Asan',
      '오송': 'Osong',
      '대전': 'Daejeon',
      '김천구미': 'Gimcheon Gumi',
      '동대구': 'Dongdaegu',
      '경주': 'Gyeongju',
      '울산': 'Ulsan',
      '부산': 'Busan',
      '출발': 'Departure',
      '도착': 'Arrival',
      '소요시간': 'Travel Time',
      '열차시간표': 'Train Schedule',
      '출발편': 'Departure Trip',
      '도착편': 'Arrival Trip',
      '출발편 좌석 선택': 'Select Departure Seat',
      '도착편 좌석 선택': 'Select Arrival Seat',
      '선택됨': 'Selected',
      '선택안됨': 'Not Selected',
      '선택한 좌석': 'Selected Seat',
      '어른': 'Adult',
      '어린이': 'Child',
      '경로': 'Senior',
      '다음': 'Next',
      '결제하기': 'Proceed to Payment',
      '예약 정보': 'Reservation Information',
      '일정 정보': 'Schedule Information',
      '좌석 정보': 'Seat Information',
      '가격 정보': 'Price Information',
      '쿠폰 선택': 'Select Coupon',
      '할인 유형': 'Discount Type',
      '취소': 'Cancel',
      '확인': 'Confirm',
      '이전날': 'Previous Day',
      '다음날': 'Next Day',
      '알림': 'Notification',
      '다음 열차가 없습니다.': 'No next train available.',
      '이전 열차가 없습니다.': 'No previous train available.',
      '더 이전 날짜는 선택할 수 없습니다.': 'Cannot select an earlier date.',
      '기본 편도 가격': 'Basic One-way Price',
      '할인 전 가격': 'Price before discount',
      '최종 가격': 'Final Price',
      '할인 없음': 'No discount',
      '역 선택': 'Station Selection',
      '만 13세 이상': 'Age 13 and above',
      '만 6세 ~ 만 12세': 'Age 6 to 12',
      '만 65세 이상': 'Age 65 and above',
      '열차 시간표': 'Train Schedule',
      '좌석 선택하기': 'Select Seats',
      '명': 'person',
      '원': 'won',
      '10% 할인': '10% Discount',
      '15% 할인': '15% Discount',
      '20% 할인': '20% Discount',
      '쿠폰': 'Coupon',
      '시간': 'hour',
      '분': 'min',
      '출발편 좌석': 'Departure Seats',
      '도착편 좌석': 'Return Seats',
    },
    'zh': {
      '승차권 예매': '购买车票',
      'K-Rail 간편 서비스': 'K Rail 便捷的火车订票服务',
      '승차권 관리': '车票管理',
      '열차위치 확인': '查看列车位置',
      '출발역': '出发站',
      '도착역': '到达站',
      '선택': '选择',
      '날짜 선택': '选择日期',
      '편도': '单程',
      '왕복': '往返',
      '예매하기': '预订',
      '더보기': '更多选项',
      '인원 선택': '选择乘客',
      '수서': '水西',
      '동탄': '东滩',
      '평택지제': '平泽地制',
      '천안아산': '天安牙山',
      '오송': '五松',
      '대전': '大田',
      '김천구미': '金泉龟尾',
      '동대구': '东大邱',
      '경주': '庆州',
      '울산': '蔚山',
      '부산': '釜山',
      '출발': '出发',
      '도착': '到达',
      '소요시간': '行程时间',
      '열차시간표': '列车时刻表',
      '출발편': '去程',
      '도착편': '回程',
      '출발편 좌석 선택': '选择去程座位',
      '도착편 좌석 선택': '选择回程座位',
      '선택됨': '已选择',
      '선택안됨': '未选择',
      '선택한 좌석': '已选座位',
      '어른': '成人',
      '어린이': '儿童',
      '경로': '老年人',
      '다음': '下一步',
      '결제하기': '进行支付',
      '예약 정보': '预订信息',
      '일정 정보': '行程信息',
      '좌석 정보': '座位信息',
      '가격 정보': '价格信息',
      '쿠폰 선택': '选择优惠券',
      '할인 유형': '折扣类型',
      '취소': '取消',
      '확인': '确认',
      '이전날': '前一天',
      '다음날': '后一天',
      '알림': '通知',
      '다음 열차가 없습니다.': '没有下一班列车。',
      '이전 열차가 없습니다.': '没有上一班列车。',
      '더 이전 날짜는 선택할 수 없습니다.': '无法选择更早的日期。',
      '기본 편도 가격': '基本单程价格',
      '할인 전 가격': '折扣前价格',
      '최종 가격': '最终价格',
      '할인 없음': '无折扣',
      '역 선택': '选择车站',
      '만 13세 이상': '13岁及以上',
      '만 6세 ~ 만 12세': '6岁至12岁',
      '만 65세 이상': '65岁及以上',
      '열차 시간표': '列车时刻表',
      '좌석 선택하기': '选择座位',
      '명': '人',
      '원': '韩元',
      '10% 할인': '10%折扣',
      '15% 할인': '15%折扣',
      '20% 할인': '20%折扣',
      '쿠폰': '优惠券',
      '시간': '小时',
      '분': '分钟',
      '출발편 좌석': '出发航班座位',
      '도착편 좌석': '返程航班座位',
    },
    'ja': {
      '승차권 예매': '乗車券予約',
      'K-Rail 간편 서비스': 'K Rail 便利な列車予約サービス',
      '승차권 관리': '乗車券管理',
      '열차위치 확인': '列車位置確認',
      '출발역': '出発駅',
      '도착역': '到着駅',
      '더보기': 'その他のオプション',
      '선택': '選択',
      '날짜 선택': '日付選択',
      '편도': '片道',
      '왕복': '往復',
      '예매하기': '予約する',
      '인원 선택': '乗客選択',
      '수서': 'スソ',
      '동탄': 'トンタン',
      '평택지제': 'ピョンテクチジェ',
      '천안아산': 'チョナンアサン',
      '오송': 'オソン',
      '대전': 'テジョン',
      '김천구미': 'キムチョングミ',
      '동대구': 'トンデグ',
      '경주': 'キョンジュ',
      '울산': 'ウルサン',
      '부산': 'プサン',
      '출발': '出発',
      '도착': '到着',
      '소요시간': '所要時間',
      '열차시간표': '列車時刻表',
      '출발편': '往路',
      '도착편': '復路',
      '출발편 좌석 선택': '往路座席選択',
      '도착편 좌석 선택': '復路座席選択',
      '선택됨': '選択済み',
      '선택안됨': '未選択',
      '선택한 좌석': '選択した座席',
      '어른': '大人',
      '어린이': '子供',
      '경로': '高齢者',
      '다음': '次へ',
      '결제하기': '支払いに進む',
      '예약 정보': '予約情報',
      '일정 정보': 'スケジュール情報',
      '좌석 정보': '座席情報',
      '가격 정보': '料金情報',
      '쿠폰 선택': 'クーポン選択',
      '할인 유형': '割引タイプ',
      '취소': 'キャンセル',
      '확인': '確認',
      '이전날': '前日',
      '다음날': '翌日',
      '알림': 'お知らせ',
      '다음 열차가 없습니다.': '次の列車はありません。',
      '이전 열차가 없습니다.': '前の列車はありません。',
      '더 이전 날짜는 선택할 수 없습니다.': 'これ以前の日付は選択できません。',
      '기본 편도 가격': '基本片道料金',
      '할인 전 가격': '割引前の価格',
      '최종 가격': '最終価格',
      '할인 없음': '割引なし',
      '역 선택': '駅選択',
      '만 13세 이상': '13歳以上',
      '만 6세 ~ 만 12세': '6歳～12歳',
      '만 65세 이상': '65歳以上',
      '열차 시간표': '列車時刻表',
      '좌석 선택하기': '座席を選択',
      '명': '名',
      '원': 'ウォン',
      '10% 할인': '10%割引',
      '15% 할인': '15%割引',
      '20% 할인': '20%割引',
      '쿠폰': 'クーポン',
      '시간': '時間',
      '분': '分',
      '출발편 좌석': '出発便の座席',
      '도착편 좌석': '到着便の座席',
    },
  };
}
