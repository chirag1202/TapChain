import 'dart:math' as math;

import 'package:forge2d/forge2d.dart';

import 'level_config.dart';
import 'physics_objects.dart';

typedef ImpactCallback =
    void Function(ObjectKind a, ObjectKind? b, Vector2 point, double impulse);

/// Pure physics for one level; no Flame dependency so it can run headless.
class ChainSimulation extends ContactListener {
  ChainSimulation(this.config) {
    world.setContactListener(this);
    _build();
  }

  static const double step = 1 / 60;
  static const double gravity = 14;
  static const double quietNeeded = 1.5;
  static const double quietSpeed = 0.12;

  final LevelConfig config;
  final World world = World(Vector2(0, gravity));
  final List<PhysicsObject> objects = [];
  final List<PhysicsObject> _pendingJumperLaunches = [];
  final List<PhysicsObject> _pendingCharacters = [];
  final Set<String> _pendingGateIds = {};

  bool triggered = false;
  bool targetHit = false;
  bool failed = false;
  double time = 0; // seconds of physics since the tap
  double hitTime = -1;
  double _quiet = 0;
  double _acc = 0;

  ImpactCallback? onImpact;
  void Function()? onTargetHit;

  /// The object the player's tap sets in motion.
  PhysicsObject get starter => objects.firstWhere((o) => o.spec.starter);

  int get totalDynamicObjects => objects.where((o) => o.spec.isDynamic).length;

  int get fallenObjectCount => objects.where((o) => o.hasFallen).length;

  int get touchedObjectCount =>
      objects.where((o) => o.spec.isDynamic && o.touched).length;

  bool get allDynamicObjectsTouched =>
      touchedObjectCount == totalDynamicObjects;

  /// Gameplay may finish once the target and every dynamic object have been
  /// contacted, without waiting for their remaining momentum to settle.
  bool get completed => targetHit && allDynamicObjectsTouched;

  /// Fraction of the next fixed step already elapsed, for render interpolation.
  double get alpha => triggered ? _acc / step : 0;

  void _build() {
    _staticBox(kWorldWidth / 2, kGroundY + 1.5, kWorldWidth + 6, 3);
    _staticBox(-0.5, kWorldHeight / 2, 1, 40);
    _staticBox(kWorldWidth + 0.5, kWorldHeight / 2, 1, 40);

    for (final spec in config.objects) {
      final def = BodyDef(
        type: spec.isDynamic ? BodyType.dynamic : BodyType.static,
        position: Vector2(spec.x, spec.y),
        angle: spec.angle,
        angularDamping: spec.kind == ObjectKind.ball ? 0.15 : 0.05,
        linearDamping:
            spec.kind == ObjectKind.box ||
                spec.kind == ObjectKind.cat ||
                spec.kind == ObjectKind.dog
            ? 0.05
            : 0,
        fixedRotation:
            spec.kind == ObjectKind.cat || spec.kind == ObjectKind.dog,
        bullet: spec.kind == ObjectKind.ball,
      );
      final body = world.createBody(def);
      switch (spec.kind) {
        case ObjectKind.domino:
          body.createFixture(
            Materials.domino(
              PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
            ),
          );
        case ObjectKind.box:
          body.createFixture(
            Materials.box(PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2)),
          );
        case ObjectKind.platform:
          body.createFixture(
            Materials.platform(
              PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
            ),
          );
        case ObjectKind.jumper:
          body.createFixture(
            Materials.jumper(
              PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
            ),
          );
        case ObjectKind.ball:
          body.createFixture(
            Materials.ball(CircleShape()..radius = spec.radius),
          );
        case ObjectKind.target:
          body.createFixture(
            Materials.target(CircleShape()..radius = spec.radius),
          );
        case ObjectKind.cat:
        case ObjectKind.dog:
        case ObjectKind.plank:
          body.createFixture(
            spec.kind == ObjectKind.plank
                ? Materials.plank(
                    PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
                  )
                : Materials.character(
                    PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
                  ),
          );
        case ObjectKind.ramp:
          body.createFixture(
            Materials.ramp(
              PolygonShape()..set([
                Vector2(-spec.w / 2, spec.h / 2),
                Vector2(spec.w / 2, -spec.h / 2),
                Vector2(spec.w / 2, spec.h / 2),
              ]),
            ),
          );
        case ObjectKind.button:
          body.createFixture(
            Materials.button(
              PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2),
            ),
          );
        case ObjectKind.gate:
          body.createFixture(
            Materials.gate(PolygonShape()..setAsBoxXY(spec.w / 2, spec.h / 2)),
          );
      }
      final obj = PhysicsObject(spec, body);
      body.userData = obj;
      objects.add(obj);
    }
  }

  void _staticBox(double x, double y, double w, double h) {
    final body = world.createBody(BodyDef(position: Vector2(x, y)));
    body.createFixture(
      Materials.platform(PolygonShape()..setAsBoxXY(w / 2, h / 2))
        ..friction = 0.6,
    );
  }

  bool triggerAt(Vector2? tapPoint) {
    if (triggered) return false;
    final tapped = tapPoint == null
        ? starter
        : objects
              .where((o) {
                final index = objects.indexOf(o);
                return o.spec.isDynamic &&
                    !o.gone &&
                    config.isTapCandidate(index) &&
                    _containsTap(o, tapPoint);
              })
              .fold<PhysicsObject?>(null, (nearest, candidate) {
                if (nearest == null) return candidate;
                final candidateDistance =
                    (candidate.body.position - tapPoint).length2;
                final nearestDistance =
                    (nearest.body.position - tapPoint).length2;
                return candidateDistance < nearestDistance
                    ? candidate
                    : nearest;
              });
    if (tapped == null) return false;
    triggered = true;
    tapped.touched = true;
    tapped.playerTapped = true;
    _launch(tapped);
    return true;
  }

  void _launch(PhysicsObject object) {
    final spec = object.spec;
    var impulse = Vector2(spec.push.dx, spec.push.dy);
    if (!spec.starter) {
      PhysicsObject? nearest;
      var nearestDistance = double.infinity;
      for (final other in objects) {
        if (identical(other, object) || !other.spec.isDynamic || other.gone) {
          continue;
        }
        final delta = other.body.position - object.body.position;
        final distance = delta.length2;
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = other;
        }
      }
      final direction = nearest == null
          ? (object.body.position.x < kWorldWidth / 2 ? 1.0 : -1.0)
          : (nearest.body.position.x >= object.body.position.x ? 1.0 : -1.0);
      final strength = switch (spec.kind) {
        ObjectKind.domino => 0.35,
        ObjectKind.ball => 0.9,
        ObjectKind.box => 14.0,
        ObjectKind.plank => 8.0,
        ObjectKind.cat || ObjectKind.dog => 0.0,
        _ => 0.0,
      };
      if (object.isCharacter) {
        object.running = true;
        object.activated = true;
        object.flash = 0;
        object.body.linearVelocity = Vector2(
          spec.direction * 4.0,
          object.body.linearVelocity.y,
        );
        object.body.setAwake(true);
        return;
      }
      impulse = Vector2(direction * strength, 0);
    }
    final point = spec.kind == ObjectKind.domino
        ? object.body.worldPoint(Vector2(0, -spec.h * 0.45))
        : object.body.worldCenter;
    object.body.applyLinearImpulse(impulse, point: point);
  }

  bool _containsTap(PhysicsObject object, Vector2 point) {
    final spec = object.spec;
    final dx = point.x - object.body.position.x;
    final dy = point.y - object.body.position.y;
    final c = math.cos(object.body.angle);
    final s = math.sin(object.body.angle);
    final localX = dx * c + dy * s;
    final localY = -dx * s + dy * c;
    if (spec.kind == ObjectKind.ball) {
      return localX * localX + localY * localY <= spec.radius * spec.radius;
    }
    return localX.abs() <= spec.w / 2 && localY.abs() <= spec.h / 2;
  }

  void trigger() => triggerAt(null);

  /// Advances physics by [dt] real seconds using fixed steps.
  void update(double dt) {
    if (!triggered) return;
    _acc += math.min(dt, 0.1);
    while (_acc >= step) {
      _acc -= step;
      _stepOnce();
      if (completed) break;
    }
    for (final o in objects) {
      if (o.flash >= 0) o.flash += dt;
    }
  }

  /// Runs [seconds] of fixed steps; used by tests.
  void advance(double seconds) {
    final n = (seconds / step).round();
    for (var i = 0; i < n; i++) {
      _stepOnce();
    }
  }

  void _stepOnce() {
    for (final o in objects) {
      if (o.spec.isDynamic) o.savePrevious();
      if (o.isCharacter && o.running) {
        o.body.linearVelocity = Vector2(
          o.spec.direction * 4.0,
          o.body.linearVelocity.y,
        );
      }
    }
    world.stepDt(step);
    time += step;

    // Contact callbacks run while Forge2D locks the world. Apply spring
    // launches just after the step so the collision response cannot cancel
    // the authored boost or hold the ball against the pad.
    for (final launched in _pendingJumperLaunches) {
      final jumper = objects.firstWhere((o) => o.isJumper && o.activated);
      final halfHeight = launched.spec.kind == ObjectKind.ball
          ? launched.spec.radius
          : launched.spec.h / 2;
      final clearY =
          jumper.body.position.y - jumper.spec.h / 2 - halfHeight - 0.04;
      launched.body.setTransform(
        Vector2(launched.body.position.x, clearY),
        launched.body.angle,
      );
      launched.body.linearVelocity = Vector2(
        jumper.spec.direction * jumper.spec.launchSpeed,
        jumper.spec.launchVelocity,
      );
      launched.body.setAwake(true);
    }
    _pendingJumperLaunches.clear();
    for (final character in _pendingCharacters) {
      character.running = true;
      character.activated = true;
      character.flash = 0;
      character.body.linearVelocity = Vector2(
        character.spec.direction * 4.0,
        character.body.linearVelocity.y,
      );
      character.body.setAwake(true);
    }
    _pendingCharacters.clear();
    for (final id in _pendingGateIds) {
      for (final gate in objects.where((o) => o.isGate && o.spec.id == id)) {
        gate.open = true;
        gate.flash = 0;
        gate.body.setActive(false);
      }
    }
    _pendingGateIds.clear();

    var maxSpeed = 0.0;
    for (final o in objects) {
      if (!o.spec.isDynamic || o.gone) continue;
      final p = o.body.position;
      if (p.y > kWorldHeight + 6 || p.x < -4 || p.x > kWorldWidth + 4) {
        o.gone = true;
        o.body.setActive(false);
        continue;
      }
      maxSpeed = math.max(maxSpeed, o.body.linearVelocity.length);
      maxSpeed = math.max(maxSpeed, o.body.angularVelocity.abs() * 0.3);
    }

    // Hitting the target records the win, but the rest of the chain keeps
    // simulating until it settles so late-moving objects count toward score.
    if (!failed) {
      _quiet = maxSpeed < quietSpeed ? _quiet + step : 0;
      if (_quiet >= quietNeeded) failed = true;
    }
  }

  @override
  void beginContact(Contact contact) {
    final a = contact.fixtureA.body.userData as PhysicsObject?;
    final b = contact.fixtureB.body.userData as PhysicsObject?;
    if (a == null || b == null) return;
    if (a.spec.isDynamic) a.touched = true;
    if (b.spec.isDynamic) b.touched = true;
    if (a.spec.isDynamic && b.spec.isDynamic) {
      if (a.spec.physicsActivatable) a.physicsActivated = true;
      if (b.spec.physicsActivatable) b.physicsActivated = true;
    }

    final jumper = a.isJumper
        ? a
        : b.isJumper
        ? b
        : null;
    if (jumper != null && jumper.spec.physicsActivatable && !jumper.activated) {
      final launched = identical(jumper, a) ? b : a;
      if (launched.spec.isDynamic) {
        _pendingJumperLaunches.add(launched);
        jumper.activated = true;
        jumper.physicsActivated = true;
        launched.physicsActivated = true;
        jumper.flash = 0;
      }
    }

    final button = a.isButton
        ? a
        : b.isButton
        ? b
        : null;
    if (button != null && button.spec.physicsActivatable && !button.activated) {
      final other = identical(button, a) ? b : a;
      if (other.spec.isDynamic) {
        button.activated = true;
        button.physicsActivated = true;
        other.physicsActivated = true;
        button.flash = 0;
        final linked = button.spec.linkedTargetId;
        if (linked != null) _pendingGateIds.add(linked);
      }
    }

    for (final character in [a, b]) {
      if (!targetHit &&
          character.isCharacter &&
          character.spec.physicsActivatable &&
          !character.running) {
        final other = identical(character, a) ? b : a;
        if (other.spec.isDynamic && other != character) {
          character.physicsActivated = true;
          other.physicsActivated = true;
          _pendingCharacters.add(character);
        }
      }
    }

    if (targetHit) return;
    final aTarget = a.isTarget;
    final bTarget = b.isTarget;
    if (aTarget == bTarget) return;
    final target = aTarget ? a : b;
    final other = aTarget ? b : a;
    if (!other.spec.isDynamic) return;
    targetHit = true;
    target.touched = true;
    hitTime = time;
    target.flash = 0;
    // Character motors stop with the successful chain so the game can enter
    // its normal settle phase rather than pushing forever against a wall.
    for (final object in objects.where((o) => o.isCharacter)) {
      object.running = false;
    }
    onTargetHit?.call();
  }

  final WorldManifold _wm = WorldManifold();

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    final cb = onImpact;
    if (cb == null || impulse.count == 0) return;
    final strength = impulse.normalImpulses[0];
    if (strength < 0.04) return;
    final a = contact.fixtureA.body.userData as PhysicsObject?;
    final b = contact.fixtureB.body.userData as PhysicsObject?;
    contact.getWorldManifold(_wm);
    final dyn = (a != null && a.spec.isDynamic) ? a : b;
    final other = identical(dyn, a) ? b : a;
    if (dyn == null) return;
    cb(dyn.spec.kind, other?.spec.kind, _wm.points[0].clone(), strength);
  }
}
