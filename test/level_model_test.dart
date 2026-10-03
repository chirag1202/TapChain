import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tapchain/models/level_model.dart';
import 'package:tapchain/services/local_storage.dart';

void main() {
  group('multiplier tiers', () {
    test('boundaries', () {
      expect(LevelResult.multiplierFor(60), 3);
      expect(LevelResult.multiplierFor(50), 3);
      expect(LevelResult.multiplierFor(49.9), 2);
      expect(LevelResult.multiplierFor(40), 2);
      expect(LevelResult.multiplierFor(39.9), 1.5);
      expect(LevelResult.multiplierFor(30), 1.5);
      expect(LevelResult.multiplierFor(29.9), 1);
      expect(LevelResult.multiplierFor(0), 1);
    });

    test('spec example: 43.2s with base 50 pays 100', () {
      const r = LevelResult(timeLeft: 43.2, baseReward: 50);
      expect(r.multiplier, 2);
      expect(r.reward, 100);
      expect(r.stars, 2);
    });

    test('floorTenths matches the HUD digits', () {
      expect(LevelResult.floorTenths(49.97), 49.9);
      expect(LevelResult.floorTenths(60), 60);
      expect(LevelResult.floorTenths(-1), 0);
    });
  });

  group('local storage', () {
    test('all levels are unlocked while progress tracking remains intact', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
      var s = LocalStorage.instance;
      expect(s.isUnlocked(1), isTrue);
      expect(s.isUnlocked(2), isTrue);
      expect(s.isUnlocked(LocalStorage.levelCount), isTrue);
      expect(s.isUnlocked(LocalStorage.levelCount + 1), isFalse);
      expect(s.unlockedLevel.value, 1);

      s.unlock(2);
      s.addCoins(125);

      await LocalStorage.init();
      s = LocalStorage.instance;
      expect(s.isUnlocked(2), isTrue);
      expect(s.isUnlocked(3), isTrue);
      expect(s.isUnlocked(LocalStorage.levelCount), isTrue);
      expect(s.unlockedLevel.value, 2);
      expect(s.coins.value, 125);
    });

    test('testing unlock state covers the full current level list', () async {
      SharedPreferences.setMockInitialValues({'unlockedLevel': 4});
      await LocalStorage.init();
      final s = LocalStorage.instance
        ..unlock(2)
        ..unlock(11);
      expect(s.unlockedLevel.value, 11);
    });
  });
}
