import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._(this._prefs)
    : coins = ValueNotifier(_prefs?.getInt(_coinsKey) ?? 0),
      unlockedLevel = ValueNotifier(_prefs?.getInt(_unlockedKey) ?? 1);

  static const _coinsKey = 'coins';
  static const _unlockedKey = 'unlockedLevel';
  static const _ftueKey = 'ftueSeen';
  static const int levelCount = 7;

  static late LocalStorage instance;

  final SharedPreferences? _prefs;
  final ValueNotifier<int> coins;
  final ValueNotifier<int> unlockedLevel;

  static Future<void> init() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Progress stays in memory if storage is unavailable.
    }
    instance = LocalStorage._(prefs);
  }

  bool get ftueSeen => _prefs?.getBool(_ftueKey) ?? _ftueSeenInMemory;
  bool _ftueSeenInMemory = false;

  void markFtueSeen() {
    _ftueSeenInMemory = true;
    _prefs?.setBool(_ftueKey, true);
  }

  void addCoins(int amount) {
    coins.value += amount;
    _prefs?.setInt(_coinsKey, coins.value);
  }

  /// Unlocks [level] if it is beyond the current progress.
  void unlock(int level) {
    if (level > levelCount || level <= unlockedLevel.value) return;
    unlockedLevel.value = level;
    _prefs?.setInt(_unlockedKey, level);
  }

  bool isUnlocked(int level) => level <= unlockedLevel.value;
}
