# TapChain — Additional Object Types for Level Generator

## Goal

Expand the TapChain object library so the procedural level generator can use these new objects alongside the existing objects:

1. CAT
2. DOG
3. RAMP
4. BUTTON / SWITCH
5. GATE
6. PLANK

Do NOT rewrite or replace existing Levels 1–10.

---

## 1. CAT 🐱

A triggered character object.

### Behaviour
- Starts idle.
- When hit by a suitable physics object, such as a ball, it becomes startled.
- It then runs across its surface in a defined direction.
- The running cat can interact with other objects, especially a button/switch.
- Direction should be configurable: left or right.
- Simple animation states: idle, startled, running.
- Movement should be deterministic enough for physics validation.

Example:

```text
BALL → CAT → CAT RUNS → BUTTON → GATE → TARGET
```

---

## 2. DOG 🐶

A triggered character object.

### Behaviour
- Starts idle.
- When triggered/hit, it starts running.
- Initially support a configurable running direction.
- It can interact with buttons, gates or other suitable objects.
- Simple idle/running animation states are sufficient.
- Keep the first implementation deterministic and simple.

Example:

```text
BALL → DOG → DOG RUNS → BUTTON → GATE → TARGET
```

---

## 3. RAMP 🛝

A physical ramp for changing an object's trajectory.

### Behaviour
- Configurable position, length/width and angle.
- Ball can roll/slide down it.
- Use real Forge2D physics.
- Generator must be able to vary orientation.

Example:

```text
DOMINO → BALL
           ↓
          RAMP
           ╲
            ╲
             → BALL → TARGET
```

---

## 4. BUTTON / SWITCH 🔘

A trigger that changes another object's state.

### Behaviour
- Starts inactive.
- When pressed/hit, becomes active.
- Activation can trigger a linked object, initially most importantly a GATE.
- Support a configurable linked target/reference.
- Clear visual state change: inactive → active.
- Should be usable by characters as well as physics objects where practical.

Example:

```text
BALL → BUTTON
          ↓
        GATE OPENS
          ↓
         BALL
          ↓
        TARGET
```

Conceptually support links such as:

```text
buttonId → gateId
```

---

## 5. GATE 🚪

A physical barrier that blocks or releases an object/path.

### Behaviour
- Starts closed.
- Blocks the relevant path while closed.
- Opens when its linked button/switch activates.
- Once open, the chain reaction can continue.
- Opening should be visually obvious.
- Prefer a simple deterministic opening animation.
- Gate state must affect actual collision/physics, not just visuals.

Example:

```text
DOMINO → BUTTON
           ↓
       GATE OPENS
           ↓
         BALL
           ↓
        TARGET
```

---

## 6. PLANK 🪵

A physical plank that can rotate, fall or act as a bridge.

### Behaviour
- Uses real Forge2D physics.
- Can be hit by a ball, box or other suitable object.
- Can rotate/fall when sufficiently impacted.
- Can bridge a gap or create a path for another object.
- Position, length and angle should be configurable.

Example:

```text
BALL → PLANK
          ↓
       PLANK FALLS
          ↓
         BALL
          ↓
        TARGET
```

Another possible use:

```text
      BALL
       ↓
   ─────────
      PLANK
         ╲
          ╲
           → BALL
```

---

# Generator Integration

All six objects must become available to the procedural generator.

The generator must understand their behaviours, not merely place sprites.

Examples:

```text
BALL → CAT → BUTTON → GATE → TARGET
```

and:

```text
DOMINO → BALL → RAMP → BALL → PLANK → TARGET
```

The generator should eventually vary, where applicable:

- position
- orientation
- direction
- spacing
- linked objects
- trigger relationships
- platform placement
- difficulty contribution

---

# Object Meaning for Difficulty

Each object should represent a different kind of reasoning:

```text
CAT       → triggered character movement
DOG       → triggered character movement
RAMP      → trajectory / momentum
BUTTON    → cause-and-effect
GATE      → sequencing / blocking
PLANK     → rotation / structural physics
```

Do not simply count these as extra objects.

For example:

```text
BUTTON + GATE
```

creates a sequencing puzzle,

while:

```text
RAMP + BALL
```

creates a trajectory puzzle,

and:

```text
CAT + BUTTON
```

creates a character-triggered chain.

---

# Implementation Rules

Before coding:

1. Inspect how the current objects are implemented.
2. Identify existing base/component patterns.
3. Follow existing conventions.
4. Reuse existing collision/event handling.
5. Keep the new objects compatible with the planned level generator and physics validator.

Do NOT:

- Rewrite Levels 1–10.
- Replace existing physics objects.
- Change the core one-tap gameplay.
- Add backend/network dependencies.
- Add AI/LLM dependencies.
- Build unnecessarily complex animation systems.

Implement the simplest reliable version of each object first.

Then make each object usable by the generator and physics validator.

Only after the basic behaviours work should more sophisticated variations be added.
