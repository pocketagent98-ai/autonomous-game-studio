# Player State Machine Specification (3D Endless Runner)

This document defines the states and transitions for the player character in a 3D endless runner game. The player's behavior is governed by a finite state machine, ensuring clear and predictable responses to input and game events.

---

## States

### 1. IDLE

*   **ID**: `IDLE`
*   **Entry Condition**: Game starts, player character is on the ground, no movement input detected.
*   **Input Triggers**:
    *   Forward movement input (e.g., `W`, Up Arrow, Joystick Up).
    *   Jump input (e.g., Spacebar, `A` button).
    *   Slide input (e.g., `S`, Down Arrow, `B` button).
*   **What Changes**:
    *   **Speed**: `0` (or very minimal for subtle breathing animation).
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `idle` animation.
*   **Exit Condition**:
    *   Forward movement input received.
    *   Jump input received.
    *   Slide input received.
    *   Collision with an obstacle.

### 2. RUNNING

*   **ID**: `RUNNING`
*   **Entry Condition**: Player receives forward movement input from `IDLE`, lands from `JUMPING`, finishes `SLIDING`, or recovers from `STUMBLE`.
*   **Input Triggers**:
    *   Jump input.
    *   Slide input.
    *   Turn Left input (e.g., `A`, Left Arrow).
    *   Turn Right input (e.g., `D`, Right Arrow).
    *   No forward movement input (less common in endless runners, but for completeness).
*   **What Changes**:
    *   **Speed**: Constant `run_speed` (e.g., `10` units/second) in the forward direction.
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `run` animation.
*   **Exit Condition**:
    *   Jump input received.
    *   Slide input received.
    *   Turn Left input received.
    *   Turn Right input received.
    *   Collision with an obstacle.
    *   Player falls off the track.
    *   (Optional) No forward movement input received.

### 3. JUMPING

*   **ID**: `JUMPING`
*   **Entry Condition**: Player receives jump input while in `IDLE`, `RUNNING`, or (optionally) `SLIDING`. Player is on the ground at the start of the jump.
*   **Input Triggers**:
    *   (No direct input triggers for exiting, primarily event-driven).
*   **What Changes**:
    *   **Speed**: Maintains horizontal `run_speed`, adds vertical `jump_force` (e.g., `8` units/second upwards), then affected by gravity.
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `jump_start` -> `jump_loop` (at apex) -> `jump_land`.
*   **Exit Condition**:
    *   Player lands on the ground.
    *   Collision with an airborne obstacle.
    *   Player falls off the track.

### 4. SLIDING

*   **ID**: `SLIDING`
*   **Entry Condition**: Player receives slide input while in `IDLE` or `RUNNING`.
*   **Input Triggers**:
    *   Slide duration timer expires.
    *   (Optional) Jump input (to cancel slide early).
*   **What Changes**:
    *   **Speed**: Maintains horizontal `run_speed`.
    *   **Collision Capsule Height**: Reduced (`slide_height`, e.g., `0.9` units).
    *   **Animation**: `slide` animation.
    *   **Timer**: `slide_duration` (e.g., `0.8` seconds) starts.
*   **Exit Condition**:
    *   `slide_duration` ends and player is on the ground.
    *   (Optional) Jump input received.
    *   Collision with an obstacle (especially a high one).
    *   Player falls off the track.

### 5. TURNING_LEFT

*   **ID**: `TURNING_LEFT`
*   **Entry Condition**: Player receives turn left input while in `RUNNING`.
*   **Input Triggers**:
    *   Turn animation/movement completion.
*   **What Changes**:
    *   **Speed**: Maintains horizontal `run_speed`, applies lateral movement/rotation to shift lanes.
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `turn_left` animation.
    *   **Player Position**: Moves to the adjacent left lane.
*   **Exit Condition**:
    *   Turn animation/movement completes, and player is centered in the new lane.
    *   Collision with an obstacle during the turn.
    *   Player falls off the track.

### 6. TURNING_RIGHT

*   **ID**: `TURNING_RIGHT`
*   **Entry Condition**: Player receives turn right input while in `RUNNING`.
*   **Input Triggers**:
    *   Turn animation/movement completion.
*   **What Changes**:
    *   **Speed**: Maintains horizontal `run_speed`, applies lateral movement/rotation to shift lanes.
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `turn_right` animation.
    *   **Player Position**: Moves to the adjacent right lane.
*   **Exit Condition**:
    *   Turn animation/movement completes, and player is centered in the new lane.
    *   Collision with an obstacle during the turn.
    *   Player falls off the track.

### 7. STUMBLE

*   **ID**: `STUMBLE`
*   **Entry Condition**: Player collides with a minor obstacle (e.g., small rock, low barrier) that causes a temporary setback but not immediate death.
*   **Input Triggers**:
    *   Stumble animation/recovery duration ends.
*   **What Changes**:
    *   **Speed**: Temporarily reduced (`stumble_speed`, e.g., `5` units/second).
    *   **Collision Capsule Height**: Normal (e.g., `1.8` units).
    *   **Animation**: `stumble` animation.
    *   **Player Control**: Temporarily disabled or limited.
    *   **Timer**: `stumble_duration` (e.g., `1.5` seconds) starts.
*   **Exit Condition**:
    *   `stumble_duration` ends.
    *   Collision with another obstacle while stumbling.
    *   Player falls off the track while stumbling.

### 8. DEAD

*   **ID**: `DEAD`
*   **Entry Condition**: Player collides with a major obstacle (e.g., wall, train), falls off the track, or takes a second hit while in `STUMBLE` state.
*   **Input Triggers**: None (this is a terminal state for the current run).
*   **What Changes**:
    *   **Speed**: `0`.
    *   **Collision Capsule Height**: Irrelevant (often replaced by ragdoll physics or a fixed death pose).
    *   **Animation**: `death` animation (or ragdoll activation).
    *   **Game State**: Triggers "Game Over" sequence/screen.
*   **Exit Condition**: None (requires game restart or return to main menu).

---

## Transition Table

| Current State    | Trigger                          | Next State      | Notes                                                              |
| :--------------- | :------------------------------- | :-------------- | :