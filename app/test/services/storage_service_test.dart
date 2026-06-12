import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_sort_rush/game/systems/xray_inspector_rules.dart';
import 'package:tap_sort_rush/services/storage_service.dart';

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
}
