# Game Design Document: Runes of Ruin

## 1. Game Overview

"Runes of Ruin" is a fast-paced, third-person endless runner for mobile and desktop, set in an ancient, crumbling temple environment. Players control an adventurer automatically running forward, navigating treacherous paths, collecting valuable runes (coins), and avoiding deadly traps. The game emphasizes skill mastery, quick reflexes, and a satisfying progression system.

## 2. Core Loop

The core gameplay loop is designed for high retention and addictive "one more run" sessions:

1.  **Run**: The player character automatically moves forward through a procedurally generated ancient temple path.
2.  **Collect**: Players swipe to collect glowing runes (coins) scattered across the path and power-ups that grant temporary advantages.
3.  **Dodge**: Players must react quickly to incoming obstacles by swiping left/right to change lanes, swiping up to jump over low obstacles, or swiping down to slide under high obstacles.
4.  **Die**: Collision with any obstacle or falling off the path immediately ends the current run.
5.  **Upgrade**: After dying, players return to the main menu where they can spend collected runes on permanent power-up upgrades, new characters, or cosmetic items.
6.  **Restart**: Players initiate a new run, aiming to beat their previous high score, complete missions, and collect more runes.

## 3. Input Mapping

Input responsiveness is paramount. Actions must be instantaneous with minimal to no perceptible lag.

### 3.1. Mobile (Touch/Swipe)

*   **Swipe Left**: Move character to the adjacent left lane.
*   **Swipe Right**: Move character to the adjacent right lane.
*   **Swipe Up / Tap**: Character performs a jump.
*   **Swipe Down**: Character performs a slide.

### 3.2. Desktop (Keyboard for Testing)

*   **Left Arrow**: Move character to the adjacent left lane.
*   **Right Arrow**: Move character to the adjacent right lane.
*   **Up Arrow / Spacebar**: Character performs a jump.
*   **Down Arrow / Left Shift**: Character performs a slide.

## 4. Camera Angle & FOV

A third-person, slightly elevated, behind-the-back camera will be used to provide optimal visibility and a strong sense of speed.

*   **Angle**: Camera is angled downwards by **12 degrees**.
*   **Distance**: Positioned **4 units behind** and **1.5 units above** the character's head.
*   **FOV**: A **65-degree vertical FOV** (adjusted for aspect ratio) will be used. This balances clear visibility of upcoming threats with maintaining a strong sense of speed and immersion. Dynamic FOV adjustments during sharp turns (slight increase) or special actions (e.g., Vine Swing - slight zoom out) will be explored.

## 5. Speed Progression Formula

The game's speed increases gradually to provide a smooth difficulty curve and maintain challenge.

*   **Initial Speed**: 10 units/second (u/s)
*   **Speed Increase**: +5% of the initial speed for every 500 meters traveled.
*   **Maximum Speed**: Capped at 30 units/second (u/s) to ensure the game remains playable, albeit extremely challenging.

**Formula**: `CurrentSpeed = InitialSpeed + (InitialSpeed * 0.05 * floor(Distance / 500))`

**Example Progression:**

*   **0 - 499m**: 10 u/s
*   **500 - 999m**: 10 + (10 * 0.05 * 1) = 10.5 u/s
*   **1000 - 1499m**: 10 + (10 * 0.05 * 2) = 11 u/s
*   **...**
