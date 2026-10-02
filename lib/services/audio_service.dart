import 'dart:async';
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
  final Map<String, AudioPool> _pools = {};

  Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll(_files);
      for (final file in _files) {
        final maxPlayers = switch (file) {
          'domino.wav' || 'ball.wav' || 'box.wav' => 3,
          _ => 1,
        };
        _pools[file] = await FlameAudio.createPool(
          file,
          minPlayers: 1,
          maxPlayers: maxPlayers,
        );
      }
      _ready = true;
    } catch (_) {
      await Future.wait(_pools.values.map((pool) => pool.dispose()));
      _pools.clear();
      _ready = false;
    }
  }

  void _play(String file, {double volume = 1, int minGapMs = 0}) {
    if (!_ready) return;
    final pool = _pools[file];
    if (pool == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - (_lastPlayed[file] ?? 0) < minGapMs) return;
    _lastPlayed[file] = now;
    unawaited(pool.start(volume: volume).then<void>((_) {}, onError: (_) {}));
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
