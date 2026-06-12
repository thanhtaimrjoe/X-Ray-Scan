import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_sort_rush/main.dart';

void main() {
  testWidgets('main menu shows title, scan action, and high score', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score': 120});

    await tester.pumpWidget(const TapSortRushApp());
    await tester.pumpAndSettle();

    expect(find.text('X-Ray Inspector'), findsOneWidget);
    expect(find.text('SCAN'), findsOneWidget);
    expect(find.text('Best clearance: 120'), findsOneWidget);
  });
}
