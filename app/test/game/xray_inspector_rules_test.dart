import 'package:flutter_test/flutter_test.dart';
import 'package:tap_sort_rush/game/systems/xray_inspector_rules.dart';

void main() {
  group('XrayInspectorRules', () {
    test('danger taps increase score and combo', () {
      final rules = XrayInspectorRules();

      final first = rules.resolveDangerTap();
      final second = rules.resolveDangerTap();

      expect(first.score, 10);
      expect(first.combo, 1);
      expect(second.score, 20);
      expect(second.combo, 2);
      expect(second.lives, 3);
      expect(second.lastEvent, XrayFeedbackEvent.dangerFound);
    });

    test('combo multiplier increases every 10 combo', () {
      final rules = XrayInspectorRules();

      for (var i = 0; i < 10; i++) {
        rules.resolveDangerTap();
      }

      expect(rules.combo, 10);
      expect(rules.pointsForNextDangerTap(), 13);
    });

    test('safe taps apply penalty and reset combo without removing lives', () {
      final rules = XrayInspectorRules();
      rules.resolveDangerTap();
      rules.resolveDangerTap();

      final snapshot = rules.resolveSafeTap();

      expect(snapshot.score, 15);
      expect(snapshot.combo, 0);
      expect(snapshot.lives, 3);
      expect(snapshot.lastEvent, XrayFeedbackEvent.safeTapped);
    });

    test('safe tap penalty does not make score negative', () {
      final rules = XrayInspectorRules();

      final snapshot = rules.resolveSafeTap();

      expect(snapshot.score, 0);
      expect(snapshot.combo, 0);
      expect(snapshot.lives, 3);
    });

    test('missed danger removes lives and triggers game over at zero', () {
      final rules = XrayInspectorRules();

      rules.resolveMissedDanger();
      rules.resolveMissedDanger();
      final snapshot = rules.resolveMissedDanger();

      expect(snapshot.lives, 0);
      expect(snapshot.isGameOver, isTrue);
      expect(snapshot.lastEvent, XrayFeedbackEvent.dangerMissed);
    });

    test('safe bag clear grants bonus and continues combo', () {
      final rules = XrayInspectorRules();
      rules.resolveDangerTap();

      final snapshot = rules.resolveSafeBagClear();

      expect(snapshot.score, 15);
      expect(snapshot.combo, 2);
      expect(snapshot.lives, 3);
      expect(snapshot.lastEvent, XrayFeedbackEvent.safeBagCleared);
    });

    test('false clear removes one life and resets combo', () {
      final rules = XrayInspectorRules();
      rules.resolveDangerTap();

      final snapshot = rules.resolveFalseClear();

      expect(snapshot.score, 10);
      expect(snapshot.combo, 0);
      expect(snapshot.lives, 2);
      expect(snapshot.lastEvent, XrayFeedbackEvent.falseClear);
    });
  });
}
