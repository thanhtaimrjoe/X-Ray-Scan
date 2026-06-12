import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._preferences);

  static const highScoreKey = 'high_score';
  static const soundEnabledKey = 'sound_enabled';

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
}
