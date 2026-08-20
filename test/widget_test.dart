import 'package:flutter_test/flutter_test.dart';
import 'package:train_booking_app/main.dart';

void main() {
  testWidgets('shows the K-Rail booking journey after splash',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('K-Rail'), findsOneWidget);
    expect(find.text('승차권 예매'), findsOneWidget);
    expect(find.text('수서'), findsOneWidget);
    expect(find.text('부산'), findsOneWidget);
    expect(find.textContaining('어른 1'), findsOneWidget);
    expect(find.text('예매하기'), findsOneWidget);
  });
}
