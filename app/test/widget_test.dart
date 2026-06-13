import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xray_scan/main.dart';

void main() {
  testWidgets('main menu shows title, play level action, and progress', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'high_score': 120});

    await tester.pumpWidget(const XrayScanApp());
    await tester.pumpAndSettle();

    expect(find.text('X-Ray Scan'), findsOneWidget);
    expect(find.text('PLAY LEVEL 1'), findsOneWidget);
    expect(find.text('ITEM DATABASE'), findsOneWidget);
    expect(find.text('Level 1 unlocked'), findsOneWidget);
    expect(find.text('Best clearance: 120'), findsOneWidget);
  });

  testWidgets('item database opens danger and safe groups', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const XrayScanApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ITEM DATABASE'));
    await tester.pumpAndSettle();

    expect(find.text('Item Database'), findsOneWidget);
    expect(find.text('DANGER ITEMS'), findsOneWidget);
    expect(find.text('SAFE ITEMS'), findsOneWidget);
    expect(find.text('0/5 discovered'), findsOneWidget);
    expect(find.text('0/6 discovered'), findsOneWidget);

    await tester.tap(find.text('DANGER ITEMS'));
    await tester.pumpAndSettle();

    expect(find.text('Danger Database'), findsOneWidget);
    expect(find.text('0/5 discovered'), findsOneWidget);
    expect(find.text('???'), findsWidgets);
  });
}
