import 'package:flutter_test/flutter_test.dart';
import 'package:xray_scan/game/systems/level_progression_rules.dart';
import 'package:xray_scan/game/systems/xray_inspector_rules.dart';

void main() {
  group('LevelProgressionRules', () {
    test('level catalog exposes the full 30-level multi-world packs', () {
      expect(levelCatalog.length, 30);
      expect(LevelProgressionRules.maxLevelNumber, 30);
      expect(LevelProgressionRules.configForLevel(1).bagsToClear, 3);
      expect(LevelProgressionRules.configForLevel(2).bagsToClear, 4);
      expect(LevelProgressionRules.configForLevel(3).bagsToClear, 5);
      expect(LevelProgressionRules.configForLevel(10).bagsToClear, 10);
      expect(LevelProgressionRules.configForLevel(20).bagsToClear, 11);
      expect(LevelProgressionRules.configForLevel(30).bagsToClear, 12);
    });

    test('level 1 uses knife-only danger pool and easy safe pool', () {
      final config = LevelProgressionRules.configForLevel(1);

      expect(config.dangerPool, [XrayObjectType.knife]);
      expect(
        config.safePool,
        [XrayObjectType.phone, XrayObjectType.bottle],
      );
    });

    test('level 2 introduces scissors in the danger pool', () {
      final config = LevelProgressionRules.configForLevel(2);

      expect(config.newlyUnlockedDanger, XrayObjectType.scissors);
      expect(config.dangerPool, contains(XrayObjectType.scissors));
    });

    test('level 3 introduces lighter and allows more speed pressure', () {
      final config = LevelProgressionRules.configForLevel(3);

      expect(config.newlyUnlockedDanger, XrayObjectType.lighter);
      expect(config.allowTwoDangerBags, isTrue);
    });

    test('level 5 introduces razor and level 8 introduces battery pack', () {
      final level5 = LevelProgressionRules.configForLevel(5);
      final level8 = LevelProgressionRules.configForLevel(8);

      expect(level5.newlyUnlockedDanger, XrayObjectType.razor);
      expect(level5.dangerPool, contains(XrayObjectType.razor));
      expect(level8.newlyUnlockedDanger, XrayObjectType.batteryPack);
      expect(level8.dangerPool, contains(XrayObjectType.batteryPack));
    });

    test('stars require objective completion first', () {
      final config = LevelProgressionRules.configForLevel(1);

      expect(
        LevelProgressionRules.starsForAttempt(
          config: config,
          bagsCleared: 2,
          score: 900,
        ),
        0,
      );
      expect(
        LevelProgressionRules.starsForAttempt(
          config: config,
          bagsCleared: 3,
          score: 400,
        ),
        1,
      );
      expect(
        LevelProgressionRules.starsForAttempt(
          config: config,
          bagsCleared: 3,
          score: 500,
        ),
        2,
      );
      expect(
        LevelProgressionRules.starsForAttempt(
          config: config,
          bagsCleared: 3,
          score: 800,
        ),
        3,
      );
    });

    test('completing level 1 unlocks level 2 and stores best score/stars', () {
      const current = LevelProgressSnapshot(
        highestUnlockedLevel: 1,
        bestScores: {},
        bestStars: {},
      );
      final config = LevelProgressionRules.configForLevel(1);
      final outcome = LevelProgressionRules.outcomeFor(
        config: config,
        bagsCleared: 3,
        score: 820,
        lives: 2,
      );

      final update = LevelProgressionRules.applyOutcome(
        current: current,
        outcome: outcome,
      );

      expect(update.updated.highestUnlockedLevel, 2);
      expect(update.updated.bestScoreFor(1), 820);
      expect(update.updated.bestStarsFor(1), 3);
      expect(update.didUnlockNextLevel, isTrue);
      expect(update.canPlayNext, isTrue);
    });

    test('failed attempt does not unlock or overwrite bests', () {
      const current = LevelProgressSnapshot(
        highestUnlockedLevel: 2,
        bestScores: {1: 700},
        bestStars: {1: 2},
      );
      final config = LevelProgressionRules.configForLevel(2);
      final outcome = LevelProgressionRules.outcomeFor(
        config: config,
        bagsCleared: 2,
        score: 900,
        lives: 0,
      );

      final update = LevelProgressionRules.applyOutcome(
        current: current,
        outcome: outcome,
      );

      expect(outcome.didFail, isTrue);
      expect(update.updated.highestUnlockedLevel, 2);
      expect(update.updated.bestScoreFor(1), 700);
      expect(update.updated.bestStarsFor(1), 2);
      expect(update.updated.bestScoreFor(2), 0);
      expect(update.didUnlockNextLevel, isFalse);
    });

    test('better stars and score update independently', () {
      const current = LevelProgressSnapshot(
        highestUnlockedLevel: 2,
        bestScores: {1: 900},
        bestStars: {1: 3},
      );
      final config = LevelProgressionRules.configForLevel(1);
      final outcome = LevelProgressionRules.outcomeFor(
        config: config,
        bagsCleared: 3,
        score: 520,
        lives: 3,
      );

      final update = LevelProgressionRules.applyOutcome(
        current: current,
        outcome: outcome,
      );

      expect(update.updated.bestScoreFor(1), 900);
      expect(update.updated.bestStarsFor(1), 3);
      expect(update.didImproveScore, isFalse);
      expect(update.didImproveStars, isFalse);
    });
  });
}
