import 'dart:math' as math;
import 'dart:ui';

const double kWorldWidth = 9;
const double kWorldHeight = 16;
const double kGroundY = 14; // top surface of the floor

enum ObjectKind {
  domino,
  ball,
  box,
  platform,
  jumper,
  target,
  cat,
  dog,
  ramp,
  button,
  gate,
  plank,
}

enum ThemeId { garden, workshop, construction, neon, space, ocean, volcano }

class LevelTheme {
  const LevelTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    required this.groundTop,
    required this.platform,
    required this.platformEdge,
    required this.domino,
    required this.dominoDot,
    required this.ball,
    required this.box,
    required this.boxEdge,
    required this.target,
    required this.accent,
    this.glow = false,
  });

  final ThemeId id;
  final String name;
  final String emoji;
  final Color skyTop;
  final Color skyBottom;
  final Color ground;
  final Color groundTop;
  final Color platform;
  final Color platformEdge;
  final Color domino;
  final Color dominoDot;
  final Color ball;
  final Color box;
  final Color boxEdge;
  final Color target;
  final Color accent;
  final bool glow;
}

class ObjectSpec {
  const ObjectSpec._({
    required this.kind,
    required this.x,
    required this.y,
    this.w = 0,
    this.h = 0,
    this.radius = 0,
    this.angle = 0,
    this.starter = false,
    this.push = Offset.zero,
    this.direction = 1,
    this.launchVelocity = -15,
    this.launchSpeed = 1.7,
    this.id,
    this.linkedTargetId,
  });

  /// Domino standing on a surface at [surfaceY]; x is the centre.
  const ObjectSpec.domino(
    double x,
    double surfaceY, {
    double h = 1.0,
    double angle = 0,
    bool starter = false,
    Offset push = Offset.zero,
  }) : this._(
         kind: ObjectKind.domino,
         x: x,
         y: surfaceY - h / 2,
         w: 0.22,
         h: h,
         angle: angle,
         starter: starter,
         push: push,
       );

  /// Ball resting on a surface at [surfaceY].
  const ObjectSpec.ball(
    double x,
    double surfaceY, {
    double radius = 0.35,
    bool starter = false,
    Offset push = Offset.zero,
  }) : this._(
         kind: ObjectKind.ball,
         x: x,
         y: surfaceY - radius,
         radius: radius,
         starter: starter,
         push: push,
       );

  /// Box resting on a surface at [surfaceY].
  const ObjectSpec.box(
    double x,
    double surfaceY, {
    double w = 0.9,
    double h = 0.9,
    bool starter = false,
    Offset push = Offset.zero,
  }) : this._(
         kind: ObjectKind.box,
         x: x,
         y: surfaceY - h / 2,
         w: w,
         h: h,
         starter: starter,
         push: push,
       );

  /// Static platform; (x, y) is the midpoint of the top surface.
  factory ObjectSpec.platform(
    double x,
    double y,
    double w, {
    double h = 0.3,
    double angle = 0,
  }) {
    return ObjectSpec._(
      kind: ObjectKind.platform,
      x: x - h / 2 * math.sin(angle),
      y: y + h / 2 * math.cos(angle),
      w: w,
      h: h,
      angle: angle,
    );
  }

  /// Target bullseye standing on the ground / platform at [surfaceY].
  const ObjectSpec.target(double x, double surfaceY, {double radius = 0.55})
    : this._(
        kind: ObjectKind.target,
        x: x,
        y: surfaceY - radius,
        radius: radius,
      );

  /// Spring pad fixed to a surface at [surfaceY]. Contact launches an object up.
  const ObjectSpec.jumper(
    double x,
    double surfaceY, {
    double w = 1.0,
    double h = 0.36,
    double direction = 1,
    double launchVelocity = -15,
    double launchSpeed = 1.7,
  }) : this._(
         kind: ObjectKind.jumper,
         x: x,
         y: surfaceY - h / 2,
         w: w,
         h: h,
         direction: direction,
         launchVelocity: launchVelocity,
         launchSpeed: launchSpeed,
       );

  /// A character rests on [surfaceY] and runs after a physics hit.
  const ObjectSpec.cat(double x, double surfaceY, {double direction = 1})
    : this._(
        kind: ObjectKind.cat,
        x: x,
        y: surfaceY - 0.3,
        w: 0.72,
        h: 0.6,
        direction: direction,
      );

  const ObjectSpec.dog(double x, double surfaceY, {double direction = 1})
    : this._(
        kind: ObjectKind.dog,
        x: x,
        y: surfaceY - 0.34,
        w: 0.82,
        h: 0.68,
        direction: direction,
      );

  /// Static angled physical surface. Positive angles slope down to the right.
  factory ObjectSpec.ramp(
    double x,
    double y,
    double length, {
    double angle = 0.35,
    double h = 0.22,
  }) => ObjectSpec._(
    kind: ObjectKind.ramp,
    x: x,
    y: y,
    w: length,
    h: h,
    angle: angle,
  );

  /// Contact sensor that opens the gate named by [linkedTargetId].
  const ObjectSpec.button(
    double x,
    double y, {
    double w = 0.55,
    double h = 0.2,
    String? id,
    String? linkedTargetId,
  }) : this._(
         kind: ObjectKind.button,
         x: x,
         y: y,
         w: w,
         h: h,
         id: id,
         linkedTargetId: linkedTargetId,
       );

  /// Static collision barrier; linked buttons deactivate it when pressed.
  const ObjectSpec.gate(
    double x,
    double y, {
    double w = 0.25,
    double h = 1.6,
    String? id,
  }) : this._(kind: ObjectKind.gate, x: x, y: y, w: w, h: h, id: id);

  /// Dynamic plank that tips and can bridge a gap.
  const ObjectSpec.plank(
    double x,
    double surfaceY, {
    double length = 2.0,
    double h = 0.2,
    double angle = 0,
    bool starter = false,
    Offset push = Offset.zero,
  }) : this._(
         kind: ObjectKind.plank,
         x: x,
         y: surfaceY - h / 2,
         w: length,
         h: h,
         angle: angle,
         starter: starter,
         push: push,
       );

  final ObjectKind kind;
  final double x;
  final double y;
  final double w;
  final double h;
  final double radius;
  final double angle;

  /// Default launch object used when the timer expires without a tap.
  final bool starter;

  /// Authored launch impulse used for this level's default starter.
  final Offset push;
  final double direction;
  final double launchVelocity;
  final double launchSpeed;
  final String? id;
  final String? linkedTargetId;

  bool get isDynamic =>
      kind == ObjectKind.domino ||
      kind == ObjectKind.ball ||
      kind == ObjectKind.box ||
      kind == ObjectKind.cat ||
      kind == ObjectKind.dog ||
      kind == ObjectKind.plank;

  ObjectSpec withPushScale(double k) => ObjectSpec._(
    kind: kind,
    x: x,
    y: y,
    w: w,
    h: h,
    radius: radius,
    angle: angle,
    starter: starter,
    push: push * k,
    direction: direction,
    launchVelocity: launchVelocity,
    launchSpeed: launchSpeed,
    id: id,
    linkedTargetId: linkedTargetId,
  );

  /// A row of dominoes from [fromX], spaced by [spacing].
  static List<ObjectSpec> dominoRow({
    required double fromX,
    required double surfaceY,
    required int count,
    double spacing = 0.6,
    double h = 1.0,
    bool firstIsStarter = false,
    Offset push = const Offset(0.35, 0),
  }) {
    return [
      for (var i = 0; i < count; i++)
        ObjectSpec.domino(
          fromX + i * spacing,
          surfaceY,
          h: h,
          starter: firstIsStarter && i == 0,
          push: firstIsStarter && i == 0 ? push : Offset.zero,
        ),
    ];
  }
}

class LevelConfig {
  const LevelConfig({
    required this.id,
    required this.name,
    required this.hint,
    required this.theme,
    required this.baseReward,
    required this.objects,
    this.generatorVersion,
    this.generationSeed,
    this.generationTemplate,
    this.generationDifficulty,
    this.complexityScore,
  });

  final int id;
  final String name;
  final String hint;
  final LevelTheme theme;
  final int baseReward;
  final List<ObjectSpec> objects;

  /// Set only for levels emitted by [LevelGenerator].
  final int? generatorVersion;
  final int? generationSeed;
  final String? generationTemplate;
  final int? generationDifficulty;
  final double? complexityScore;
}
