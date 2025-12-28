# K-Rail Train Booking Demo

### Overview / 프로젝트 소개

한국 철도 예매 경험을 모바일 환경에서 구현한 Flutter 포트폴리오 데모입니다. 출발지/도착지 선택부터 KTX 시간표 조회, 좌석 선택, 예약 확인까지 하나의 흐름으로 구성했습니다.

A Flutter portfolio demo that recreates a Korean train-booking journey, from route selection and KTX schedules to seat selection and booking confirmation.

### Demo Journey / 대표 데모 여정

대표 데모 여정은 **수서 → 부산 / 편도 / 성인 1명**입니다.

The representative demo journey is **Suseo → Busan / one-way / one adult**.

## User Flow Preview / 사용자 흐름 미리보기

<p align="center">
  <img src=".github/assets/portfolio/01-home-booking.png" alt="K-Rail booking home" width="47%" />
  <img src=".github/assets/portfolio/05-station-selection.png" alt="K-Rail station selection" width="47%" />
</p>
<p align="center">
  <img src=".github/assets/portfolio/02-train-schedule.png" alt="K-Rail train schedule" width="47%" />
  <img src=".github/assets/portfolio/03-seat-selection.png" alt="K-Rail seat selection" width="47%" />
</p>
<p align="center">
  <img src=".github/assets/portfolio/06-booking-review.png" alt="K-Rail booking review before confirmation" width="47%" />
  <img src=".github/assets/portfolio/04-booking-confirmation.png" alt="K-Rail booking confirmation" width="47%" />
</p>
## What it does / 주요 기능

- 출발역과 도착역 선택 / Select departure and arrival stations.
- 여행 날짜, 승객 수, 편도·왕복 선택 / Choose travel date, passenger count, and one-way or round-trip travel.
- 출발·도착 시각, 소요 시간, 가격, 잔여석을 포함한 KTX 시간표 조회 / Browse KTX schedule cards with times, duration, fare, and remaining seats.
- 선택 가능·선택됨·선택 불가 상태를 구분한 좌석 배치도 / Select seats from an interactive carriage grid with available, selected, and unavailable states.
- 여정, 승객, 좌석, 쿠폰, 결제 금액 확인 / Review itinerary, passenger, seat, coupon, and price information.
- 실제 결제 없이 데모 예약 완료 화면 제공 / Complete a simulated checkout and view booking confirmation details.
- 한국어, 영어, 일본어, 중국어 UI 지원 / Switch between Korean, English, Japanese, and Chinese UI strings.

## Architecture / 구조

- Flutter `StatefulWidget`과 기본 Navigator route를 이용한 화면 흐름 / Screen flow built with Flutter `StatefulWidget` and standard Navigator routes.
- 홈 → 시간표 → 좌석 → 결제/예약 확인 단계로 예약 데이터 전달 / Booking data is passed through the home → schedule → seat → payment/confirmation flow.
- Flutter localization delegate와 `AppLocalizations` 기반 다국어 처리 / Localization is handled with Flutter localization delegates and the app's `AppLocalizations` implementation.
- 시간표, 좌석 상태, 가격, 결제 동작은 로컬 데모 데이터이며 실제 백엔드나 결제 게이트웨이는 사용하지 않음 / Schedule, seat availability, pricing, and checkout behavior use local demo data with no production backend or payment gateway.

## Tech Stack / 기술 스택

- Flutter / Dart
- Material 3
- `flutter_localizations`
- `intl`

## Run / 실행

```bash
git clone https://github.com/oosuhada/train_booking_app.git
cd train_booking_app
flutter pub get
flutter run
```

현재 데모 실행에는 API key, Firebase 프로젝트 또는 별도 credential이 필요하지 않습니다.

No API key, Firebase project, or private credential is required for the current demo flow.

## Demo Note / 데모 안내

이 저장소의 K-Rail은 포트폴리오 데모이며 실제 철도 예약 또는 결제 서비스와 연결되어 있지 않습니다. 시간표, 좌석, 요금, 쿠폰, 예약 정보는 시연 목적의 데이터입니다.

K-Rail in this repository is a portfolio demo and is not connected to an actual railway reservation or payment service. Schedule, seat, fare, coupon, and reservation information are illustrative.

## Topics

[`dart`](https://github.com/topics/dart) · [`flutter`](https://github.com/topics/flutter) · [`localization`](https://github.com/topics/localization) · [`mobile-app`](https://github.com/topics/mobile-app) · [`reservation-system`](https://github.com/topics/reservation-system) · [`train-booking`](https://github.com/topics/train-booking) · [`travel-app`](https://github.com/topics/travel-app)
