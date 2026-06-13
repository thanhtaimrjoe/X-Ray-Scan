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

  testWidgets('main menu reflects highest unlocked level in the full pack', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'high_score': 120,
      'highest_unlocked_level': 10,
    });

    await tester.pumpWidget(const XrayScanApp());
    await tester.pumpAndSettle();

    expect(find.text('PLAY LEVEL 10'), findsOneWidget);
    expect(find.text('Level 10 unlocked'), findsOneWidget);
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

    expect(find.text('CONTINUE (WATCH AD)'), findsOneWidget);
    await tester.tap(find.text('CONTINUE (WATCH AD)'));
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

      expect(find.text('CONTINUE (WATCH AD)'), findsNothing);
    },
  );
}
