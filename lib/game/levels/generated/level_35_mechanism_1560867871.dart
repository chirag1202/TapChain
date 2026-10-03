import 'dart:ui';
import '../../level_config.dart';

const _generatedTheme = LevelTheme(
  id: ThemeId.neon,
  name: 'Neon Night',
  emoji: '🌃',
  skyTop: Color(0xFF07072B),
  skyBottom: Color(0xFF3A0CA3),
  ground: Color(0xFF14143F),
  groundTop: Color(0xFF00F5D4),
  platform: Color(0xFF12123A),
  platformEdge: Color(0xFF00F5D4),
  domino: Color(0xFFFF2E93),
  dominoDot: Color(0xFFFFFFFF),
  ball: Color(0xFF00E5FF),
  box: Color(0xFFB5179E),
  boxEdge: Color(0xFFF72585),
  target: Color(0xFFFFEE32),
  accent: Color(0xFF00F5D4),
  glow: true,
);

final levelGeneratedMechanism5 = LevelConfig(
  id: 35,
  name: 'Generated Mechanism 5',
  hint: 'Use the characters and switch to open the way to the target.',
  theme: _generatedTheme,
  baseReward: 250,
  generatorVersion: 1,
  generationSeed: 1560867871,
  generationTemplate: 'mechanism',
  generationDifficulty: 15,
  complexityScore: 15.0,
  objects: [
    ObjectSpec.domino(1.2, 14.0, h: 1.0, angle: 0.0, starter: true, push: Offset(0.35, 0.0)),
    ObjectSpec.domino(1.76, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.3200000000000003, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.88, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.ball(3.4299999999999997, 14.0, radius: 0.35),
    ObjectSpec.dog(4.21, 14.0, direction: 1.0),
    ObjectSpec.cat(5.11, 14.0, direction: 1.0),
    ObjectSpec.button(5.96, 13.88, w: 0.55, h: 0.2, id: 'switch-a', linkedTargetId: 'gate-a'),
    ObjectSpec.gate(6.61, 13.2, w: 0.25, h: 1.6, id: 'gate-a'),
    ObjectSpec.ramp(0.55, 13.88, 0.9, h: 0.22, angle: -0.18),
    ObjectSpec.plank(7.25, 14.0, length: 0.7, h: 0.2, angle: 0.0),
    ObjectSpec.target(8.45, 14.0, radius: 0.48),
  ],
);
