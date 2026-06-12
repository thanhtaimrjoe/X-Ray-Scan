import 'package:shared_preferences/shared_preferences.dart';

import '../game/systems/xray_inspector_rules.dart';

class StorageService {
  StorageService(this._preferences);

  static const highScoreKey = 'high_score';
  static const soundEnabledKey = 'sound_enabled';
  static const unlockedXrayItemsKey = 'unlocked_xray_items';

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
}
