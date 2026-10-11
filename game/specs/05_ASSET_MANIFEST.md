# ASSET & PALETTE MANIFEST

This manifest outlines the strategy for all visual and auditory assets, prioritizing a lightweight, performant, and procedurally generated approach fitting the low-poly, neon aesthetic of our endless runner. All assets are designed to be built directly within Godot 4, minimizing external dependencies.

## 1. Asset Generation Strategy

All game assets (meshes, materials, and audio) will be generated procedurally or constructed from Godot's native primitives. This ensures a small build size, rapid iteration, and complete control over the asset pipeline without reliance on external modeling or sound design software.

## 2. Mesh Assets

All 3D models will adhere to a low-poly aesthetic with minimal vertex counts.

*   **Construction Method:** Meshes will be built primarily using Godot's built-in `PrimitiveMeshes` (e.g., `BoxMesh`, `CylinderMesh`, `CapsuleMesh`, `PlaneMesh`). More complex shapes will be constructed using Godot's CSG (Constructive Solid Geometry) tools, combining and subtracting these primitives.
*   **Examples:**
    *   **Track Segments:** Composed of `BoxMesh` instances for lanes, walls, and ground planes.
    *   **Player Character:** A stylized `CapsuleMesh` or combination of `BoxMesh` and `CylinderMesh` for a simple, abstract runner.
    *   **Coins:** `CylinderMesh` or `BoxMesh` (thin cube) with rotation.
    *   **Obstacles:** Various combinations of `BoxMesh`, `CylinderMesh`, and `CapsuleMesh` to form walls, spikes, gaps, or moving barriers.

## 3. Material Assets

Materials will be flat-shaded and lightweight, relying solely on `albedo` color for visual distinction, without complex textures, normal maps, or advanced lighting calculations.

*   **Material Type:** `StandardMaterial3D` with `Shading Mode` set to `Flat` or a simple `ShaderMaterial` for custom effects if needed (e.g., glowing neon lines).
*   **Properties:**
    *   `Albedo Color`: Defined by the palette below.
    *   `Metallic`: 0.0
    *   `Roughness`: 1.0 (for a matte, non-reflective finish)
    *   `Emission`: Used selectively for neon elements to provide a glow effect.

## 4. Neon/Low-Poly Colour Palette

The game's visual identity is defined by a vibrant, high-contrast neon palette against a dark, atmospheric background.

*   **Track:** `#2C3E50` (Dark Slate Blue) - Provides a solid, grounding base that contrasts with neon elements.
*   **Player:** `#FF00FF` (Fuchsia/Magenta) - Highly visible and energetic, stands out against the track.
*   **Coins:** `#FFD700` (Gold) - Classic coin color, given a neon glow.
*   **Obstacles:** `#FF4500` (OrangeRed) - A warning color, immediately signaling danger.
*   **Sky/Background:** `#000033` (Very Dark Blue) - Creates a deep, atmospheric backdrop, enhancing the neon elements.

## 5. Procedural Audio Assets

All in-game sound effects will be generated programmatically using Godot's `AudioStreamPlayer` nodes combined with `AudioStreamGenerator` for real-time tone synthesis. This ensures a consistent, minimalist soundscape and avoids reliance on external audio files.

*   **Implementation:** Each sound effect will be an `AudioStreamPlayer` instance, dynamically generating simple waveforms (sine, square, triangle) with specific frequencies, durations, and envelopes (attack, decay, sustain, release) to create distinct tones.
*   **Specific Sounds:**
    *   **Coin Pickup:** A short, high-pitched, rising sine wave tone (e.g., 800Hz to 1200Hz over 0.15s).
    *   **Jump:** A quick, mid-frequency square wave "boop" (e.g., 600Hz for 0.1s with a rapid decay).
    *   **Hit/Collision:** A short, low-frequency, slightly dissonant buzz or thud (e.g., 150Hz square wave with a rapid pitch drop to 100Hz over 0.2s).

## 6. CC0 Fallback / External Asset Option

Should the project later require more complex or pre-made 3D models and sound effects, a robust library of CC0 (Creative Commons Zero) licensed assets is available.

*   **Primary Source:** **Kenney.nl** offers extensive packs of low-poly 3D models, UI elements, and sound effects that are ideal for prototyping and production, providing a consistent art style and high quality. These would serve as an excellent fallback or upgrade path for specific asset categories if procedural generation proves insufficient for future needs.