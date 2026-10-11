# Temple Runner 3D — Godot Game Project

A complete, playable **3D Temple-Run-style endless runner** built with **Godot 4.7.2**.
Everything is procedural — no external models, textures or audio files are required.

This game is the output of the *Autonomous Game Studio* pipeline described in the
repository's root README.

## How to run

1. Install **Godot 4.7.2** (standard build) — https://godotengine.org/download
2. Open Godot, click **Import**, and select `game/project.godot`.
3. Press **F5** to play.

Headless check (no window needed):

```bash
godot --headless --path game res://tests/Smoke.tscn
```

## Controls

| Action | Keyboard | Touch |
| --- | --- | --- |
| Turn left / right | A / D or ← / → | swipe left / right |
| Jump | W / ↑ / Space | swipe up |
| Slide | S / ↓ | swipe down |
| Start / Restart | any key, or the RESTART button | tap |

## Gameplay

- The hero auto-runs forward; speed grows 5% every 500 m: `speed = 14 * 1.05^(distance/500)`.
- Score = distance + 10 × coins.
- Hitting an obstacle ends the run; the best score is saved (encrypted).

## Project structure

```
game/
  project.godot          # Godot project (autoloads Game + Audio, GL Compatibility renderer)
  icon.svg
  scenes/Main.tscn       # the only scene — the whole world is built in code
  scripts/
    GameManager.gd       # autoload "Game": score, coins, speed, encrypted save/load
    Main.gd              # builds the scene and wires everything together
    Player.gd            # CharacterBody3D + full state machine + swipe/keyboard input
    TrackManager.gd      # pooled procedural track, obstacles and coins
    Obstacle.gd          # Area3D hazard
    Coin.gd              # Area3D collectible
    HUD.gd               # score/coins, start overlay, game-over panel
    CameraRig.gd         # behind-the-back follow camera (FOV 70)
    AudioManager.gd      # autoload "Audio": procedural tones (no audio files)
  specs/                 # the 7 master blueprint documents from the planning phase
  tests/                 # headless smoke + death/restart tests
```

## Verified

Both headless tests pass on Godot 4.7.2:

```
SMOKE RESULT: PASS      # run starts, score grows, speed rises, tiles spawn obstacles + coins
DEATHTEST RESULT: PASS  # death ends the run, best score saves, reset + restart work
```

## Technical notes

- Renderer: **GL Compatibility** — runs on CPU / low-end hardware and mobile.
- Performance budget: object-pooled track (12 recycled tiles), flat-shaded materials.
- Save data is encrypted with `FileAccess.open_encrypted_with_pass()` (no plain text on disk).

## कैसे चलाएँ (हिंदी)

Godot 4.7.2 इंस्टॉल करें, Godot खोलकर **Import** पर क्लिक करें और `game/project.godot` चुनें, फिर **F5** दबाकर खेलें।
कंट्रोल: A/D या ←/→ से लेन बदलें, W/↑/Space से कूदें, S/↓ से स्लाइड करें, और स्क्रीन पर स्वाइप करके भी खेल सकते हैं।
गेम में रफ़्तार हर 500 मीटर पर 5% बढ़ती है, और आपका सबसे अच्छा स्कोर एन्क्रिप्ट करके सेव होता है।
