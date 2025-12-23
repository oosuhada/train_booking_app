import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
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
