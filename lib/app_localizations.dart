import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko'].contains(locale.languageCode);
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
    'en': {
      'title': 'K Rail',
      'book_ticket': 'Book Ticket',
      'departure_station': 'Departure Station',
      'arrival_station': 'Arrival Station',
      'ticket_management': 'Ticket Management',
      'train_location': 'Train Location',
      'language': 'Language',
      'select_date': 'Select Date',
      'departure_date': 'Departure Date',
      'return_date': 'Return Date',
      'passenger': 'Passenger',
      'adult': 'Adult',
      'child': 'Child',
      'senior': 'Senior',
      'one_way': 'One Way',
      'round_trip': 'Round Trip',
    },
    'ko': {
      'title': 'K 레일',
      'book_ticket': '승차권 예매',
      'departure_station': '출발역',
      'arrival_station': '도착역',
      'ticket_management': '승차권 관리',
      'train_location': '열차위치 확인',
      'language': '언어',
      'select_date': '날짜 선택',
      'departure_date': '가는 날',
      'return_date': '오는 날',
      'passenger': '인원',
      'adult': '어른',
      'child': '어린이',
      'senior': '경로',
      'one_way': '편도',
      'round_trip': '왕복',
    },
  };
}
