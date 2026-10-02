# TapChain — Procedural Level Generator Implementation Brief

## Purpose

Build a **procedural level generator + physics validator** for TapChain.

TapChain is a Flutter + Flame + Forge2D Android puzzle game. The player gets 60 seconds to study a physics puzzle, taps exactly once, and the physics chain reaction plays automatically. The objective is to create valid, interesting chain-reaction puzzles rather than merely random object layouts.

The generator must integrate with the existing TapChain architecture and must NOT break the existing hand-authored levels.

---

# 1. Core Design Principle

Do NOT build a purely random level generator.

Build a three-stage system:

```text
Logical Puzzle
      ↓
Physical Layout
      ↓
Physics Validation
      ↓
Valid Level
```

The generator should first decide **what should happen**, then decide **where objects should be placed**, then use the actual game physics to determine whether the resulting puzzle works.

The long-term goal is:

> Generate many candidate levels automatically, reject invalid/uninteresting candidates, and allow the developer to curate the best ones.

---

# 2. Preserve Existing Gameplay

The existing game mechanics are authoritative.

Do not redesign the core gameplay loop.

Current intended loop:

```text
LOOK → THINK → TAP → WATCH → REWARD
```

Rules:

- Player has 60 seconds to study the puzzle.
- Player taps exactly once.
- Timer stops when the tap happens.
- Physics reaction happens automatically.
- Remaining time affects the coin multiplier.
- Successful levels award coins.
- Failed chains can be retried.

The generator must work with the existing implementation rather than creating a parallel physics system.

---

# 3. Existing Object Types

The current level set uses concepts including:

- Domino
- Ball
- Box
- Platform
- Angled platform
- Jumper / spring
- Target

The generator should use existing implementations wherever possible.

Do NOT duplicate physics implementations.

For example:

```text
Generated Level
      ↓
Existing Level/Object Factory
      ↓
Existing Flame/Forge2D objects
```

---

# 4. Recommended Architecture

Introduce a clean abstraction:

```text
LevelDefinition
 ├── metadata
 ├── logical puzzle
 ├── physical objects
 └── difficulty information
```

Then:

```text
Generator
    ↓
LevelDefinition
    ↓
Existing LevelLoader
    ↓
Existing Flame / Forge2D implementation
```

The normal game should not care whether a level was:

- hand-authored, or
- procedurally generated.

Both must ultimately produce the same type of playable level.

---

# 5. Logical Puzzle Graph

Create a logical representation of the intended chain reaction.

Example:

```text
START
  ↓
DOMINO RUN
  ↓
BALL
  ↓
DROP
  ↓
SPRING
  ↓
UPPER PLATFORM
  ↓
DOMINO RUN
  ↓
BALL
  ↓
TARGET
```

This is more important than coordinates.

The logical graph should describe:

- starter
- interactions
- chain order
- optional branches
- target
- decoys
- stages/mechanics

Suggested conceptual node types:

```dart
StarterNode
DominoRunNode
BallNode
BoxNode
DropNode
SpringNode
PlatformNode
TargetNode
DecoyNode
```

Exact class names may differ to fit the existing codebase.

---

# 6. Chain Templates

Do not initially generate completely arbitrary graphs.

Use templates plus procedural variation.

Initial templates:

## Template A — Simple Relay

```text
DOMINO → BALL → DOMINO → TARGET
```

## Template B — Drop

```text
DOMINO → BALL
           ↓
       LOWER ROW
           ↓
         TARGET
```

## Template C — Spring

```text
DOMINO → BALL
           ↓
         SPRING
           ↑
     UPPER PLATFORM
           ↓
        TARGET
```

## Template D — Split / Branch

```text
             → BALL → TARGET A
            /
START → DOMINO
            \
             → BALL → TARGET B
```

## Template E — False Path

```text
             → DECOY / DEAD END
            /
START → DOMINO
            \
             → CORRECT PATH → TARGET
```

Start with A-C. Add D-E only after the basic generator and validator are stable.

---

# 7. Procedural Layout Generation

Convert the logical graph into the existing game's coordinate system.

The layout generator should control:

- platform positions
- platform widths
- platform heights
- domino spacing
- domino direction
- ball positions
- drop distances
- spring positions
- angled-platform angles
- target positions
- horizontal direction
- vertical progression
- margins/boundaries

Do not hard-code a single layout for every template.

For example, a relay can vary:

```text
left → right
right → left
upper → lower
lower → upper
```

while remaining logically equivalent.

---

# 8. Difficulty System

Difficulty must be an explicit input.

Example:

```dart
DifficultyProfile(
  difficulty: 7,
  chainLength: ...,
  platformCount: ...,
  ballCount: ...,
  springCount: ...,
  directionChanges: ...,
  verticalDrops: ...,
  decoys: ...,
  timingDependency: ...,
);
```

The exact implementation should be adapted to the existing codebase.

Suggested progression:

### Difficulty 1–2
Simple domino chains.

### Difficulty 3–4
Domino + ball + drop.

### Difficulty 5–6
Multiple platforms, balls, springs, and direction changes.

### Difficulty 7–8
Branches, decoys, prediction, optional interactions.

### Difficulty 9–10
Complex chains, multiple interactions, timing dependencies, multiple targets or objects that must NOT be triggered.

Do not simply make levels harder by adding more objects.

Difficulty should eventually measure **prediction complexity**, not just object count.

---

# 9. Candidate Generation

The generator should produce candidates.

Example:

```text
Generate 100 candidates
        ↓
Geometry validation
        ↓
Logical validation
        ↓
Physics simulation
        ↓
Difficulty evaluation
        ↓
Reject bad candidates
        ↓
Return valid candidates
```

The generator should support something conceptually like:

```dart
generateLevels(
  count: 20,
  difficulty: 6,
  template: TemplateType.auto,
  theme: ThemeType.neon,
);
```

Exact API should follow the existing architecture.

---

# 10. Geometry Validation

Before running physics, reject obviously invalid levels.

Check:

- Objects outside playable bounds.
- Target outside reachable screen/world area.
- Platform overlap.
- Object overlap where overlap is not intentional.
- Dominoes too far apart to interact.
- Dominoes placed incorrectly relative to platforms.
- Ball positioned outside platform.
- Spring/jumper positioned incorrectly.
- Impossible drop distances.
- Target unreachable by construction.
- Excessively cramped layouts.

The validator should return useful diagnostics.

Example:

```text
INVALID LEVEL

Reason:
Domino #5 is 1.42 world units from Domino #4.
Maximum supported spacing: 0.75.
```

Do not silently discard all failures without a reason.

---

# 11. Physics Validation — MOST IMPORTANT

Use the game's actual physics implementation.

Do not create a fake mathematical approximation if the existing Forge2D simulation can be reused.

Ideal flow:

```text
Generate candidate
      ↓
Create level in physics world
      ↓
Trigger starter automatically
      ↓
Run simulation
      ↓
Track collisions/interactions
      ↓
Track target state
      ↓
Determine success/failure
```

The validator should answer:

1. Did the starter activate?
2. Did the intended chain begin?
3. Did required interactions happen?
4. Did the target get hit?
5. Did the chain stop unexpectedly?
6. Did a required object fail to activate?
7. Did an unintended object activate?
8. Did the simulation settle?
9. Did it settle within a reasonable time?

The exact implementation must use the existing game's collision/event APIs where possible.

---

# 12. Simulation Safety

The validator must not interfere with normal gameplay.

Prefer an isolated/headless/test physics world if the existing architecture permits it.

If not, create a dedicated simulation mode.

Never let generator validation modify:

- player progress
- coins
- saved level state
- achievements
- normal game timer
- production analytics

Generated validation should be deterministic where possible.

---

# 13. Deterministic Seeds

Every generated level should have a seed.

Example:

```text
seed = 847291
```

Given the same:

- seed
- difficulty
- template
- generator version

the generator should ideally produce the same candidate.

This makes bugs reproducible.

Store:

```text
generatorVersion
seed
template
difficulty
```

with generated levels.

---

# 14. Difficulty Scoring

After generation and validation, calculate a complexity score.

Possible factors:

```text
Chain length
Number of dominoes
Number of balls
Number of platforms
Number of drops
Number of direction changes
Number of springs
Number of branches
Number of decoys
Timing dependency
Number of required interactions
```

Example diagnostic:

```text
LEVEL 37

Chain length:        11
Dominoes:             7
Balls:                2
Platforms:            3
Drops:                2
Direction changes:    3
Springs:              1
Decoys:               1

Complexity:          7.2 / 10
Physics:             PASS
```

The formula can evolve later.

---

# 15. Level Generator Tool

Eventually create a developer/debug screen.

Concept:

```text
╔════════════════════════════════╗
║       TAPCHAIN GENERATOR       ║
╠════════════════════════════════╣
║ Difficulty       [ 7 ]         ║
║ Template         [ AUTO ]      ║
║ Theme            [ NEON ]      ║
║                                ║
║ Chain Length     [ 8 - 12 ]    ║
║ Balls            [ 1 - 2 ]     ║
║ Platforms        [ 2 - 4 ]     ║
║ Springs          [ 0 - 1 ]     ║
║ Decoys           [ 0 - 2 ]     ║
║                                ║
║       [ GENERATE ]             ║
║                                ║
║ Physics:        PASS           ║
║ Difficulty:     6.8            ║
║ Seed:           829104         ║
║                                ║
║ [ SAVE LEVEL ]                 ║
╚════════════════════════════════╝
```

This does not need to be part of the production UI.

It can be a developer-only/debug feature.

---

# 16. Level Export

The generator should eventually support exporting a valid generated level into the same format used by normal levels.

Possible output:

```text
generated_level_027.dart
```

or preferably a data format if the existing architecture supports it:

```text
assets/levels/generated/level_027.json
```

Do not choose JSON merely for the sake of JSON. First inspect the current architecture and use the representation that creates the least duplication.

The important requirement is:

```text
Generator output
        =
Normal playable LevelDefinition
```

---

# 17. Backward Compatibility

Existing Levels 1–10 must continue working exactly as they do today.

Do not rewrite them unnecessarily.

The generator should be introduced alongside the existing levels.

Only refactor existing level definitions if the refactor is clearly safe and makes the architecture cleaner.

Run all existing tests after every major change.

---

# 18. Testing Strategy

Create tests for:

### Logical generation

- Valid starter exists.
- Valid target exists.
- Graph is connected.
- Required chain has no broken links.

### Geometry

- No invalid coordinates.
- Objects remain within bounds.
- Required objects have valid spacing.

### Determinism

Same seed → same logical layout.

### Difficulty

Generated difficulty stays within requested tolerance.

### Physics

Known-valid levels pass simulation.

Known-invalid levels fail simulation.

### Regression

All existing Levels 1–10 still load and play.

---

# 19. Development Order

Implement in this order.

## Phase 1 — Inspect

Before coding, inspect:

- Level model
- Level loader
- Level factory
- Domino implementation
- Ball implementation
- Box implementation
- Platform implementation
- Jumper implementation
- Target implementation
- Collision handling
- Win/fail handling
- Physics world setup
- Existing tests

Do not assume class names.

Document the existing architecture briefly before making changes.

---

## Phase 2 — Minimal abstraction

Create the smallest reusable `LevelDefinition` / generator-compatible representation possible.

Do not over-engineer.

Existing levels must still work.

---

## Phase 3 — Logical generator

Implement only:

```text
START
→ DOMINO RUN
→ BALL
→ TARGET
```

Generate simple valid logical chains.

---

## Phase 4 — Physical layout generator

Convert the logical chain into physical coordinates.

Start with simple horizontal layouts.

Then add:

- direction changes
- vertical drops
- multiple platforms

---

## Phase 5 — Physics validator

This is the critical milestone.

A generated level must be automatically tested with actual game physics.

Do not proceed to complicated procedural generation until this works reliably.

---

## Phase 6 — More mechanics

Add:

- spring
- angled platform
- multiple balls
- multiple domino runs

Only add each mechanic after it can be generated and validated independently.

---

## Phase 7 — Difficulty engine

Introduce difficulty 1–10.

Ensure higher difficulty is not simply:

```text
more objects
```

but increasingly involves:

```text
more prediction
more spatial reasoning
more interaction dependencies
```

---

## Phase 8 — Candidate generation

Generate 10–100 candidates at once.

Validate automatically.

Return only valid candidates.

---

## Phase 9 — Developer generator UI

Create the debug generator screen.

Allow manual control of:

- difficulty
- template
- theme
- chain length
- mechanics
- decoys

---

## Phase 10 — Export

Allow the developer to save a generated level into the normal game level format.

---

# 20. Important Non-Goals

Do NOT initially build:

- Online level generation
- Backend generation
- Supabase integration
- Multiplayer generation
- AI/LLM-generated levels
- Remote configuration
- Production analytics
- Infinite live generation for players

This is an offline developer tool first.

---

# 21. Important Engineering Principle

Do not try to build the complete generator in one pass.

Work incrementally.

After every major phase:

1. Run `flutter analyze`.
2. Run tests.
3. Build/run the game if possible.
4. Verify existing Levels 1–10.
5. Only then continue.

If something in the existing architecture conflicts with this design, **adapt the design to the existing codebase rather than forcing a rewrite.**

---

# 22. Definition of Done

The first usable version is complete when:

- Existing Levels 1–10 still work.
- A generator can create a simple puzzle.
- The puzzle is converted into real game objects.
- The game can run the generated puzzle.
- Physics simulation can automatically determine whether the target was reached.
- Invalid candidates are rejected.
- Generated levels have deterministic seeds.
- Difficulty can be specified.
- At least 10 valid candidates can be generated reliably.
- A developer can save/export a valid generated level.

Do NOT attempt hundreds of complex templates before this milestone.

---

# 23. Long-Term Goal

The eventual system should support requests conceptually like:

```text
Generate 20 levels
Difficulty: 6–7
Theme: Neon
Mechanics:
  - spring
  - two domino runs
No decoys
Exactly one target
```

and return a set of physically validated candidate puzzles.

The desired pipeline is:

```text
             PARAMETERS
                 ↓
        LOGICAL GENERATOR
                 ↓
        PHYSICAL LAYOUT
                 ↓
       GEOMETRY VALIDATOR
                 ↓
        FORGE2D SIMULATION
                 ↓
       DIFFICULTY ANALYSIS
                 ↓
        ┌────────┴────────┐
        │                 │
      FAIL              PASS
        │                 │
     DISCARD          CANDIDATE
                          ↓
                    HUMAN CURATION
                          ↓
                    FINAL LEVEL
```

The generator's job is **not to replace level design**.

Its job is to dramatically increase the number of interesting, physically valid candidates that the developer can choose from.

---

# Codex Instructions

When implementing this:

1. First inspect the entire repository relevant to the game.
2. Identify the current architecture and existing abstractions.
3. Do not invent duplicate physics systems.
4. Reuse existing Flame/Forge2D objects and collision mechanisms.
5. Make the smallest safe architectural changes necessary.
6. Implement the generator incrementally.
7. Keep existing levels working throughout.
8. Add tests before adding complex generation.
9. Prefer deterministic generation with seeds.
10. Make physics validation the central correctness check.
11. Do not add backend/network dependencies.
12. Do not add AI/LLM dependencies.
13. Do not change the game's core player experience.
14. Document important architectural decisions in code.
15. At the end of each phase, report:
    - files changed
    - what was implemented
    - tests run
    - remaining limitations
    - next recommended phase

Before writing substantial code, provide a short implementation plan based on the **actual repository structure** you inspected.

If an architectural decision is ambiguous, choose the option that:
- reuses existing code,
- minimizes duplication,
- preserves current levels,
- keeps generated levels compatible with hand-authored levels,
- and makes physics validation possible.

Do not rewrite the game merely to accommodate the generator.
