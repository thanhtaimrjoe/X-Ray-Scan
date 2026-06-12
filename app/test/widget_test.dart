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
    expect(find.text('ITEM DATABASE'), findsOneWidget);
    expect(find.text('Best clearance: 120'), findsOneWidget);
  });

  testWidgets('item database opens danger and safe groups', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TapSortRushApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ITEM DATABASE'));
    await tester.pumpAndSettle();

    expect(find.text('Item Database'), findsOneWidget);
    expect(find.text('Danger Items'), findsOneWidget);
    expect(find.text('Safe Items'), findsOneWidget);
    expect(find.text('0/5 discovered'), findsOneWidget);
    expect(find.text('0/6 discovered'), findsOneWidget);

    await tester.tap(find.text('Danger Items'));
    await tester.pumpAndSettle();

    expect(find.text('Danger Database'), findsOneWidget);
    expect(find.text('0/5 discovered'), findsOneWidget);
    expect(find.text('???'), findsWidgets);
  });
}
