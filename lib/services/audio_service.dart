import 'dart:math' as math;

import 'package:flame_audio/flame_audio.dart';

import '../game/level_config.dart';

/// Every call is a no-op if audio is unavailable; the game must run silently.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const _files = [
    'tap.wav',
    'domino.wav',
    'ball.wav',
    'box.wav',
    'target.wav',
    'coin.wav',
    'win.wav',
    'fail.wav',
  ];

  bool _ready = false;
  final Map<String, int> _lastPlayed = {};

  Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll(_files);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  void _play(String file, {double volume = 1, int minGapMs = 0}) {
    if (!_ready) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - (_lastPlayed[file] ?? 0) < minGapMs) return;
    _lastPlayed[file] = now;
    try {
      FlameAudio.play(file, volume: volume).then((_) {}, onError: (_) {});
    } catch (_) {
      // Ignore playback failures.
    }
  }

  void tap() => _play('tap.wav');
  void coin() => _play('coin.wav', minGapMs: 60);
  void win() => _play('win.wav');
  void fail() => _play('fail.wav');
  void targetHit() => _play('target.wav');

  void impact(ObjectKind a, ObjectKind? b, double strength) {
    final vol = math.min(1.0, 0.25 + strength * 0.5);
    if (a == ObjectKind.box || b == ObjectKind.box) {
      _play('box.wav', volume: vol, minGapMs: 120);
    } else if (a == ObjectKind.ball || b == ObjectKind.ball) {
      _play('ball.wav', volume: vol, minGapMs: 90);
    } else {
      _play('domino.wav', volume: vol, minGapMs: 55);
    }
  }
}
