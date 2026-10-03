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

final levelGeneratedMechanism6 = LevelConfig(
  id: 26,
  name: 'Generated Mechanism 6',
  hint: 'Use the characters and switch to open the way to the target.',
  theme: _generatedTheme,
  baseReward: 160,
  generatorVersion: 1,
  generationSeed: 702189614,
  generationTemplate: 'mechanism',
  generationDifficulty: 6,
  complexityScore: 9.049999999999999,
  objects: [
    ObjectSpec.domino(1.2, 14.0, h: 1.0, angle: 0.0, starter: true, push: Offset(0.35, 0.0)),
    ObjectSpec.domino(1.76, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.3200000000000003, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.domino(2.88, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.domino(3.4400000000000004, 14.0, h: 1.0, angle: 0.0),
    ObjectSpec.ball(3.99, 14.0, radius: 0.35),
    ObjectSpec.dog(4.7700000000000005, 14.0, direction: 1.0),
    ObjectSpec.cat(5.670000000000001, 14.0, direction: 1.0),
    ObjectSpec.button(6.5200000000000005, 13.88, w: 0.55, h: 0.2, id: 'switch-a', linkedTargetId: 'gate-a'),
    ObjectSpec.gate(7.170000000000001, 13.2, w: 0.25, h: 1.6, id: 'gate-a'),
    ObjectSpec.ramp(0.5, 13.9, 0.8, h: 0.22, angle: -0.16),
    ObjectSpec.target(8.45, 14.0, radius: 0.48),
  ],
);
