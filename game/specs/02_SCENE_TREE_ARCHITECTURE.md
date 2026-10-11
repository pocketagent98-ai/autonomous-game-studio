# Scene Tree Architecture: Endless Runner

This architecture outlines the primary scene (`Main.tscn`) and the reusable component scenes for an endless runner game in Godot 4, designed to meet the requirements of the research brief.

## Main Scene (`Main.tscn`)

The `Main` scene serves as the root of the game, orchestrating the entire experience from game state management to world rendering and UI display.

*   **Main (Node)**
    *   **Type:** `Node`
    *   **Purpose:** The root of the game, managing overall game state, transitions, and global systems.
    *   **Script:** `Main.gd` - Handles game initialization, scene transitions (e.g., to a main menu or upgrade screen), and potentially global input mapping or pause state.

    *   **WorldEnvironment (WorldEnvironment)**
        *   **Type:** `WorldEnvironment`
        *   **Purpose:** Defines global environment settings such as sky, ambient light, fog, and post-processing effects. Crucial for establishing the game's visual mood.
        *   **Script:** None (configured via inspector).

    *   **DirectionalLight3D (DirectionalLight3D)**
        *   **Type:** `DirectionalLight3D`
        *   **Purpose:** Provides the primary light source for the 3D world, simulating sunlight.
        *   **Script:** None (configured via inspector).

    *   **CameraRig (Node3D)**
        *   **Type:** `Node3D`
        *   **Purpose:** Acts as an intermediary parent for the `Camera3D`. This node will follow the `Player` character, allowing the `Camera3D` to maintain its relative position, angle, and FOV without directly being a child of the player. This separation prevents camera jitters from player movement.
        *   **Script:** `CameraRig.gd` - Implements the third-person, slightly elevated, behind-the-back camera logic, following the `Player` with a configurable offset, angle (10-15 degrees downwards), and smooth interpolation.

        *   **Camera3D (Camera3D)**
            *   **Type:** `Camera3D`
            *   **Purpose:** The player's viewport into the 3D world. Its position and orientation are managed by its parent `CameraRig`.
            *   **Script:** None (configured via inspector, FOV 60-75 degrees vertical).

    *   **TrackManager (Node3D)**
        *   **Type:** `Node3D`
        *   **Purpose:** Responsible for the procedural generation, instantiation, and despawning of track segments, obstacles, and coins. Manages the "endless" aspect of the runner, ensuring a continuous path and increasing difficulty. Addresses "unfair obstacle spawning" by managing look-ahead distance.
        *   **Script:** `TrackManager.gd` - Handles track segment pooling, obstacle/coin placement logic, difficulty scaling, and ensuring sufficient "look-ahead" distance for fair obstacle generation. Communicates with `GameManager` about track progression.

    *   **Player (CharacterBody3D)**
        *   **Type:** `CharacterBody3D`
        *   **Purpose:** The player-controlled character. Instantiated from `Player.tscn`. Handles player input, movement, collision, and interaction with the environment.
        *   **Script:** `Player.gd` - Processes input (swipe/tap for lane change, jump, slide), manages character animations, handles collision detection, and implements specific interactions like "Boulder Push" or "Vine Swing." Emits signals for `died`, `coin_collected`, `powerup_picked_up`.

    *   **HUD (CanvasLayer)**
        *   **Type:** `CanvasLayer`
        *   **Purpose:** Displays all User Interface elements (score, coins, power-up indicators, pause button) on top of the 3D world.
        *   **Script:** `HUD.gd` - Updates UI elements based on game state changes received from `GameManager`. Handles button presses (e.g., pause).

        *   **ScoreLabel (Label)**
            *   **Type:** `Label`
            *   **Purpose:** Displays the current score.
            *   **Script:** None.
        *   **CoinCountLabel (Label)**
            *   **Type:** `Label`
            *   **Purpose:** Displays the number of coins collected.
            *   **Script:** None.
        *   **PowerUpIndicator (TextureRect)**
            *   **Type:** `TextureRect`
            *   **Purpose:** Visually indicates active power-ups and their remaining duration.
            *   **Script:** None.
        *   **PauseButton (Button)**
            *   **Type:** `Button`
            *   **Purpose:** Allows the player to pause the game.
            *   **Script:** None (connects `pressed` signal to `HUD.gd` or `GameManager.gd`).

    *   **GameManager (Node)**
        *   **Type:** `Node`
        *   **Purpose:** The central hub for game logic. Manages game state (playing, paused, game over), score, coin count, power-up states, progression systems (missions, upgrades), and high scores. Responds to signals from `Player`, `TrackManager`, and `HUD`.
        *   **Script:** `GameManager.gd` - Orchestrates game flow, updates score/coins, manages power-up timers, handles game over conditions, and communicates with `HUD` to update display. Also responsible for saving/loading player data (high scores, upgrades).

    *   **SFXPlayer (AudioStreamPlayer)**
        *   **Type:** `AudioStreamPlayer`
        *   **Purpose:** Plays one-shot sound effects (e.g., coin collection, jump, collision, power-up activation).
        *   **Script:** None (managed by `GameManager` or individual nodes emitting signals).

    *   **MusicPlayer (AudioStreamPlayer)**
        *   **Type:** `AudioStreamPlayer`
        *   **Purpose:** Plays background music for the game.
        *   **Script:** None (managed by `GameManager`).

## Reusable Scenes

These scenes are designed to be modular and instantiated multiple times by the `TrackManager` or other parent nodes.

*   **`Player.tscn` (CharacterBody3D)**
    *   **Root Node:** `CharacterBody3D`
    *   **Purpose:** The player character, containing its visual model, collision shape, and animation logic.
    *   **Node Tree:**
        *   `Player (CharacterBody3D)`
            *   `MeshInstance3D` (Player character model)
            *   `CollisionShape3D` (Defines player's physical bounds for collision)
            *   `AnimationPlayer` (Manages run, jump, slide, idle, death animations)
            *   `RayCast3D` (For ground detection, useful for jump logic)
    *   **Script:** `Player.gd` (same script as referenced in `Main.tscn` for the player instance).

*   **`Coin.tscn` (Area3D)**
    *   **Root Node:** `Area3D`
    *   **Purpose:** A collectible item that awards points/currency to the player.
    *   **Node Tree:**
        *   `Coin (Area3D)`
            *   `MeshInstance3D` (Coin model, often rotating)
            *   `CollisionShape3D` (Defines the coin's pickup area)
            *   `AnimationPlayer` (For rotation animation, and potentially a