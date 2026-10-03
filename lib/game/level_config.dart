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

/// Expected number of target-reaching direct taps. This is validation metadata;
/// it never changes simulation or tap eligibility.
enum TapChoiceProfile { broad, narrow, exact }

extension TapChoiceProfileRules on TapChoiceProfile {
  bool accepts(int successfulChoices) => switch (this) {
    TapChoiceProfile.broad => successfulChoices >= 4,
    TapChoiceProfile.narrow => successfulChoices >= 2 && successfulChoices <= 3,
    TapChoiceProfile.exact => successfulChoices == 1,
  };

  String get description => switch (this) {
    TapChoiceProfile.broad => '4 or more successful taps',
    TapChoiceProfile.narrow => '2–3 successful taps',
    TapChoiceProfile.exact => 'exactly 1 successful tap',
  };
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
    this.physicsActivatable = false,
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
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.domino,
         x: x,
         y: surfaceY - h / 2,
         w: 0.22,
         h: h,
         angle: angle,
         starter: starter,
         push: push,
         physicsActivatable: physicsActivatable,
         id: id,
       );

  /// Ball resting on a surface at [surfaceY].
  const ObjectSpec.ball(
    double x,
    double surfaceY, {
    double radius = 0.35,
    bool starter = false,
    Offset push = Offset.zero,
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.ball,
         x: x,
         y: surfaceY - radius,
         radius: radius,
         starter: starter,
         push: push,
         physicsActivatable: physicsActivatable,
         id: id,
       );

  /// Box resting on a surface at [surfaceY].
  const ObjectSpec.box(
    double x,
    double surfaceY, {
    double w = 0.9,
    double h = 0.9,
    bool starter = false,
    Offset push = Offset.zero,
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.box,
         x: x,
         y: surfaceY - h / 2,
         w: w,
         h: h,
         starter: starter,
         push: push,
         physicsActivatable: physicsActivatable,
         id: id,
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
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.jumper,
         x: x,
         y: surfaceY - h / 2,
         w: w,
         h: h,
         direction: direction,
         launchVelocity: launchVelocity,
         launchSpeed: launchSpeed,
         physicsActivatable: physicsActivatable,
       );

  /// A character rests on [surfaceY] and runs after a physics hit.
  const ObjectSpec.cat(
    double x,
    double surfaceY, {
    double direction = 1,
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.cat,
         x: x,
         y: surfaceY - 0.3,
         w: 0.72,
         h: 0.6,
         direction: direction,
         physicsActivatable: physicsActivatable,
         id: id,
       );

  const ObjectSpec.dog(
    double x,
    double surfaceY, {
    double direction = 1,
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.dog,
         x: x,
         y: surfaceY - 0.34,
         w: 0.82,
         h: 0.68,
         direction: direction,
         physicsActivatable: physicsActivatable,
         id: id,
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
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.button,
         x: x,
         y: y,
         w: w,
         h: h,
         id: id,
         linkedTargetId: linkedTargetId,
         physicsActivatable: physicsActivatable,
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
    String? id,
    bool physicsActivatable = true,
  }) : this._(
         kind: ObjectKind.plank,
         x: x,
         y: surfaceY - h / 2,
         w: length,
         h: h,
         angle: angle,
         starter: starter,
         push: push,
         physicsActivatable: physicsActivatable,
         id: id,
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

  /// Enables contact-driven actions such as springs, switches, and pet starts.
  /// Ordinary Forge2D collision response remains active regardless.
  final bool physicsActivatable;
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
    physicsActivatable: physicsActivatable,
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
    String? idPrefix,
  }) {
    return [
      for (var i = 0; i < count; i++)
        ObjectSpec.domino(
          fromX + i * spacing,
          surfaceY,
          h: h,
          starter: firstIsStarter && i == 0,
          push: firstIsStarter && i == 0 ? push : Offset.zero,
          id: idPrefix == null ? null : '$idPrefix${i + 1}',
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
    this.tapCandidates,
    this.tapChoiceProfile,
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

  /// Optional object IDs a player may tap directly. Null retains the original
  /// behavior for existing levels: every dynamic object is tappable. Physics
  /// contacts are independent of this allowlist.
  final Set<String>? tapCandidates;

  /// Optional design target checked by developer-side tap audits only.
  final TapChoiceProfile? tapChoiceProfile;

  String objectIdAt(int index) {
    final object = objects[index];
    if (object.id != null) return object.id!;
    final sameKindBefore = objects
        .take(index)
        .where((candidate) => candidate.kind == object.kind)
        .length;
    return '${object.kind.name}_${sameKindBefore + 1}';
  }

  List<int> get tapCandidateIndices => [
    for (var index = 0; index < objects.length; index++)
      if (objects[index].isDynamic &&
          (tapCandidates == null || tapCandidates!.contains(objectIdAt(index))))
        index,
  ];

  bool isTapCandidate(int objectIndex) {
    if (objectIndex < 0 || objectIndex >= objects.length) return false;
    final object = objects[objectIndex];
    return object.isDynamic &&
        (tapCandidates == null ||
            tapCandidates!.contains(objectIdAt(objectIndex)));
  }

  List<String> validateTapConfiguration() {
    if (tapCandidates == null) {
      if (tapChoiceProfile == TapChoiceProfile.exact &&
          tapCandidateIndices.length < 2) {
        return const [
          'An exact-choice profile needs at least two tap candidates.',
        ];
      }
      return const [];
    }
    final errors = <String>[];
    final knownIds = <String>{};
    for (var index = 0; index < objects.length; index++) {
      final id = objectIdAt(index);
      if (!knownIds.add(id)) errors.add('Duplicate object id "$id".');
    }
    for (final id in tapCandidates!) {
      int? index;
      for (var i = 0; i < objects.length; i++) {
        if (objectIdAt(i) == id) {
          index = i;
          break;
        }
      }
      if (index == null) {
        errors.add('Tap candidate "$id" does not exist.');
      } else if (!objects[index].isDynamic) {
        errors.add('Tap candidate "$id" is not dynamic.');
      }
    }
    if (tapCandidates!.isEmpty) {
      errors.add('At least one tap candidate is required.');
    }
    final starterIndex = objects.indexWhere((object) => object.starter);
    if (starterIndex >= 0 && !isTapCandidate(starterIndex)) {
      errors.add('The authored starter must also be a tap candidate.');
    }
    if (tapChoiceProfile == TapChoiceProfile.exact &&
        tapCandidateIndices.length < 2) {
      errors.add('An exact-choice profile needs at least two tap candidates.');
    }
    return List.unmodifiable(errors);
  }
}
