import 'package:flutter/painting.dart';

import '../level_config.dart';
import 'level_2.dart' show workshopTheme;
import 'level_4.dart' show neonTheme;
import 'level_6.dart' show oceanTheme;
import 'level_7.dart' show volcanoTheme;

const _reward = 620;

/// Hand-authored finale. Each level changes the route topology or the order in
/// which a mechanic must be activated; these are not generator template cycles.
final List<LevelConfig> lateGameLevels = [
  // ─────────────────────────────────────────────────────────────────────────
  // Level 31 – Switch at the Bend  [TUNE – Phase 3: switch-gate-bend]
  // Auto-generated IDs: box_1(starter) · domino_1..4 · ball_1 ·
  //                     s31 · g31 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 31,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Switch at the Bend',
    hint:
        'The switch is before the gate. Start midway to send the ball through it.',
    theme: oceanTheme,
    baseReward: _reward,
    generationTemplate: 'switch-gate-bend',
    generationDifficulty: 11,
    complexityScore: 11,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The starter box drives a domino run into the ball; the ball rolls over '
          'the switch to open the gate and reaches the target. Direct taps midway '
          'fail to open the gate in time or carry sufficient momentum.',
      intendedTapIds: ['box_1', 'domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 's31', 'g31', 'target_1',
      ],
      reasoningPrompt: 'Why does tapping the ball directly fail to pass the gate, '
          'while starting from the box succeeds?',
      complexity: ['gate_dependency', 'ordering', 'momentum_threshold'],
    ),
    objects: [
      ObjectSpec.box(1.0, kGroundY, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.7,
        surfaceY: kGroundY,
        count: 4,
        spacing: 0.56,
      ),
      ObjectSpec.ball(4.5, kGroundY),
      ObjectSpec.button(
        5.05,
        kGroundY - 0.12,
        id: 's31',
        linkedTargetId: 'g31',
      ),
      ObjectSpec.gate(5.9, kGroundY - 0.8, id: 'g31'),
      ObjectSpec.target(7.4, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 32 – The Return Lane  [TUNE – Phase 4: reverse-two-tier]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..5 · ball_1 ·
  //                     ramp_1 · platform_2 · s32 · g32 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 32,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'The Return Lane',
    hint:
        'Start on the upper right; the ball must cross the lower lane back to the target.',
    theme: volcanoTheme,
    baseReward: _reward + 20,
    generationTemplate: 'reverse-two-tier',
    generationDifficulty: 12,
    complexityScore: 12,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'domino_5',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The upper right platform chain pushes the ball leftward onto a '
          'deflector ramp; the ramp redirects it down to the lower shelf where '
          'it presses the switch to open the gate and reach the target.',
      intendedTapIds: ['domino_1', 'domino_2'],
      decoys: ['domino_3', 'domino_4', 'domino_5', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4', 'domino_5',
        'ball_1', 'ramp_1', 's32', 'g32', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly fails to reach the switch with '
          'the required speed. Why is momentum from the upper run essential?',
      complexity: ['vertical_transfer', 'direction_reversal', 'gate_dependency'],
    ),
    objects: [
      ObjectSpec.platform(6.6, 6.4, 4.4),
      ObjectSpec.domino(8.1, 6.4, starter: true, push: const Offset(-0.38, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.5,
        surfaceY: 6.4,
        count: 4,
        spacing: -0.58,
      ),
      ObjectSpec.ball(5.0, 6.4),
      ObjectSpec.ramp(4.4, 8.8, 2.2, angle: -0.28),
      ObjectSpec.platform(2.8, 10.3, 4.4),
      ObjectSpec.button(2.15, 10.18, id: 's32', linkedTargetId: 'g32'),
      ObjectSpec.gate(0.7, 9.5, h: 1.6, id: 'g32'),
      ObjectSpec.target(1.5, 10.3, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 33 – Spring to the Left Target  [TUNE – Phase 3: spring-left-target]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     jumper_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 33,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Spring to the Left Target',
    hint:
        'The upper row feeds a leftward launch; the ball must land on the floor target.',
    theme: neonTheme,
    baseReward: _reward + 40,
    generationTemplate: 'spring-left-target',
    generationDifficulty: 13,
    complexityScore: 13,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Upper shelf box drives a left-falling domino chain; ball drops into the '
          'jumper on the floor and is launched leftward into the target.',
      intendedTapIds: ['box_1', 'domino_1'],
      decoys: ['domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'jumper_1', 'target_1',
      ],
      reasoningPrompt: 'Why does tapping the ball directly cause it to miss the jumper '
          'arc, while starting from the box succeeds?',
      complexity: ['vertical_transfer', 'jumper_launch', 'trajectory_planning'],
    ),
    objects: [
      ObjectSpec.platform(7.0, 9.3, 3.8),
      ObjectSpec.box(8.15, 9.3, starter: true, push: const Offset(-14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.55,
        surfaceY: 9.3,
        count: 4,
        spacing: -0.5,
      ),
      ObjectSpec.ball(5.45, 9.3),
      ObjectSpec.jumper(3.0, kGroundY, w: 1.2, direction: -1),
      ObjectSpec.target(2.0, kGroundY, radius: 0.65),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 34 – Counterflow Pet Relay  [TUNE – Phase 4: pet-counterflow]
  // Auto-generated IDs: domino_1(starter) · domino_2..4 · ball_1 ·
  //                     dog_1 · cat_1 · s34 · g34 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 34,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Counterflow Pet Relay',
    hint:
        'Start on the right: the dog wakes the cat, which presses the linked gate switch.',
    theme: workshopTheme,
    baseReward: _reward + 60,
    generationTemplate: 'pet-counterflow',
    generationDifficulty: 14,
    complexityScore: 14,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The starter domino pushes the chain into the dog, which collides with '
          'and activates the cat; the cat presses the switch to open the gate and '
          'reach the target.',
      intendedTapIds: ['domino_1', 'domino_2'],
      decoys: ['domino_3', 'domino_4', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'dog_1', 'cat_1', 's34', 'g34', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly fails to activate the pets with '
          'sufficient force. Why is the full domino chain necessary?',
      complexity: ['pet_relay', 'gate_dependency', 'momentum_transfer'],
    ),
    objects: [
      ObjectSpec.domino(
        7.8,
        kGroundY,
        starter: true,
        push: const Offset(-0.35, 0),
      ),
      ...ObjectSpec.dominoRow(
        fromX: 7.24,
        surfaceY: kGroundY,
        count: 3,
        spacing: -0.56,
      ),
      ObjectSpec.ball(5.57, kGroundY),
      ObjectSpec.dog(4.79, kGroundY, direction: -1),
      ObjectSpec.cat(3.89, kGroundY, direction: -1),
      ObjectSpec.button(
        3.04,
        kGroundY - 0.12,
        id: 's34',
        linkedTargetId: 'g34',
      ),
      ObjectSpec.gate(2.39, kGroundY - 0.8, id: 'g34'),
      ObjectSpec.target(0.45, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 35 – Plank After the Drop  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     plank_1 · platform_2 · ramp_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 35,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'Plank After the Drop',
    hint:
        'Topple the high row so the ball lands on the plank, not straight into the gap.',
    theme: oceanTheme,
    baseReward: _reward + 80,
    generationTemplate: 'plank-after-drop',
    generationDifficulty: 15,
    complexityScore: 15,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
      'plank_1',
    },
    design: const LevelDesignSpec(
      idea: 'Box starter topples the upper domino chain; ball rolls off the '
          'platform edge and falls onto an angled plank below. The plank redirects '
          'the ball across a gap onto a lower platform where a ramp sends it to the target.',
      intendedTapIds: ['box_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1', 'plank_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'plank_1', 'ramp_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly sends it straight down and it '
          'misses the plank entirely. Why does the FULL chain place the ball '
          "over the plank's catch zone?",
      complexity: ['plank_loading', 'vertical_transfer', 'ramp_redirect'],
    ),
    objects: [
      ObjectSpec.platform(2.2, 7.2, 4.2),
      ObjectSpec.box(0.8, 7.2, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: 7.2,
        count: 4,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.6, 7.2),
      ObjectSpec.plank(5.2, 10.3, length: 2.4, angle: -0.12),
      ObjectSpec.platform(7.4, 10.8, 3.0),
      ObjectSpec.ramp(6.5, 12.0, 2.2, angle: 0.25),
      ObjectSpec.target(6.1, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 36 – Ramp Choice  [TUNE – Phase 3: ramp-fork-choice]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..4 · ball_1 ·
  //                     ramp_1 · s36 · g36 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 36,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Ramp Choice',
    hint:
        'The ramp sends the ball down to the lower lane; tapping the ball directly misses the switch.',
    theme: volcanoTheme,
    baseReward: _reward + 100,
    generationTemplate: 'ramp-fork-choice',
    generationDifficulty: 16,
    complexityScore: 16,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The domino row topples rightward into the ball; the ball rolls across '
          'the button to open the gate, and continues through the gate to the target. '
          'Tapping the ball directly drops it down the ramp and away from the switch.',
      intendedTapIds: ['domino_1', 'domino_3'],
      decoys: ['domino_2', 'domino_4', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1',
        's36', 'g36', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly sends it down the lower ramp, '
          'missing the button entirely so the gate stays shut. Why does starting '
          'from the dominoes keep the ball on track?',
      complexity: ['gate_dependency', 'ramp_deflection', 'ordering'],
    ),
    objects: [
      ObjectSpec.platform(4.5, 7.3, 7.6),
      ObjectSpec.domino(2.2, 7.3, starter: true, push: const Offset(0.38, 0)),
      ObjectSpec.domino(2.8, 7.3),
      ObjectSpec.domino(3.4, 7.3),
      ObjectSpec.domino(4.0, 7.3),
      ObjectSpec.ball(4.8, 7.3),
      ObjectSpec.ramp(5.2, 9.6, 2.8, angle: 0.35),
      ObjectSpec.button(5.9, 7.18, id: 's36', linkedTargetId: 'g36'),
      ObjectSpec.gate(7.1, 6.5, h: 1.6, id: 'g36'),
      ObjectSpec.target(8.3, 7.3, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 37 – Open Before Impact  [RETAIN – Phase 1: tapCandidates + LevelDesignSpec]
  // Auto-generated IDs: plank_1(starter) · s37(button, explicit) · g37(gate, explicit) ·
  //                     domino_1..4 · ball_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 37,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Open Before Impact',
    hint:
        'Tap the plank to press the switch; the row cannot pass the gate until it opens.',
    theme: neonTheme,
    baseReward: _reward + 120,
    generationTemplate: 'plank-switch-sequence',
    generationDifficulty: 17,
    complexityScore: 17,
    tapCandidates: const {
      'plank_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'Plank starter is pushed rightward and sweeps into the button, '
          'opening the gate. Then the domino chain (to the right of the plank) '
          'falls rightward, ball rolls through the now-open gate to the target.',
      intendedTapIds: ['plank_1'],
      decoys: ['domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1'],
      chain: [
        'plank_1', 's37', 'g37',
        'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping a domino sends the ball forward but the gate is '
          'still shut and blocks it. Why must the PLANK go first?',
      complexity: ['gate_dependency', 'ordering', 'plank_activation'],
    ),
    objects: [
      ObjectSpec.plank(
        3.5,
        kGroundY,
        length: 2.0,
        starter: true,
        push: const Offset(30, 0),
      ),
      ObjectSpec.button(
        4.35,
        kGroundY - 0.12,
        id: 's37',
        linkedTargetId: 'g37',
      ),
      ObjectSpec.gate(7.5, kGroundY - 0.8, h: 1.6, id: 'g37'),
      ...ObjectSpec.dominoRow(
        fromX: 4.8,
        surfaceY: kGroundY,
        count: 4,
        spacing: 0.55,
      ),
      ObjectSpec.ball(7.0, kGroundY),
      ObjectSpec.target(8.3, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 38 – Ramp Switchback  [TUNE – Phase 3: ramp-switchback]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     ramp_1 · domino_5..8 · s38 · g38 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 38,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Ramp Switchback',
    hint:
        'Start on the raised right lane; the ramp redirects the fall into the lower domino run.',
    theme: workshopTheme,
    baseReward: _reward + 140,
    generationTemplate: 'ramp-switchback',
    generationDifficulty: 18,
    complexityScore: 18,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
      'domino_5',
      'domino_6',
      'domino_7',
      'domino_8',
    },
    design: const LevelDesignSpec(
      idea: 'The upper right platform chain pushes the ball leftward; the ramp '
          'redirects the fall down into the lower ground domino run, which presses '
          'the switch to open the gate and reach the target.',
      intendedTapIds: ['box_1', 'domino_1', 'domino_5'],
      decoys: [
        'domino_2', 'domino_3', 'domino_4', 'ball_1',
        'domino_6', 'domino_7', 'domino_8',
      ],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4', 'ball_1',
        'ramp_1', 'domino_5', 'domino_6', 'domino_7', 'domino_8',
        's38', 'g38', 'target_1',
      ],
      reasoningPrompt: 'Why does starting the lower run from domino_5 succeed in opening '
          'the gate, while starting from domino_6 or ball_1 fails?',
      complexity: ['vertical_transfer', 'direction_reversal', 'gate_dependency'],
    ),
    objects: [
      ObjectSpec.platform(6.0, 10.0, 4.8),
      ObjectSpec.box(7.9, 10.0, starter: true, push: const Offset(-14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 7.3,
        surfaceY: 10.0,
        count: 4,
        spacing: -0.52,
      ),
      ObjectSpec.ball(5.0, 10.0),
      ObjectSpec.ramp(3.7, 12.2, 2.4, angle: -0.3),
      ...ObjectSpec.dominoRow(
        fromX: 2.8,
        surfaceY: kGroundY,
        count: 4,
        spacing: -0.55,
      ),
      ObjectSpec.button(1.3, kGroundY - 0.12, id: 's38', linkedTargetId: 'g38'),
      ObjectSpec.gate(0.75, kGroundY - 0.8, h: 1.6, id: 'g38'),
      ObjectSpec.target(0.45, kGroundY, radius: 0.48),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 39 – Up, Across, Back  [TUNE – Phase 4: up-across-back]
  // Auto-generated IDs: platform_1 · box_1(starter) · domino_1..4 · ball_1 ·
  //                     jumper_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 39,
    tapChoiceProfile: TapChoiceProfile.narrow,
    name: 'Up, Across, Back',
    hint:
        'The ball lands on the spring and must ride the launch arc back to the target.',
    theme: oceanTheme,
    baseReward: _reward + 160,
    generationTemplate: 'up-across-back',
    generationDifficulty: 19,
    complexityScore: 19,
    tapCandidates: const {
      'box_1',
      'domino_1',
      'domino_2',
      'domino_3',
      'domino_4',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'The platform box drives the domino row rightward into the ball; the '
          'ball drops off the shelf onto the ground jumper, which launches it upward '
          'and back across to the target.',
      intendedTapIds: ['box_1', 'domino_1', 'domino_3'],
      decoys: ['domino_2', 'domino_4', 'ball_1'],
      chain: [
        'box_1', 'domino_1', 'domino_2', 'domino_3', 'domino_4',
        'ball_1', 'jumper_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping the ball directly results in insufficient momentum, '
          'causing it to drop straight down and miss the jumper pad. Why does the '
          'box starter provide the required launch arc?',
      complexity: ['vertical_transfer', 'jumper_launch', 'arc_trajectory'],
    ),
    objects: [
      ObjectSpec.platform(2.4, 10.3, 4.0),
      ObjectSpec.box(0.8, 10.3, starter: true, push: const Offset(14, 0)),
      ...ObjectSpec.dominoRow(
        fromX: 1.4,
        surfaceY: 10.3,
        count: 4,
        spacing: 0.5,
      ),
      ObjectSpec.ball(3.7, 10.3),
      ObjectSpec.jumper(6.0, kGroundY, direction: -1, launchSpeed: 1.2),
      ObjectSpec.target(6.0, kGroundY, radius: 0.65),
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // Level 40 – One Tap, Three Consequences  [TUNE/REDESIGN – Phase 5 (Master Chain)]
  // Auto-generated IDs: platform_1 · domino_1(starter) · domino_2..3 · ball_1 ·
  //                     s40 · g40 · dog_1 · cat_1 · target_1
  // ─────────────────────────────────────────────────────────────────────────
  LevelConfig(
    id: 40,
    tapChoiceProfile: TapChoiceProfile.exact,
    name: 'One Tap, Three Consequences',
    hint:
        'Predict the order: the ball presses the switch, clears the gate, then reaches the target.',
    theme: neonTheme,
    baseReward: _reward + 180,
    generationTemplate: 'three-consequence-finale',
    generationDifficulty: 20,
    complexityScore: 20,
    tapCandidates: const {
      'domino_1',
      'domino_2',
      'domino_3',
      'ball_1',
    },
    design: const LevelDesignSpec(
      idea: 'A single tap on the starter domino triggers a three-consequence chain: '
          'domino momentum rolls the ball across the switch to open the gate, '
          'the ball clears the gate to trigger the dog, and the dog-cat relay reaches the target.',
      intendedTapIds: ['domino_1'],
      decoys: ['domino_2', 'domino_3', 'ball_1'],
      chain: [
        'domino_1', 'domino_2', 'domino_3', 'ball_1',
        's40', 'g40', 'dog_1', 'cat_1', 'target_1',
      ],
      reasoningPrompt: 'Tapping later dominoes or the ball directly lacks the momentum '
          'needed to depress the button switch, leaving the gate shut. Why is the full '
          'domino run required to clear the gate for the pet relay?',
      complexity: ['momentum_accumulation', 'switch_gate_dependency', 'pet_relay', 'exact_solution'],
    ),
    objects: [
      ObjectSpec.platform(4.5, 8.1, 8.0),
      ObjectSpec.domino(1.8, 8.1, starter: true, push: const Offset(0.42, 0)),
      ObjectSpec.domino(2.5, 8.1),
      ObjectSpec.domino(3.2, 8.1),
      ObjectSpec.ball(4.1, 8.1),
      ObjectSpec.button(4.85, 7.85, id: 's40', linkedTargetId: 'g40'),
      ObjectSpec.gate(5.5, 7.3, h: 1.6, id: 'g40'),
      ObjectSpec.dog(6.3, 8.1, direction: 1),
      ObjectSpec.cat(7.2, 8.1, direction: 1),
      ObjectSpec.target(8.3, 8.1, radius: 0.48),
    ],
  ),
];
