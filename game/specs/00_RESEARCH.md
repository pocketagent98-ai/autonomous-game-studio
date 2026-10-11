# Pre-Production Research Brief: Endless Runner

## 1. Core Loop & Player Retention (Temple Run / Subway Surfers)

The core loop is elegantly simple: **Run > Avoid Obstacles / Collect Coins > Die > Upgrade / Retry.**

**Retention Drivers:**
*   **Skill Mastery & High Score Chase:** Players are driven by the desire to improve their personal best, master obstacle patterns, and climb leaderboards. The "one more run" impulse is powerful.
*   **Short Session Length:** Runs are quick, making the game ideal for brief play sessions, fitting seamlessly into daily routines.
*   **Progression Systems:**
    *   **Character Unlocks:** Cosmetic and sometimes gameplay-altering characters provide aspirational goals.
    *   **Power-Up Upgrades:** Persistent upgrades to magnets, shields, coin multipliers, etc., give a tangible sense of growth and make subsequent runs easier/more rewarding.
    *   **Mission/Challenge Systems:** Daily/weekly challenges or tiered objectives provide specific goals beyond just running, offering structured progression and rewards.
*   **Addictive Flow State:** The increasing speed and constant demand for quick reflexes can induce a "flow state" where players are fully immersed and time seems to disappear.

## 2. Camera Angle & FOV in Top Endless Runners

Top endless runners (e.g., Temple Run 2, Subway Surfers, Minion Rush) typically employ a **third-person, slightly elevated, behind-the-back camera.**

*   **Angle:** The camera is usually angled downwards by about 10-15 degrees, providing a clear view of the immediate path ahead and upcoming obstacles, while still showcasing the character.
*   **Distance:** It's close enough to feel connected to the character but far enough to give ample reaction time for lane changes, jumps, and slides. A typical distance might be 3-5 units behind and 1-2 units above the character.
*   **FOV (Field of View):** A moderate FOV (e.g., 60-75 degrees vertical, depending on aspect ratio) is crucial.
    *   **Too Narrow:** Feels claustrophobic, limits peripheral vision, and makes sudden obstacles feel unfair.
    *   **Too Wide:** Can make the character feel small, distort perspective, and reduce the sense of speed.
    *   The optimal FOV balances visibility of upcoming threats with a strong sense of speed and immersion. It's often dynamically adjusted slightly during turns or special actions.

## 3. Common Player Complaints

*   **Input Lag:** The most critical complaint. Any perceptible delay between a swipe/tap and the character's action is infuriating and leads to perceived "unfair" deaths. Input responsiveness must be pixel-perfect and instantaneous.
*   **Unfair Obstacle Spawning:**
    *   **"Blind Corners":** Obstacles appearing immediately after a turn with no time to react.
    *   **"Wall of Death":** An unavoidable sequence of obstacles that requires a specific, untelegraphed action (e.g., jump *then* slide immediately) that's impossible to predict.
    *   **Solutions:** Ensure sufficient "look-ahead" distance for procedural generation, provide clear visual cues for upcoming turns/obstacles, and test sequences rigorously for unavoidable scenarios.
*   **Difficulty Spikes:** Sudden, untelegraphed increases in speed or complex obstacle patterns that feel arbitrary rather than a natural progression. The difficulty curve should be smooth, with new mechanics or combined obstacle patterns introduced gradually.

## 4. Three Original Twists

1.  **Dynamic Environmental Manipulation:** Instead of merely avoiding, players can *interact* with certain environmental elements to clear paths or gain advantages. For example:
    *   **"Boulder Push":** Swipe into a crumbling pillar to push it into an adjacent lane, clearing your path but potentially creating a temporary hazard for a split second in the next lane.
    *   **"Vine Swing":** A timing-based jump to latch onto a passing vine, swinging over a section of obstacles, but requiring a precise release. This adds a layer of mini-game interaction to movement.
2.  **Momentum-Based "Flow State" Ability:** Introduce a secondary meter, "Flow," that builds up by successfully chaining dodges, jumps, and slides without hitting obstacles. When full, players can activate a short burst of a unique movement ability (e.g., a temporary "Ghost Dash" that phases through minor obstacles, or a "Vertical Boost" that launches the character onto a higher, coin-rich path) offering a strategic choice and a powerful reward for skilled play.
3.  **Persistent "Relic Hunt" Meta-Game:** Beyond coins and high scores, specific runs can feature procedurally placed "Relic Fragments." Collecting a full set of fragments (across multiple runs) unlocks unique lore entries, character backstory segments, or access to new "challenge zones" within the endless track, providing a longer-term, narrative-driven objective and a sense of discovery that ties runs together beyond just score accumulation.