import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/systems/level_progression_rules.dart';
import '../game/systems/xray_inspector_rules.dart';

class StorageService {
  StorageService(this._preferences);

  static const highScoreKey = 'high_score';
  static const soundEnabledKey = 'sound_enabled';
  static const unlockedXrayItemsKey = 'unlocked_xray_items';
  static const highestUnlockedLevelKey = 'highest_unlocked_level';
  static const levelBestScoresKey = 'level_best_scores';
  static const levelBestStarsKey = 'level_best_stars';

  final SharedPreferences _preferences;

  static Future<StorageService> load() async {
    final preferences = await SharedPreferences.getInstance();
    return StorageService(preferences);
  }

  int getHighScore() => _preferences.getInt(highScoreKey) ?? 0;

  Future<bool> saveHighScore(int score) {
    return _preferences.setInt(highScoreKey, score);
  }

  bool getSoundEnabled() => _preferences.getBool(soundEnabledKey) ?? true;

  Future<bool> saveSoundEnabled({required bool enabled}) {
    return _preferences.setBool(soundEnabledKey, enabled);
  }

  Set<XrayObjectType> getUnlockedXrayItems() {
    final savedIds =
        _preferences.getStringList(unlockedXrayItemsKey) ?? const [];
    return XrayObjectType.values
        .where((type) => savedIds.contains(type.id))
        .toSet();
  }

  Future<bool> saveUnlockedXrayItems(Set<XrayObjectType> items) {
    final ids = items.map((type) => type.id).toList()..sort();
    return _preferences.setStringList(unlockedXrayItemsKey, ids);
  }

  Future<bool> unlockXrayItem(XrayObjectType item) {
    final items = getUnlockedXrayItems()..add(item);
    return saveUnlockedXrayItems(items);
  }

  int getHighestUnlockedLevel() {
    final saved = _preferences.getInt(highestUnlockedLevelKey);
    return LevelProgressionRules.clampHighestUnlocked(saved ?? 1);
  }

  Future<bool> saveHighestUnlockedLevel(int levelNumber) {
    return _preferences.setInt(
      highestUnlockedLevelKey,
      LevelProgressionRules.clampHighestUnlocked(levelNumber),
    );
  }

  Map<int, int> getLevelBestScores() {
    return _decodeIntMap(_preferences.getString(levelBestScoresKey));
  }

  Map<int, int> getLevelBestStars() {
    return _decodeIntMap(_preferences.getString(levelBestStarsKey));
  }

  LevelProgressSnapshot getLevelProgressSnapshot() {
    return LevelProgressSnapshot(
      highestUnlockedLevel: getHighestUnlockedLevel(),
      bestScores: getLevelBestScores(),
      bestStars: getLevelBestStars(),
    );
  }

  Future<void> saveLevelProgressSnapshot(LevelProgressSnapshot snapshot) async {
    await saveHighestUnlockedLevel(snapshot.highestUnlockedLevel);
    await _preferences.setString(
      levelBestScoresKey,
      jsonEncode(_encodeIntMap(snapshot.bestScores)),
    );
    await _preferences.setString(
      levelBestStarsKey,
      jsonEncode(_encodeIntMap(snapshot.bestStars)),
    );
  }

  Future<LevelProgressUpdate> applyLevelOutcome(
    LevelAttemptOutcome outcome,
  ) async {
    final update = LevelProgressionRules.applyOutcome(
      current: getLevelProgressSnapshot(),
      outcome: outcome,
    );
    await saveLevelProgressSnapshot(update.updated);
    return update;
  }

  Map<String, int> _encodeIntMap(Map<int, int> values) {
    return values.map((key, value) => MapEntry(key.toString(), value));
  }

  Map<int, int> _decodeIntMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return {};
    }

    final result = <int, int>{};
    decoded.forEach((key, value) {
      final levelNumber = int.tryParse(key.toString());
      final score = value is int ? value : int.tryParse(value.toString());
      if (levelNumber != null && score != null) {
        result[levelNumber] = score;
      }
    });
    return result;
  }
}
