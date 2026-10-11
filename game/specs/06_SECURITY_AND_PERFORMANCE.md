# SECURITY & PERFORMANCE BUDGET

This budget outlines the critical technical constraints and strategies for developing the Endless Runner, ensuring a smooth, responsive, and fair player experience on mobile platforms.

## Performance Budget

To achieve a fluid and immersive experience on mobile devices, especially given the fast-paced nature of an endless runner, we must adhere to strict performance targets:

*   **Target Frame Rate:** 60 Frames Per Second (FPS)
*   **Maximum Draw Calls:** At most 50 draw calls per frame
*   **Maximum Polygon Count:** Under 100,000 polygons rendered per frame

### Performance Strategies

Achieving these targets requires disciplined optimization throughout development.

#### Object Pooling

**Explanation:** Object pooling is a design pattern that involves reusing pre-instantiated objects instead of repeatedly creating and destroying them. In an endless runner, new obstacles, coins, power-ups, and even environmental segments are constantly appearing and disappearing.

**Application:**
*   **Obstacles & Collectibles:** Instead of `queue_free()` and `instance()` for every obstacle or coin, we will maintain pools of these nodes. When an object goes off-screen or is collected, it's returned to its respective pool and marked as inactive. When a new object is needed, one is retrieved from the pool, reset to its initial state, and positioned.
*   **Environment Chunks:** The track segments themselves can be pooled. As the player progresses and a segment moves out of view behind them, it's returned to a pool and then reused to extend the track ahead.
*   **Benefits:** This significantly reduces garbage collection overhead and CPU spikes associated with node instantiation/destruction, leading to smoother frame rates and fewer hitches, directly addressing potential "input lag" issues caused by performance drops.

#### Visibility Ranges (Culling)

**Explanation:** Visibility culling refers to the process of preventing the rendering of objects that are not visible to the camera. This can be based on distance, frustum, or occlusion.

**Application:**
*   **Distance-Based Culling:** For an endless runner, only the immediate path ahead and a short distance behind the player needs to be rendered. Objects beyond a certain distance (e.g., 50-100 units) from the player's camera should be culled.
*   **Godot's `CullInstance` Nodes:** We can leverage Godot's `CullInstance` nodes or implement custom logic to manage the visibility of track segments, obstacles, and props. When a track segment is instantiated or moved into view, its `CullInstance` can be activated. When it moves out of range, it's deactivated.
*   **Benefits:** This drastically reduces the number of polygons sent to the GPU and the number of draw calls, as only relevant geometry is processed. This is crucial for staying within the <100,000 polygons and <50 draw calls budget.

#### Disabling Shadows

**Explanation:** Real-time dynamic shadows are computationally expensive, requiring additional render passes and complex calculations. Mobile GPUs are particularly sensitive to this overhead.

**Application:**
*   **Global Shadow Disablement:** For most lights in the scene, especially directional lights representing the sun, shadows will be disabled.
*   **Baked Lighting (Limited):** If environmental aesthetics demand some form of shadow, we might consider baking static shadows into textures for static environment elements (e.g., large structures), but this would be limited and pre-computed, not dynamic.
*   **No Dynamic Shadows:** Player characters, obstacles, and dynamic environmental elements will not cast real-time shadows. The fast-paced nature of the game means players are focused on immediate obstacles and movement, making the absence of dynamic shadows less impactful on gameplay immersion.
*   **Benefits:** Eliminating real-time shadows is one of the most effective ways to reduce GPU load and draw calls on mobile, directly contributing to maintaining a stable 60 FPS.

## Security Budget

While an endless runner typically doesn't involve server-side security for competitive play, local save file integrity is crucial to prevent players from tampering with their progress, high scores, and in-game currency. This directly impacts player retention and the perceived fairness of progression systems.

### Local Save File Encryption

**Explanation:** To prevent players from easily editing their high scores, collected coins, unlocked characters, or upgrade levels, the local save file will be encrypted. Godot 4 provides built-in functionality for this.

**Application:**
*   **`FileAccess.open_encrypted_with_pass()`:** When saving player data, we will use `FileAccess.open_encrypted_with_pass(path, mode, password)` to write the JSON save data to disk. Similarly, `FileAccess.open_encrypted_with_pass(path, mode, password)` will be used for loading.
*   **Encryption Key:** The `password` parameter will be a hardcoded, unique string embedded within the game's binary. While not impervious to determined reverse-engineering, this provides a significant barrier against casual file editing.
*   **Prevention of Tampering:**
    *   **High Scores:** A player cannot simply open the save file and manually input a ridiculously high score, preserving the integrity of local leaderboards and the "skill mastery & high score chase" retention driver.
    *   **Coins & Upgrades:** Players cannot grant themselves infinite coins or instantly max out all power-up upgrades (magnet, shield, coin multiplier), which would completely bypass the "progression systems" and "power-up upgrades" retention drivers, destroying the game's economy and sense of achievement.
    *   **Character Unlocks:** Similarly, character unlocks cannot be trivially bypassed, ensuring players earn their cosmetic and gameplay-altering characters.
*   **Benefits:** This measure ensures that the progression systems remain meaningful and that the "one more run" impulse is driven by genuine achievement rather than simple file manipulation.

### Save Data JSON Schema

The local save file will store player progress in a structured JSON format. This schema covers all essential player data, progression, and settings, directly supporting the core loop and retention drivers identified in the research brief.

```json
{
    "player_data": {
        "current_character_id": "runner_default",         // The character currently selected by the player.
        "current_coins": 12345,                           // Total coins collected across all runs, used for upgrades/unlocks.
        "total_distance_run": 56789.0,                    // Cumulative distance run across all runs.
        "last_run_score": 1234,                           // Score from the most recent run.
        "last_run_distance": 123.0,                       // Distance from the most recent run.
        "total_runs": 123                                 // Total number of runs played.
    },
    "inventory": {
        "unlocked_characters": [
            "runner_default",
            "runner_ninja"                                // List of character IDs the player has unlocked.
        ],
        "unlocked_powerups": [
            "magnet",
            "shield"                                      // List of power-up types the player has unlocked (not upgraded).
        ]
    },
    "upgrades": {
        "magnet_level": 3,                                // Current upgrade level for the magnet power-up.
        "shield_level": 2,                                // Current upgrade level for the shield power-up.
        "coin_multiplier_level": 1,                       // Current upgrade level for the coin multiplier.
        "boost_duration_level": 0                         // Current upgrade level for boost duration (