# Procedural Track Algorithm

The procedural track algorithm for an endless runner is designed to create an infinite, varied, and fair playing experience while maintaining optimal performance. It leverages object pooling to minimize CPU load and ensures a balanced challenge by adhering to strict obstacle placement rules.

## Object Pooling for Track Tiles

One of the most critical performance optimizations in an endless runner is avoiding constant instantiation and freeing of game objects. Godot's `instantiate()` and `free()` operations, while efficient, can introduce micro-stutters or CPU spikes if called frequently, especially on mobile devices.

**Mechanism:**
Instead of destroying track tiles that have passed the player and creating new ones, we maintain a fixed-size "pool" of pre-generated track tiles.

*   **Pool Size:** A pool of **12-15 track tiles** is typically sufficient. This number ensures that there are always enough tiles ahead of the player to provide a smooth visual experience and ample "look-ahead" distance for obstacle generation, while keeping the memory footprint manageable.
*   **Pre-generation:** At the start of the game or level, all 12-15 track tiles are instantiated and placed sequentially to form the initial track segment. They are then stored in an array or list.
*   **Recycling:** When a tile is no longer visible or relevant (i.e., the player has passed it), it is *recycled*. This means it's not destroyed. Instead, it's moved from the "back" of the visible track to the "front" (the furthest point ahead of the player). Its position is updated, and its internal state (obstacles, coins) is reset and re-randomized for its new placement.

**Benefits:**
*   **Low CPU Load:** Eliminates the overhead of `instantiate()` and `free()` during gameplay, leading to smoother frame rates.
*   **Consistent Performance:** Memory allocation remains stable, preventing performance hitches associated with dynamic memory management.
*   **Predictable Resource Usage:** The game's memory footprint for track elements is fixed and known.

## Track Tile Structure and Length

Each track tile represents a distinct segment of the game world.

*   **Consistent Length:** All track tiles must have a **uniform, fixed length** (e.g., 20 Godot units). This consistency is crucial for:
    *   **Predictable Spawning:** Knowing exactly where the next tile will begin simplifies the positioning of obstacles and coins.
    *   **Smooth Transitions:** Ensures seamless blending between tiles without visual gaps or overlaps.
    *   **Difficulty Scaling:** Allows for precise control over the density and complexity of obstacles per unit of track.
*   **Components:** A tile typically includes:
    *   A base mesh (e.g., road, ground).
    *   Collision shapes.
    *   Pre-defined "spawn points" or "slots" for obstacles and coins across its width (e.g., 3 lanes).
    *   Environmental decorations (trees, buildings) that are part of the tile's visual theme but don't usually block the player.

## Tile Recycling Mechanism

The recycling process is triggered when the player progresses past a certain point on the track.

*   **Trigger Condition:** When the player's Z-position (assuming a forward movement along the negative Z-axis) exceeds the Z-position of the **Nth tile** in the active track segment (e.g., the 5th tile in a 15-tile pool), the **first tile** in the sequence is marked for recycling. This ensures there are always `N-1` tiles behind the player and `PoolSize - N` tiles ahead, providing a consistent "look-ahead" distance.
*   **Recycling Action:**
    1.  The oldest tile (the one the player just passed) is retrieved from the front of the pool.
    2.  Its current obstacles and coins are removed or reset.
    3.  Its position is updated to be immediately after the last tile in the current active track segment. For example, if the last tile is at `Z = -200` and tile length is `20`, the recycled tile moves to `Z = -220`.
    4.  It is then re-initialized with new obstacles and coins based on the generation rules.
    5.  It's moved to the end of the active pool list, effectively becoming the "newest" tile.

## Obstacle and Coin Spawn Rules

The primary goal of obstacle spawning is to create challenging but fair paths, directly addressing the "Unfair Obstacle Spawning" and "Wall of Death" complaints from the research brief. The core rule is: **always guarantee at least one safe path.**

*   **Lanes:** Assume a standard 3-lane setup (left, middle, right).
*   **Obstacle Types:**
    *   **Static Block:** Requires a lane change (e.g., a crate, wall segment).
    *   **Jump Obstacle:** Requires jumping over (e.g., low barrier, gap). Clears the lane for running.
    *   **Slide Obstacle:** Requires sliding under (e.g., high barrier, fallen log). Clears the lane for running.
    *   **Dynamic/Interactive Obstacles:** (Referencing "Dynamic Environmental Manipulation" twist) These could be special obstacles that, when interacted with, clear a path in one lane but might temporarily block another. Their placement must still adhere to the "safe lane" rule.
*   **Safe Lane Guarantee:**
    *   For any given "obstacle segment" within a tile (a specific Z-depth where obstacles are placed), ensure that at least one of the three lanes is traversable without collision.
    *   Traversable means:
        *   Completely empty.
        *   Contains a jump obstacle (player can jump over).
        *   Contains a slide obstacle (player can slide under).
    *   **Forbidden Combinations:** Never place static blocks in all three lanes simultaneously. Never force an impossible sequence (e.g., jump immediately followed by slide in the same lane without landing time).
*   **Difficulty Scaling:**
    *   **Early Game:** Tiles feature simple obstacles (single blocks, clear paths), more coins, and less dense obstacle patterns.
    *   **Mid/Late Game:** Introduce more complex patterns:
        *   Two lanes blocked by static obstacles, one lane requires a jump/slide.
        *   Alternating jump/slide obstacles across lanes.
        *   Obstacles that span two lanes.
        *   Increased frequency of obstacles.
        *   Dynamic obstacles.
*   **Coin Placement:**
    *   **Guiding:** Coins should often be placed in the safe lanes to guide the player.
    *   **Risk/Reward:** Sometimes, coins can be placed in front of jump/slide obstacles to encourage interaction and add a minor risk/reward element.
    *   **Trails:** Create trails of coins to reward sustained movement in a single lane.
    *   **Density:** More coins in easier sections, fewer in highly challenging ones.

## Procedural Generation Pseudo-code

```gdscript
# --- Configuration ---
const TILE_LENGTH = 20.0 # Length of each track tile in Godot units
const POOL_SIZE = 15     # Number of tiles in the object pool
const SAFE_LANE_COUNT = 1 # Minimum number of traversable lanes per obstacle segment

# --- Global Variables ---
var track_tile_scene = preload("res://Scenes/TrackTile.tscn") # Your track tile scene
var tile_pool = [] # Array to hold our pooled tile nodes
var active_tiles = [] # Array to hold currently active tiles (subset of pool)
var next_spawn_z = 0.0 # Z-position for the next tile to be placed
var player_node # Reference to the player character node

# --- Initialization ---
func _ready():
    player_node = get_tree().get_first_node_in_group("player") # Assuming player is in "player" group
    initialize_track_pool()

func initialize_track_pool():
    # Pre-generate and place the initial set of tiles
    for i in range(POOL_SIZE):
        var new_tile = track_tile_scene.instantiate()
        add_child(new_tile)
        tile_pool.append(new_tile)
        
        # Position the tile and generate its content
        new_tile.position.z = next_spawn_z
        generate_