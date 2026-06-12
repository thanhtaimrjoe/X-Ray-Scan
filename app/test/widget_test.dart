import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_sort_rush/main.dart';

void main() {
  testWidgets('main menu shows title, play action, and high score', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score': 120});

    await tester.pumpWidget(const TapSortRushApp());
    await tester.pumpAndSettle();

    expect(find.text('Tap Sort Rush'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('High score: 120'), findsOneWidget);
  });
}
