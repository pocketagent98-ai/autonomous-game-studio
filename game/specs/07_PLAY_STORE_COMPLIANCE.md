# Play Store Compliance Document: Endless Runner

This document outlines the technical and policy compliance requirements for our Godot 4 endless runner game, ensuring a smooth and successful launch on the Google Play Store. Adherence to these guidelines is critical for app approval, optimal performance, and a positive user experience.

---

## 1. Target SDK Version

Our game will target the latest stable Android SDK version to ensure compatibility, security, and access to the newest platform features.

*   **Minimum Target:** Android 14 (API level 34)
*   **Recommended Target (Post-Release):** Android 15 (API level 35) upon its stable release.

**Rationale:** Google Play requires apps to target a recent API level to provide users with the latest privacy and security protections. Targeting Android 14/15 ensures our game benefits from performance improvements, battery optimizations, and maintains compliance with Play Store policies, avoiding potential delisting or warnings. Godot 4 fully supports targeting these API levels.

---

## 2. Permissions Management

We are committed to the principle of "least privilege," requesting only the absolute minimum permissions necessary for the game's core functionality.

*   **Only Necessary Permission:** `android.permission.VIBRATE`
    *   **Purpose:** This permission is essential for providing tactile feedback to the player, enhancing immersion and responsiveness. In an endless runner, haptic feedback can signal successful dodges, collisions, power-up activations, or critical events, directly addressing the "Input Lag" and "Unfair Obstacle Spawning" complaints by providing immediate physical confirmation of game events.
*   **Excluded Permissions:** The game **will not** request permissions for:
    *   Camera
    *   Location
    *   Microphone
    *   External Storage (Read/Write)
    *   Contacts
    *   Any other sensitive or unnecessary permissions.
    *   **Rationale:** The core loop of our endless runner (Run > Avoid Obstacles / Collect Coins > Die > Upgrade / Retry) does not require access to any of these sensitive device features. Avoiding these permissions simplifies user trust, reduces security risks, and streamlines the app review process.

---

## 3. Architecture & Distribution

To ensure broad compatibility, optimal performance, and efficient distribution, the game will adhere to modern Android packaging standards.

*   **64-bit Architecture:** The game will be exported with 64-bit architecture support.
    *   **Primary ABI:** `arm64-v8a`
    *   **Rationale:** Google Play mandates 64-bit support for all apps. This ensures compatibility with modern Android devices, which are predominantly 64-bit, offering better performance and security.
*   **Android App Bundle (AAB):** The game will be distributed as an Android App Bundle.
    *   **Rationale:** AABs allow Google Play to generate and serve optimized APKs for each user's device configuration, resulting in smaller app downloads and more efficient installations.

---

## 4. Screen Aspect Ratio & Notch/Safe Area Handling

Given the diversity of Android devices, robust handling of various screen aspect ratios and device cutouts (notches, punch-holes) is paramount for a consistent and fair player experience.

*   **Aspect Ratio Handling:**
    *   The game will be designed to gracefully adapt to a wide range of aspect ratios, from traditional 16:9 to ultra-wide 21:9 and beyond.
    *   **Godot's Stretch Mode:** We will utilize Godot's `viewport` or `2d` stretch mode with an `expand` aspect mode for the UI layer. This ensures UI elements scale appropriately or are positioned relative to the screen edges without being cut off or distorted.
    *   **3D Camera & FOV:** The 3D camera (third-person, slightly elevated, behind-the-back) will be configured to maintain optimal visibility and a strong sense of speed, as highlighted in the research brief.
        *   The base FOV (e.g., 60-75 degrees vertical) will be chosen for a balanced view.
        *   For wider aspect ratios, the horizontal FOV will naturally expand, providing more peripheral vision without distorting central gameplay. For narrower aspect ratios, pillarboxing may be employed for non-critical background elements, or the camera's distance/FOV might be slightly adjusted to preserve critical gameplay visibility, ensuring "look-ahead" distance for obstacles is never compromised.
        *   Crucially, the playable path and upcoming obstacles will always remain clearly visible, regardless of the screen's dimensions, preventing "Blind Corners" or "Wall of Death" scenarios due to display limitations.
*   **Notch, Punch-Hole, and Safe Area Handling:**
    *   All critical UI elements (score, currency, power-up indicators, pause button) and gameplay information will be confined to the device's "safe area."
    *   We will use Godot's `DisplayServer.screen_get_safe_area()` function to query the device's safe area in pixels.
    *   UI containers (e.g., `MarginContainer` or `Control` nodes with custom margins) will be dynamically padded or anchored to respect these safe area insets, ensuring they are never obscured by notches, punch-holes, or system UI bars (status bar, navigation bar).
    *   While background elements or non-critical visuals may extend into the unsafe areas for aesthetic purposes, core gameplay (the character, path, obstacles, and interactive elements) will always be fully visible and playable within the safe bounds.

---

## 5. Pre-Launch Compliance Checklist

Before submitting to the Google Play Store, the following checklist will be rigorously followed:

*   **[ ] Target SDK Verification:** Confirm Godot export targets Android 14 (API level 34) or higher.
*   **[ ] Permissions Audit:** Verify `android.permission.VIBRATE` is the *only* permission requested in the `AndroidManifest.xml`.
*   **[ ] 64-bit AAB Export:** Ensure the game is exported as an AAB with `arm64-v8a` architecture included.
*   **[ ] Safe Area UI Testing:** Test the game on various devices and emulators with different notch/punch-hole configurations to confirm all critical UI elements are within the safe area.
*   **[ ] Aspect Ratio Testing:** Validate gameplay and UI across common aspect ratios (e.g., 16:9, 18:9, 19.5:9, 21:9) to ensure no visual or gameplay compromises.
*   **[ ] Privacy Policy:** Prepare and link a clear, concise privacy policy (even if minimal data is collected, e.g., only device vibration).
*   **[ ] Age Rating:** Obtain and apply the appropriate IARC age rating for the game's content.
*   **[ ] Performance & Stability:** Conduct extensive testing on diverse hardware for performance, stability, and absence of crashes. Pay special attention to input responsiveness to avoid player complaints about "Input Lag."
*   **[ ] Store Listing Assets:** Prepare high-quality screenshots, feature graphics, an app icon, and a compelling promotional video that accurately represent the game.
*   **[ ] Description & Keywords:** Write a clear, engaging app description and research relevant keywords for discoverability.