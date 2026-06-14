import 'package:flutter/material.dart';
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
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('LEVEL MAP'), findsOneWidget);
    expect(find.text('ITEM DATABASE'), findsOneWidget);
    expect(find.textContaining('Current Level'), findsOneWidget);
    expect(find.textContaining('Best Clearance'), findsOneWidget);
  });

  testWidgets('item database opens tabbed danger and safe groups', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const XrayScanApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ITEM DATABASE'));
    await tester.pumpAndSettle();

    expect(find.text('Item Database'), findsOneWidget);
    expect(find.text('DANGER ITEMS'), findsOneWidget);
    expect(find.text('SAFE ITEMS'), findsOneWidget);
    expect(find.text('Progress: 0/5 discovered'), findsOneWidget);
    expect(find.text('Knife'), findsOneWidget);
    expect(find.text('???'), findsWidgets);

    await tester.tap(find.text('SAFE ITEMS'));
    await tester.pumpAndSettle();

    expect(find.text('Progress: 0/6 discovered'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('???'), findsWidgets);
  });

  testWidgets('main menu reflects highest unlocked level in the full pack', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'high_score': 120,
      'highest_unlocked_level': 10,
    });

    await tester.pumpWidget(const XrayScanApp());
    await tester.pumpAndSettle();

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Level 10'), findsWidgets);
  });

  testWidgets('LevelFailedScreen shows continue button when ad is available', (
    tester,
  ) async {
    var continuePressed = false;
    var retryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LevelFailedScreen(
          levelNumber: 1,
          score: 300,
          bagsCleared: 2,
          bagsToClear: 3,
          onRetry: () => retryPressed = true,
          onMenu: () {},
          canContinueWithAd: true,
          onContinueWithAd: () => continuePressed = true,
        ),
      ),
    );

    expect(find.text('CONTINUE +1 LIFE'), findsOneWidget);
    await tester.tap(find.text('CONTINUE +1 LIFE'));
    await tester.pump();
    expect(continuePressed, isTrue);

    await tester.tap(find.text('RETRY'));
    await tester.pump();
    expect(retryPressed, isTrue);
  });

  testWidgets(
    'LevelFailedScreen hides continue button when ad is not available',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LevelFailedScreen(
            levelNumber: 1,
            score: 300,
            bagsCleared: 2,
            bagsToClear: 3,
            onRetry: () {},
            onMenu: () {},
            canContinueWithAd: false,
            onContinueWithAd: () {},
          ),
        ),
      );

      expect(find.text('CONTINUE +1 LIFE'), findsNothing);
    },
  );
}
