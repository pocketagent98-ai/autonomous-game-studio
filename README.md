# Autonomous Game Studio

**An autonomous, GPU-free AI game-development pipeline built on Godot Engine.**
A complete bilingual architecture report — **English** and **हिंदी**.

**Language:** [English Report](#english-report) &nbsp;•&nbsp; [हिंदी रिपोर्ट](#हिंदी-रिपोर्ट)

---

## The built game

This repository now contains a **working game produced by the pipeline**: a playable **3D Temple-Run-style endless runner** built with Godot 4.7.2, in [`game/`](game/).

- Source, controls and build steps: [`game/README.md`](game/README.md)
- To play: open `game/project.godot` in Godot 4.7.2 and press **F5**.
- Verified on Godot 4.7.2 with headless tests — `SMOKE` and `DEATHTEST` both pass.

---

## English Report

### Building a studio-level 3D game with AI agents on top of Godot Engine — a complete architecture report

This report describes an **autonomous (agentic) game-development pipeline** with a simple goal: give the system a one-line game idea, and a team of AI agents researches, plans, codes, renders, tests, fixes, secures and packages a complete 3D mobile game — **without a GPU**, entirely on cloud CPUs. The human only supplies the idea and the API keys.

> This document is bilingual: the English report is below, followed by the full [हिंदी रिपोर्ट](#हिंदी-रिपोर्ट).

---

## 1. What this project is

The project is an end-to-end automation layer wrapped around the open-source **Godot Engine**. Instead of a human developer opening the Godot editor, an orchestrator agent drives the whole studio:

- **Research** what makes competing games work.
- **Plan** the game through seven fixed blueprint documents.
- **Write** the GDScript code and build the scene tree.
- **Run** the game headless on a cloud CPU and capture screenshots and video.
- **Judge** the result with vision- and audio-capable models.
- **Self-heal** by feeding the critique back to the coding model.
- **Audit** the code for security, and finally
- **Export** a Play-Store-ready Android App Bundle.

The result is a "studio-level" game built from a single prompt, on ordinary CPU hardware.

## 2. Why Godot Engine

Among all engines, Godot is uniquely suited to agentic automation:

- **Text-based scenes.** Every scene (`.tscn`) and resource (`.tres`) is a readable, YAML-like plain-text file, so an LLM can create or edit scenes directly without touching binary formats.
- **GDScript.** Godot's primary language has Python-like syntax, and modern LLMs write it accurately — far fewer memory and compilation traps than C++ or Rust.
- **Headless + CLI.** `godot --headless` runs the engine with no GUI window, which lets an agent launch the game, read the error log, and correct itself.
- **Studio-level capability, tiny footprint.** Godot 4 ships a modern Vulkan renderer, global illumination, volumetric fog and advanced shaders, yet the editor plus CLI is only about 60–100 MB.

Pinned engine: **Godot 4.7.2 (stable)** — the latest stable at the time of writing; the stack can be moved to 4.8 later.

## 3. The five-phase pipeline

1. **Deep research & anti-copy evolution.** The research agent studies competitor mechanics, camera FOV, speed loops and player complaints, then reconstructs the core loop and adds three original twists so the game is inspired, never copied.
2. **Zero-attribution asset management.** 100% CC0 assets (for example Kenney) are auto-downloaded and unpacked into the project, with a procedural fallback built from CSG primitives and custom shaders inside the engine when an asset is missing.
3. **Coding & scene construction.** The coding brain writes minimal, clean GDScript under Ponytail rules and builds the `.tscn` node tree through Godot-MCP.
4. **CPU rendering & multi-layer QA.** The game runs on a virtual display; a screenshot model checks static visuals, a video+audio model checks motion and sound, and any error loops back for auto-fix.
5. **Security, optimisation & publishing.** A security scan, then a 64-bit Play-Store-compliant AAB export.

## 4. The technology stack

| Tool | Role | Notes |
| --- | --- | --- |
| **Godot 4.7.2** | Game engine + CLI | MIT licence, ~60–100 MB, headless capable |
| **NVIDIA NIM** | Master coder / architect | Native NVIDIA models, 40 RPM |
| **Gemma** (Google AI Studio) | Still-screenshot inspector | UI, layout, lighting, static poses |
| **Gemini Flash Lite** | Video + audio QA | Motion, collision, SFX timing |
| **Laya** | Local decision gatekeeper | ~421M params, runs on CPU (ONNX) |
| **DeepSeek Harness (dsh)** | Open-source coding orchestrator | Runs the whole agent loop |
| **Godot-MCP** | Direct engine control | create-node, modify-script, build-scene, run-project |
| **Ponytail** | Anti-over-engineering plugin | "Lazy senior developer" rules |
| **Strix** | Security scanner | Open-source codebase audit |
| **Agent Reach** | Web / YouTube research | Video, comment and trend extraction |
| **Xvfb + Mesa/llvmpipe + PulseAudio + FFmpeg** | Zero-GPU render & capture | Virtual screen, software 3D, dummy audio, video |

## 5. Dual-brain AI architecture

The system deliberately splits the work between two "brains" so that neither quota nor speed becomes a bottleneck:

- **Brain 1 — NVIDIA NIM (40 requests/minute).** This does 90–95% of the work: research, architecture, all GDScript coding, refactoring and bug-fixing. Only NVIDIA's *native* models are used, because partner-hosted models (for example GLM or Kimi) are routed through third-party infrastructure and frequently time out. The recommended native models are `nvidia/llama-3.1-nemotron-70b-instruct` for fast coding and Ponytail clean-up, and `nvidia/nemotron-4-340b-instruct` for complex architecture and the seven blueprint files.
- **Brain 2 — Google AI Studio (Gemma + Gemini Flash Lite).** Gemini Flash Lite is the "QA inspector": it only wakes up when a freshly built feature needs testing, accepting a short MP4 clip together with its audio track. Two API keys are used in a round-robin so the load is balanced across them.

Because Brain 2 runs rarely, the expensive video/audio model never becomes the hot path, and Brain 1 carries the heavy, continuous coding load at full speed.

## 6. Laya: the local decision gatekeeper

Before every small decision, the system previously had to call an expensive LLM. **Laya** — an open-source, non-autoregressive "System-1" decision model of roughly 421M parameters, ModernBERT-based — removes that cost. Instead of generating heavy text, it returns a structured decision (Yes/No, a category route, or a pass/fail score) in 30–40 milliseconds, running locally on the CPU in about 400–500 MB of RAM.

Laya acts as a smart gatekeeper, answering questions such as:

- "Is a screenshot enough here, or must we record video?"
- "Is there a serious error that needs fixing? Yes/No."
- "Is this problem visual, audio or logic?"

This saves roughly 70% of the otherwise-wasted tokens and API calls on the paid models.

## 7. CPU-first, zero-GPU rendering and capture

The whole system is designed to run with **no GPU at all** — on GitHub Codespaces, Modal or Lightning AI CPUs — using four open-source components:

- **Xvfb** creates a virtual X display (`:99`), so Godot believes a real monitor is attached and renders the full 3D scene.
- **Mesa / llvmpipe** is the software rasteriser that turns the CPU itself into a virtual GPU, producing picture-perfect 3D on OpenGL3.
- **PulseAudio** provides a dummy sound card so every Godot sound (music and effects) is captured.
- **FFmpeg** grabs the screen (`x11grab`) and the audio (`pulse`) together and writes a synchronised 5-second MP4 clip for the QA model.

This is what gives the agent "eyes and ears" without any graphics hardware.

## 8. The seven master blueprint files

Before a single line of code is written, the planner agent produces seven documents in the `specs/` folder, so the coding agent never has to guess:

1. **01_GAME_DESIGN_DOCUMENT.md** — core loop (Run → Collect → Dodge → Die → Upgrade → Restart), input mapping, and the speed-progression formula.
2. **02_SCENE_TREE_ARCHITECTURE.md** — the Godot node tree (Main → WorldEnvironment, DirectionalLight3D, TrackSpawner, Player, HUD).
3. **03_STATE_MACHINE_SPEC.md** — every player state (IDLE, RUNNING, JUMPING, SLIDING, TURNING_LEFT, TURNING_RIGHT, STUMBLE, DEAD) with its input triggers and collision-shape changes.
4. **04_PROCEDURAL_TRACK_ALGO.md** — object pooling of 12–15 recycled track tiles, and obstacle-spawn rules that guarantee no path is ever 100% blocked.
5. **05_ASSET_MANIFEST.md** — paths to CC0 low-poly 3D meshes, lightweight materials and audio effects.
6. **06_SECURITY_AND_PERFORMANCE.md** — the mobile budget (60 FPS, ≤50 draw calls, <100k polygons) and AES-256 encrypted save data.
7. **07_PLAY_STORE_COMPLIANCE.md** — target SDK, the minimal permission set, and screen-notch / safe-area handling.

## 9. Rate-limit and cost math

The quotas were chosen so the pipeline can run for a full working day without ever hitting a ceiling:

- **NVIDIA NIM:** 40 requests per minute — enough for continuous coding all day.
- **Gemini Flash Lite:** about 13–14 requests per minute and 450 requests per day per key; two keys give roughly 27 RPM and 900 RPD.
- If the agent records and inspects one 5-second clip every three minutes, that is about 20 requests per hour and only 200–250 in a ten-hour day — comfortably inside the 900 RPD budget.

## 10. Google Play 2026 compliance

The export phase enforces four rules automatically:

1. **Target API level** Android 15/16 (API level 35+).
2. **Zero unnecessary permissions** — no camera, location or microphone; only basics such as VIBRATE.
3. **App Bundle (AAB)** — 64-bit `arm64-v8a` split AAB, keeping the download under about 25–30 MB.
4. **Secure save data** — coins and high-scores are encrypted with Godot's `FileAccess.open_encrypted_with_pass()` instead of plain JSON, to prevent cheating.

## 11. Setup commands (appendix)

The one-time environment setup on a cloud CPU terminal:

```bash
# 1. Virtual display, CPU 3D renderer, audio and FFmpeg
sudo apt-get update
sudo apt-get install -y xvfb pulseaudio ffmpeg libgl1-mesa-dri mesa-utils unzip wget python3-pip

# 2. Godot 4.x headless Linux binary
wget https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip Godot_v4.7.2-stable_linux.x86_64.zip
sudo mv Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot
chmod +x /usr/local/bin/godot

# 3. Ponytail and Strix skills
npm install -g @deepseek-ai/dsh
npx skills add https://github.com/dietrichgebert/ponytail --skill ponytail
npx skills add usestrix/strix

# 4. Python libraries
pip install google-genai requests

# 5. Start the virtual display and dummy audio
pulseaudio -D --exit-idle-time=-1
Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99
```

## Sources

The plan above was assembled from the following references cited during its design:

1. Best AI Agents for Godot in 2026: MCP, Plugins & Tools — SoonLab
2. Godot RL Agents — Hugging Face
3. godot-mcp — AI Agents on GitHub — SkillsLLM
4. Godot Engine — Free and open source 2D and 3D game engine
5. AI Models by NVIDIA | Try NVIDIA NIM APIs
6. Gemini 3.1 Flash-Lite | Gemini API — Google AI for Developers
7. Gemma models overview — Google AI for Developers
8. Laya Model: Open-Source Decision AI You Can Run Locally
9. What Is Laya? Laya vs Jev — Medium

---

## हिंदी रिपोर्ट

### Godot इंजन पर AI एजेंट्स के साथ स्टूडियो-लेवल 3D गेम बनाना — एक पूरी आर्किटेक्चर रिपोर्ट

यह रिपोर्ट एक **ऑटोनॉमस (agentic) गेम-डेवलपमेंट पाइपलाइन** का वर्णन करती है, जिसका लक्ष्य सरल है: सिस्टम को एक लाइन का गेम आइडिया दें, और AI एजेंट्स की एक टीम रिसर्च, प्लानिंग, कोडिंग, रेंडरिंग, टेस्टिंग, फिक्सिंग, सिक्योरिटी और पैकेजिंग करके एक पूरा 3D मोबाइल गेम तैयार कर देती है — **बिना किसी GPU के**, पूरी तरह क्लाउड CPU पर। इंसान केवल आइडिया और API keys देता है।

## 1. यह प्रोजेक्ट क्या है

यह प्रोजेक्ट ओपन-सोर्स **Godot इंजन** के चारों ओर बनी एक एंड-टू-एंड ऑटोमेशन लेयर है। इंसानी डेवलपर के Godot एडिटर खोलने के बजाय, एक ऑर्केस्ट्रेटर एजेंट पूरे स्टूडियो को चलाता है:

- यह **रिसर्च** करता है कि कॉम्पिटिटिव गेम्स को सफल क्या बनाता है।
- सात तय ब्लूप्रिंट डॉक्यूमेंट्स के जरिए गेम की **प्लानिंग** करता है।
- GDScript कोड **लिखता** है और सीन ट्री बनाता है।
- क्लाउड CPU पर गेम को हेडलेस **रन** करता है और स्क्रीनशॉट तथा वीडियो कैप्चर करता है।
- विज़न और ऑडियो इनेबल्ड मॉडल्स से नतीजों को **इवैल्यूएट** करता है।
- फीडबैक को वापस कोडिंग मॉडल को भेजकर **खुद को ठीक** करता है।
- कोड का सिक्योरिटी **ऑडिट** करता है, और अंत में
- Play Store के लिए तैयार Android App Bundle **एक्सपोर्ट** करता है।

नतीजा यह है कि एक ही प्रॉम्प्ट से, आम CPU हार्डवेयर पर, एक "स्टूडियो-लेवल" गेम बन जाता है।

## 2. Godot इंजन ही क्यों

सभी इंजनों में से, Godot एजेंटिक ऑटोमेशन के लिए सबसे उपयुक्त है:

- **टेक्स्ट-बेस्ड सीन्स।** हर सीन (`.tscn`) और रिसोर्स (`.tres`) एक रीडेबल, YAML जैसी प्लेन-टेक्स्ट फाइल होती है, इसलिए कोई भी LLM बिना बाइनरी फॉर्मेट को छेड़े सीधे सीन बना या बदल सकता है।
- **GDScript।** Godot की मुख्य भाषा का सिंटैक्स Python जैसा है, और मॉडर्न LLMs इसे सटीकता से लिखते हैं — C++ या Rust की तुलना में मेमोरी और कंपाइलेशन की गलतियाँ बहुत कम होती हैं।
- **हेडलेस + CLI।** `godot --headless` इंजन को बिना किसी GUI विंडो के चलाता है, जिससे एजेंट गेम लॉन्च कर सकता है, एरर लॉग पढ़ सकता है और खुद को सुधार सकता है।
- **स्टूडियो-लेवल क्षमता, बहुत छोटा आकार।** Godot 4 में मॉडर्न Vulkan रेंडरर, ग्लोबल इल्यूमिनेशन, वॉल्यूमेट्रिक फॉग और एडवांस शेडर्स हैं, फिर भी एडिटर और CLI मिलाकर केवल लगभग 60–100 MB का है।

चुना गया इंजन: **Godot 4.7.2 (stable)** — लिखे जाने के समय का लेटेस्ट स्टेबल वर्ज़न; बाद में स्टैक को 4.8 पर भी ले जाया जा सकता है।

## 3. पांच-स्टेप पाइपलाइन

1. **डीप रिसर्च और एंटी-कॉपी इवोल्यूशन।** रिसर्च एजेंट कॉम्पिटिटिव गेम्स की मैकेनिक्स, कैमरा FOV, स्पीड लूप्स और खिलाड़ियों की शिकायतों का अध्ययन करता है, फिर कोर लूप को फिर से तैयार करता है और तीन ओरिजिनल ट्विस्ट जोड़ता है ताकि गेम इंस्पायर्ड लगे, कभी कॉपी न लगे।
2. **जीरो-एट्रिब्यूशन एसेट मैनेजमेंट।** 100% CC0 एसेट्स (जैसे Kenney) ऑटो-डाउनलोड होकर प्रोजेक्ट में आ जाते हैं; और जब कोई एसेट न मिले, तो इंजन के अंदर CSG प्रिमिटिव्स तथा कस्टम शेडर्स से प्रोसीजरल फॉलबैक बनाया जाता है।
3. **कोडिंग और सीन कंस्ट्रक्शन।** कोडिंग ब्रेन Ponytail नियमों के तहत न्यूनतम और क्लीन GDScript लिखता है और Godot-MCP के जरिए `.tscn` नोड ट्री बनाता है।
4. **CPU रेंडरिंग और मल्टी-लेयर QA।** गेम एक वर्चुअल डिस्प्ले पर चलता है; एक स्क्रीनशॉट मॉडल स्टैटिक विज़ुअल्स चेक करता है, एक वीडियो+ऑडियो मॉडल मोशन और साउंड चेक करता है, और कोई भी एरर ऑटो-फिक्स के लिए वापस लूप हो जाता है।
5. **सिक्योरिटी, ऑप्टिमाइज़ेशन और पब्लिशिंग।** एक सिक्योरिटी स्कैन, फिर 64-bit Play-Store-कम्प्लायंट AAB एक्सपोर्ट।

## 4. टेक्नोलॉजी स्टैक

| टूल | भूमिका | नोट्स |
| --- | --- | --- |
| **Godot 4.7.2** | गेम इंजन + CLI | MIT लाइसेंस, ~60–100 MB, हेडलेस इनेबल्ड |
| **NVIDIA NIM** | मास्टर कोडर / आर्किटेक्ट | NVIDIA के नेटिव मॉडल्स, 40 RPM |
| **Gemma** (Google AI Studio) | स्टैटिक स्क्रीनशॉट इंस्पेक्टर | UI, लेआउट, लाइटिंग, स्टैटिक पोज़ |
| **Gemini Flash Lite** | वीडियो + ऑडियो QA | मोशन, कोलिजन, SFX टाइमिंग |
| **Laya** | लोकल डिसीजन गेटकीपर | ~421M पैरामीटर्स, CPU (ONNX) पर चलता है |
| **DeepSeek Harness (dsh)** | ओपन-सोर्स कोडिंग ऑर्केस्ट्रेटर | पूरा एजेंट लूप चलाता है |
| **Godot-MCP** | डायरेक्ट इंजन कंट्रोल | create-node, modify-script, build-scene, run-project |
| **Ponytail** | ओवर-इंजीनियरिंग रोकने वाला प्लगइन | "लेज़ी सीनियर डेवलपर" नियम |
| **Strix** | सिक्योरिटी स्कैनर | ओपन-सोर्स कोडबेस ऑडिट |
| **Agent Reach** | वेब / YouTube रिसर्च | वीडियो, कमेंट और ट्रेंड एक्सट्रैक्शन |
| **Xvfb + Mesa/llvmpipe + PulseAudio + FFmpeg** | जीरो-GPU रेंडर और कैप्चर | वर्चुअल स्क्रीन, सॉफ्टवेयर 3D, डमी ऑडियो, वीडियो |

## 5. डुअल-ब्रेन AI आर्किटेक्चर

सिस्टम जानबूझकर काम को दो "ब्रेन" के बीच बांटता है, ताकि न कोटा और न स्पीड कोई रुकावट बने:

- **ब्रेन 1 — NVIDIA NIM (40 रिक्वेस्ट/मिनट)।** यह 90–95% काम करता है: रिसर्च, आर्किटेक्चर, सारी GDScript कोडिंग, रिफैक्टरिंग और बग-फिक्सिंग। केवल NVIDIA के *नेटिव* मॉडल्स इस्तेमाल होते हैं, क्योंकि पार्टनर-होस्टेड मॉडल्स (जैसे GLM या Kimi) थर्ड-पार्टी इंफ्रास्ट्रक्चर से रूट होते हैं और अक्सर टाइमआउट दे देते हैं। सुझाए गए नेटिव मॉडल्स हैं `nvidia/llama-3.1-nemotron-70b-instruct` (तेज़ कोडिंग और Ponytail क्लीन-अप के लिए) और `nvidia/nemotron-4-340b-instruct` (कॉम्प्लेक्स आर्किटेक्चर और सात ब्लूप्रिंट फाइलों के लिए)।
- **ब्रेन 2 — Google AI Studio (Gemma + Gemini Flash Lite)।** Gemini Flash Lite "QA इंस्पेक्टर" है: यह तभी जागता है जब किसी नए बने फीचर को टेस्ट करना हो, और एक छोटी MP4 क्लिप को उसके ऑडियो ट्रैक के साथ एक्सेप्ट करता है। दो API keys राउंड-रॉबिन में इस्तेमाल होती हैं ताकि लोड बंट जाए।

चूंकि ब्रेन 2 कम चलता है, महँगा वीडियो/ऑडियो मॉडल कभी हॉट पाथ नहीं बनता, और ब्रेन 1 पूरी स्पीड से लगातार कोडिंग का भारी काम उठाता है।

## 6. Laya: लोकल डिसीजन गेटकीपर

पहले हर छोटे फैसले के लिए सिस्टम को महँगा LLM कॉल करना पड़ता था। **Laya** — एक ओपन-सोर्स, नॉन-ऑटोरिग्रैसिव "System-1" डिसीजन मॉडल जो लगभग 421M पैरामीटर्स का है और ModernBERT-बेस्ड है — उस खर्च को हटा देता है। भारी टेक्स्ट जनरेट करने के बजाय यह 30–40 मिलीसेकंड में एक स्ट्रक्चर्ड डिसीजन (Yes/No, कोई कैटेगरी रूट, या pass/fail स्कोर) देता है, और CPU पर लगभग 400–500 MB RAM में लोकली चलता है।

Laya एक स्मार्ट गेटकीपर की तरह काम करता है, और ऐसे सवालों के जवाब देता है:

- "यहाँ स्क्रीनशॉट काफी है, या वीडियो रिकॉर्ड करना ज़रूरी है?"
- "कोई गंभीर एरर है जिसे ठीक करना है? हाँ/नहीं।"
- "यह समस्या विज़ुअल है, ऑडियो है या लॉजिक?"

इससे पेड मॉडल्स पर बर्बाद होने वाले लगभग 70% टोकन और API कॉल्स बच जाते हैं।

## 7. CPU-फर्स्ट, जीरो-GPU रेंडरिंग और कैप्चर

पूरा सिस्टम **बिना किसी GPU के** चलने के लिए बनाया गया है — GitHub Codespaces, Modal या Lightning AI के CPU पर — और इसके लिए चार ओपन-सोर्स कंपोनेंट्स काम करते हैं:

- **Xvfb** एक वर्चुअल X डिस्प्ले (`:99`) बनाता है, जिससे Godot को लगता है कि असली मॉनिटर जुड़ा है और वह पूरा 3D सीन रेंडर करता है।
- **Mesa / llvmpipe** वह सॉफ्टवेयर रास्टराइज़र है जो CPU को ही एक वर्चुअल GPU बना देता है, और OpenGL3 पर बेदाग 3D तैयार करता है।
- **PulseAudio** एक डमी साउंड कार्ड देता है जिससे Godot की हर आवाज़ (म्यूजिक और इफेक्ट्स) कैप्चर होती है।
- **FFmpeg** स्क्रीन (`x11grab`) और ऑडियो (`pulse`) को एक साथ पकड़कर QA मॉडल के लिए एक सिंक की हुई 5-सेकंड की MP4 क्लिप लिखता है।

यही चीज़ एजेंट को बिना किसी ग्राफिक्स हार्डवेयर के "आँखें और कान" देती है।

## 8. सात मास्टर ब्लूप्रिंट फाइल्स

कोड की एक भी लाइन लिखे जाने से पहले, प्लानर एजेंट `specs/` फोल्डर में सात डॉक्यूमेंट तैयार करता है, ताकि कोडिंग एजेंट को कभी अंदाज़ा न लगाना पड़े:

1. **01_GAME_DESIGN_DOCUMENT.md** — कोर लूप (Run → Collect → Dodge → Die → Upgrade → Restart), इनपुट मैपिंग, और स्पीड-प्रोग्रेशन फॉर्मूला।
2. **02_SCENE_TREE_ARCHITECTURE.md** — Godot का नोड ट्री (Main → WorldEnvironment, DirectionalLight3D, TrackSpawner, Player, HUD)।
3. **03_STATE_MACHINE_SPEC.md** — प्लेयर की हर स्टेट (IDLE, RUNNING, JUMPING, SLIDING, TURNING_LEFT, TURNING_RIGHT, STUMBLE, DEAD), उनके इनपुट ट्रिगर्स और कोलिजन-शेप बदलावों के साथ।
4. **04_PROCEDURAL_TRACK_ALGO.md** — 12–15 रीसायकल होने वाले ट्रैक टाइल्स की ऑब्जेक्ट पूलिंग, और ऐसे ऑब्स्टैकल-स्पॉन नियम जो गारंटी दें कि कोई रास्ता कभी 100% ब्लॉक न हो।
5. **05_ASSET_MANIFEST.md** — CC0 लो-पॉली 3D मेश, हल्के मैटेरियल्स और ऑडियो इफेक्ट्स के पाथ।
6. **06_SECURITY_AND_PERFORMANCE.md** — मोबाइल बजट (60 FPS, ≤50 ड्रॉ-कॉल्स, <100k पॉलीगॉन्स) और AES-256 एन्क्रिप्टेड सेव डेटा।
7. **07_PLAY_STORE_COMPLIANCE.md** — टारगेट SDK, मिनिमम परमिशन सेट, और स्क्रीन-नॉच / सेफ-एरिया हैंडलिंग।

## 9. रेट-लिमिट और कॉस्ट का गणित

कोटा इस तरह चुना गया है कि पाइपलाइन पूरे वर्किंग डे बिना किसी लिमिट तक पहुंचे चल सके:

- **NVIDIA NIM:** 40 रिक्वेस्ट प्रति मिनट — पूरे दिन लगातार कोडिंग के लिए पर्याप्त।
- **Gemini Flash Lite:** लगभग 13–14 रिक्वेस्ट प्रति मिनट और 450 रिक्वेस्ट प्रति दिन प्रति key; दो keys से मोटे तौर पर 27 RPM और 900 RPD।
- अगर एजेंट हर तीन मिनट में एक 5-सेकंड की क्लिप रिकॉर्ड और इंस्पेक्ट करता है, तो यह लगभग 20 रिक्वेस्ट प्रति घंटा और दस घंटे के दिन में केवल 200–250 होता है — 900 RPD के बजट के भीतर बिल्कुल।

## 10. Google Play 2026 कम्प्लायंस

एक्सपोर्ट स्टेज चार नियम अपने आप लागू करता है:

1. **टारगेट API लेवल** Android 15/16 (API लेवल 35+)।
2. **जीरो अननेसेसरी परमिशन** — कोई कैमरा, लोकेशन या माइक्रोफोन नहीं; केवल VIBRATE जैसी बेसिक चीज़ें।
3. **App Bundle (AAB)** — 64-bit `arm64-v8a` स्प्लिट AAB, जिससे डाउनलोड लगभग 25–30 MB से कम रहे।
4. **सिक्योर सेव डेटा** — कॉइन्स और हाई-स्कोर प्लेन JSON के बजाय Godot के `FileAccess.open_encrypted_with_pass()` से एन्क्रिप्ट किए जाते हैं, ताकि चीटिंग रुके।

## 11. सेटअप कमांड्स (अपेंडिक्स)

क्लाउड CPU टर्मिनल पर एक बार का एनवायरनमेंट सेटअप:

```bash
# 1. Virtual display, CPU 3D renderer, audio and FFmpeg
sudo apt-get update
sudo apt-get install -y xvfb pulseaudio ffmpeg libgl1-mesa-dri mesa-utils unzip wget python3-pip

# 2. Godot 4.x headless Linux binary
wget https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
unzip Godot_v4.7.2-stable_linux.x86_64.zip
sudo mv Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot
chmod +x /usr/local/bin/godot

# 3. Ponytail and Strix skills
npm install -g @deepseek-ai/dsh
npx skills add https://github.com/dietrichgebert/ponytail --skill ponytail
npx skills add usestrix/strix

# 4. Python libraries
pip install google-genai requests

# 5. Start the virtual display and dummy audio
pulseaudio -D --exit-idle-time=-1
Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99
```

## स्रोत

ऊपर दी गई योजना इन संदर्भों से तैयार की गई है, जो इसके डिज़ाइन के दौरान उद्धृत किए गए:

1. Best AI Agents for Godot in 2026: MCP, Plugins & Tools — SoonLab
2. Godot RL Agents — Hugging Face
3. godot-mcp — AI Agents on GitHub — SkillsLLM
4. Godot Engine — Free and open source 2D and 3D game engine
5. AI Models by NVIDIA | Try NVIDIA NIM APIs
6. Gemini 3.1 Flash-Lite | Gemini API — Google AI for Developers
7. Gemma models overview — Google AI for Developers
8. Laya Model: Open-Source Decision AI You Can Run Locally
9. What Is Laya? Laya vs Jev — Medium
