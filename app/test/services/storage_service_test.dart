import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xray_scan/game/systems/level_progression_rules.dart';
import 'package:xray_scan/game/systems/xray_inspector_rules.dart';
import 'package:xray_scan/services/storage_service.dart';

void main() {
  group('StorageService x-ray discoveries', () {
    test('stores and restores unlocked x-ray items', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.load();

      await storage.unlockXrayItem(XrayObjectType.knife);
      await storage.unlockXrayItem(XrayObjectType.bottle);

      final unlockedItems = storage.getUnlockedXrayItems();

      expect(unlockedItems, contains(XrayObjectType.knife));
      expect(unlockedItems, contains(XrayObjectType.bottle));
      expect(unlockedItems, isNot(contains(XrayObjectType.scissors)));
    });
  });

  group('StorageService level progression', () {
    test('defaults to level 1 unlocked with empty bests', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.load();

      final snapshot = storage.getLevelProgressSnapshot();

      expect(snapshot.highestUnlockedLevel, 1);
      expect(snapshot.bestScores, isEmpty);
      expect(snapshot.bestStars, isEmpty);
    });

    test('persists unlock, best score, and best stars after restart', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.load();
      final config = LevelProgressionRules.configForLevel(1);
      final outcome = LevelProgressionRules.outcomeFor(
        config: config,
        bagsCleared: 3,
        score: 820,
        lives: 2,
      );

      await storage.applyLevelOutcome(outcome);

      final reloaded = await StorageService.load();
      final snapshot = reloaded.getLevelProgressSnapshot();

      expect(snapshot.highestUnlockedLevel, 2);
      expect(snapshot.bestScoreFor(1), 820);
      expect(snapshot.bestStarsFor(1), 3);
    });

    test('keeps the higher stored stars and score on replay', () async {
      SharedPreferences.setMockInitialValues({
        StorageService.highestUnlockedLevelKey: 2,
        StorageService.levelBestScoresKey: '{"1":820}',
        StorageService.levelBestStarsKey: '{"1":3}',
      });
      final storage = await StorageService.load();
      final config = LevelProgressionRules.configForLevel(1);
      final outcome = LevelProgressionRules.outcomeFor(
        config: config,
        bagsCleared: 3,
        score: 520,
        lives: 3,
      );

      await storage.applyLevelOutcome(outcome);
      final snapshot = storage.getLevelProgressSnapshot();

      expect(snapshot.bestScoreFor(1), 820);
      expect(snapshot.bestStarsFor(1), 3);
    });
  });
}
