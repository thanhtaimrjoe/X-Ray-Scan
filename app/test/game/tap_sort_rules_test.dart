import 'package:flutter_test/flutter_test.dart';
import 'package:tap_sort_rush/game/systems/tap_sort_rules.dart';

void main() {
  group('TapSortRules', () {
    test('correct sorts increase score and combo', () {
      final rules = TapSortRules();

      final first = rules.resolveSort(
        itemLane: SortLane.blue,
        tappedLane: SortLane.blue,
      );
      final second = rules.resolveSort(
        itemLane: SortLane.green,
        tappedLane: SortLane.green,
      );

      expect(first.score, 10);
      expect(first.combo, 1);
      expect(second.score, 20);
      expect(second.combo, 2);
      expect(second.lives, 3);
    });

    test('combo multiplier increases every 10 combo', () {
      final rules = TapSortRules();

      for (var i = 0; i < 10; i++) {
        rules.resolveSort(itemLane: SortLane.red, tappedLane: SortLane.red);
      }

      expect(rules.combo, 10);
      expect(rules.pointsForNextCorrectSort(), 13);
    });

    test('wrong lane resets combo and removes one life', () {
      final rules = TapSortRules();
      rules.resolveSort(itemLane: SortLane.yellow, tappedLane: SortLane.yellow);

      final snapshot = rules.resolveSort(
        itemLane: SortLane.yellow,
        tappedLane: SortLane.blue,
      );

      expect(snapshot.combo, 0);
      expect(snapshot.lives, 2);
      expect(snapshot.isGameOver, isFalse);
    });

    test('missed items remove lives and trigger game over at zero', () {
      final rules = TapSortRules();

      rules.resolveMiss();
      rules.resolveMiss();
      final snapshot = rules.resolveMiss();

      expect(snapshot.lives, 0);
      expect(snapshot.isGameOver, isTrue);
    });
  });
}
