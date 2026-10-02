import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../models/level_model.dart';
import '../services/audio_service.dart';
import 'backgrounds.dart';
import 'chain_simulation.dart';
import 'level_config.dart';
import 'physics_objects.dart';

enum GameState { waiting, running, success, failed }

class _Particle {
  _Particle(this.x, this.y, this.vx, this.vy, this.life, this.size, this.color)
    : maxLife = life;
  double x, y, vx, vy, life, size;
  final double maxLife;
  final Color color;
}

class TapChainGame extends FlameGame {
  TapChainGame({required this.level, required this.onFinished});

  /// Real-time speed of the chain; physics results are unchanged by it.
  static const double playbackSpeed = 1.3;

  final LevelConfig level;

  /// Called once when the outcome is decided and the end-of-chain pause is over.
  final void Function(LevelResult? result) onFinished;

  late final ChainSimulation sim = ChainSimulation(level)
    ..onImpact = _onImpact
    ..onTargetHit = _onTargetHit;

  GameState state = GameState.waiting;
  LevelResult? result;

  /// HUD countdown, updated only when the displayed tenth changes.
  final ValueNotifier<double> displayTime = ValueNotifier(kStartTime);
  final ValueNotifier<GameState> stateNotifier = ValueNotifier(
    GameState.waiting,
  );

  double _remaining = kStartTime;
  double _frozen = kStartTime;
  double _clock = 0;
  double _endTimer = 0;
  bool _reported = false;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random(7);

  double topInset = 0;
  double bottomInset = 0;
  double _scale = 1;
  double _ox = 0;
  double _oy = 0;

  @override
  Color backgroundColor() => level.theme.skyBottom;

  void setInsets({required double top, required double bottom}) {
    topInset = top;
    bottomInset = bottom;
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout();
  }

  void _layout() {
    if (!hasLayout || size.x <= 0 || size.y <= 0) return;
    final h = math.max(1.0, size.y - topInset - bottomInset);
    _scale = math.min(size.x / kWorldWidth, h / kWorldHeight);
    _ox = (size.x - kWorldWidth * _scale) / 2;
    _oy = topInset + (h - kWorldHeight * _scale) / 2;
  }

  /// Starts the chain only when the authored starter object is tapped.
  void handleTap(Offset screenPosition) {
    if (state != GameState.waiting) return;
    final point = Vector2(
      (screenPosition.dx - _ox) / _scale,
      (screenPosition.dy - _oy) / _scale,
    );
    if (sim.triggerAt(point)) _start();
  }

  void _start({bool timeout = false}) {
    if (timeout) sim.trigger();
    _frozen = LevelResult.floorTenths(_remaining);
    displayTime.value = _frozen;
    state = GameState.running;
    stateNotifier.value = state;
    AudioService.instance.tap();
  }

  @override
  void update(double dt) {
    if (_reported) return;
    final frameDt = math.min(dt, 0.1);
    super.update(frameDt);
    _clock += frameDt;

    if (state == GameState.waiting) {
      _remaining = math.max(0, _remaining - frameDt);
      final shown = LevelResult.floorTenths(_remaining);
      if (shown != displayTime.value) displayTime.value = shown;
      if (_remaining <= 0) _start(timeout: true);
    }

    final simDt = frameDt * playbackSpeed;
    if (state == GameState.running) {
      sim.update(simDt);
      if (sim.targetHit) {
        state = GameState.success;
        result = LevelResult(
          timeLeft: _frozen,
          baseReward: level.baseReward,
          fallenObjects: sim.fallenObjectCount,
          totalObjects: sim.totalDynamicObjects,
        );
        stateNotifier.value = state;
        _endTimer = 1.4;
      } else if (sim.failed) {
        state = GameState.failed;
        stateNotifier.value = state;
        _endTimer = 0.6;
      }
    } else if (state != GameState.waiting) {
      sim.update(simDt);
      _endTimer -= frameDt;
      if (_endTimer <= 0 && !_reported) {
        _reported = true;
        onFinished(result);
        pauseEngine();
      }
    }

    _updateParticles(frameDt);
  }

  void _updateParticles(double dt) {
    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life -= dt;
      if (p.life <= 0) {
        _particles.removeAt(i);
        continue;
      }
      p.vy += 9 * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
    }
  }

  void _burst(double x, double y, int n, Color color, double speed) {
    for (var i = 0; i < n && _particles.length < 120; i++) {
      final a = _rng.nextDouble() * math.pi * 2;
      final v = speed * (0.4 + _rng.nextDouble());
      _particles.add(
        _Particle(
          x,
          y,
          math.cos(a) * v,
          math.sin(a) * v - speed * 0.4,
          0.35 + _rng.nextDouble() * 0.4,
          0.05 + _rng.nextDouble() * 0.05,
          color,
        ),
      );
    }
  }

  void _onImpact(ObjectKind a, ObjectKind? b, Vector2 p, double strength) {
    AudioService.instance.impact(a, b, strength);
    if (strength > 0.25) {
      _burst(p.x, p.y, strength > 1 ? 5 : 3, level.theme.accent, 2.5);
    }
  }

  void _onTargetHit() {
    final t = sim.objects.firstWhere((o) => o.isTarget);
    final p = t.body.position;
    _burst(p.x, p.y, 28, level.theme.target, 5);
    _burst(p.x, p.y, 16, const Color(0xFFFFFFFF), 4);
    AudioService.instance.targetHit();
  }

  @override
  void render(Canvas canvas) {
    final s = Size(size.x, size.y);
    final theme = level.theme;
    paintBackground(canvas, s, theme, _clock);
    paintGround(canvas, s, _oy + kGroundY * _scale, _scale, theme, _clock);

    canvas.save();
    canvas.translate(_ox, _oy);
    canvas.scale(_scale);

    final alpha = sim.alpha;
    for (final o in sim.objects) {
      if (o.gone) continue;
      final spec = o.spec;
      canvas.save();
      if (spec.isDynamic) {
        canvas.translate(o.renderX(alpha), o.renderY(alpha));
        canvas.rotate(o.renderAngle(alpha));
      } else {
        canvas.translate(o.body.position.x, o.body.position.y);
        canvas.rotate(o.body.angle);
      }
      paintObject(
        canvas,
        theme,
        spec.kind,
        w: spec.w,
        h: spec.h,
        radius: spec.radius,
        flash: o.flash,
        time: _clock,
      );
      canvas.restore();
    }

    final paint = Paint();
    for (final p in _particles) {
      paint.color = p.color.withValues(alpha: (p.life / p.maxLife).clamp(0, 1));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }

    canvas.restore();
    super.render(canvas);
  }

  @override
  void onDispose() {
    displayTime.dispose();
    stateNotifier.dispose();
    super.onDispose();
  }
}
