# train_booking_app

A Flutter project - K-Rail 기차 예매 서비스 / K-Rail Train Booking Service / K-Rail 列車予約サービス / K-Rail 火车订票服务

## 한국어

### 프로젝트 개요

이 프로젝트는 Flutter를 사용하여 개발된 K-Rail 기차 예매 서비스 모바일 애플리케이션입니다. 사용자가 편리하게 기차표를 예매할 수 있도록 다국어 지원, 열차 시간표 조회, 좌석 선택, 결제 기능 등을 제공합니다.

### 주요 기능

- 다국어 지원 (한국어, 영어, 일본어, 중국어)
- 출발역과 도착역 선택
- 승객 유형 및 인원 선택
- 편도/왕복 여정 선택
- 열차 시간표 조회
- 좌석 선택
- 할인 쿠폰 적용
- 결제 기능

### 프로젝트 구조

프로젝트의 `lib` 폴더는 다음과 같은 파일들로 구성되어 있습니다:

1. `main.dart`: 애플리케이션의 진입점
2. `app_localizations.dart`: 다국어 지원을 위한 로컬라이제이션 설정
3. `home_page.dart`: 메인 화면 UI 및 로직
4. `passenger_selection.dart`: 승객 유형 및 인원 선택 화면
5. `station_list.dart`: 역 목록 및 선택 화면
6. `train_schedule.dart`: 열차 시간표 조회 및 선택 화면
7. `seat_page.dart`: 좌석 선택 화면
8. `payment_page.dart`: 결제 정보 확인 및 처리 화면

### 설치 및 실행

1. Flutter 개발 환경을 설정합니다.
2. 프로젝트를 클론합니다.
3. 프로젝트 디렉토리로 이동합니다.
4. 의존성 패키지를 설치합니다: `flutter pub get`
5. 애플리케이션을 실행합니다: `flutter run`

### 참고 사항

- 이 프로젝트는 실제 K-Rail 예매 서비스와 연동되어 있지 않으며, 데모 목적으로 제작되었습니다.
- 열차 스케줄 및 가격 정보는 실제와 다를 수 있습니다.
- 결제 기능은 실제 결제가 이루어지지 않으며, 시뮬레이션 목적으로만 구현되어 있습니다.

## English

### Project Overview

This project is a mobile application for the K-Rail train booking service developed using Flutter. It provides features such as multi-language support, train schedule lookup, seat selection, and payment processing to allow users to conveniently book train tickets.

### Key Features

- Multi-language support (Korean, English, Japanese, Chinese)
- Departure and arrival station selection
- Passenger type and number selection
- One-way/round-trip journey selection
- Train schedule lookup
- Seat selection
- Discount coupon application
- Payment processing

### Project Structure

The `lib` folder of the project consists of the following files:

1. `main.dart`: Entry point of the application
2. `app_localizations.dart`: Localization settings for multi-language support
3. `home_page.dart`: Main screen UI and logic
4. `passenger_selection.dart`: Passenger type and number selection screen
5. `station_list.dart`: Station list and selection screen
6. `train_schedule.dart`: Train schedule lookup and selection screen
7. `seat_page.dart`: Seat selection screen
8. `payment_page.dart`: Payment information confirmation and processing screen

### Installation and Execution

1. Set up the Flutter development environment.
2. Clone the project.
3. Navigate to the project directory.
4. Install dependencies: `flutter pub get`
5. Run the application: `flutter run`

### Notes

- This project is not linked to the actual K-Rail service and was created for demonstration purposes.
- Train schedules and price information may differ from reality.
- The payment function does not process actual payments and is implemented for simulation purposes only.

## 日本語

### プロジェクト概要

このプロジェクトは、Flutter を使用して開発された K-Rail 列車予約サービスのモバイルアプリケーションです。多言語サポート、列車スケジュール検索、座席選択、決済処理などの機能を提供し、ユーザーが便利に列車チケットを予約できるようにします。

### 主な機能

- 多言語サポート（韓国語、英語、日本語、中国語）
- 出発駅と到着駅の選択
- 乗客タイプと人数の選択
- 片道/往復旅程の選択
- 列車スケジュールの検索
- 座席選択
- 割引クーポンの適用
- 決済処理

### プロジェクト構造

プロジェクトの`lib`フォルダは以下のファイルで構成されています：

1. `main.dart`: アプリケーションのエントリーポイント
2. `app_localizations.dart`: 多言語サポートのためのローカライゼーション設定
3. `home_page.dart`: メイン画面の UI とロジック
4. `passenger_selection.dart`: 乗客タイプと人数選択画面
5. `station_list.dart`: 駅リストと選択画面
6. `train_schedule.dart`: 列車スケジュール検索と選択画面
7. `seat_page.dart`: 座席選択画面
8. `payment_page.dart`: 支払い情報確認と処理画面

### インストールと実行

1. Flutter 開発環境をセットアップします。
2. プロジェクトをクローンします。
3. プロジェクトディレクトリに移動します。
4. 依存関係をインストールします：`flutter pub get`
5. アプリケーションを実行します：`flutter run`

### 注意事項

- このプロジェクトは実際の K-Rail サービスとリンクしておらず、デモンストレーション目的で作成されました。
- 列車スケジュールと価格情報は現実と異なる場合があります。
- 決済機能は実際の支払いを処理せず、シミュレーション目的でのみ実装されています。

## 中文

### 项目概述

这个项目是使用 Flutter 开发的 K-Rail 列车订票服务移动应用程序。它提供多语言支持、列车时刻表查询、座位选择和支付处理等功能，让用户可以方便地预订火车票。

### 主要功能

- 多语言支持（韩语、英语、日语、中文）
- 出发站和到达站选择
- 乘客类型和人数选择
- 单程/往返行程选择
- 列车时刻表查询
- 座位选择
- 折扣优惠券应用
- 支付处理

### 项目结构

项目的`lib`文件夹包含以下文件：

1. `main.dart`：应用程序的入口点
2. `app_localizations.dart`：多语言支持的本地化设置
3. `home_page.dart`：主屏幕 UI 和逻辑
4. `passenger_selection.dart`：乘客类型和人数选择屏幕
5. `station_list.dart`：车站列表和选择屏幕
6. `train_schedule.dart`：列车时刻表查询和选择屏幕
7. `seat_page.dart`：座位选择屏幕
8. `payment_page.dart`：支付信息确认和处理屏幕

### 安装和执行

1. 设置 Flutter 开发环境。
2. 克隆项目。
3. 导航到项目目录。
4. 安装依赖项：`flutter pub get`
5. 运行应用程序：`flutter run`

### 注意事项

- 该项目未与实际的 K-Rail 服务链接，仅为演示目的而创建。
- 列车时刻表和价格信息可能与实际情况不同。
- 支付功能不处理实际支付，仅为模拟目的而实现。
