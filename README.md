# AR VR

Flutter application for a youth center with:

- **Augmented Reality (AR)** to display interactive 3D models.
- **Live projects** with camera, microphone, and real-time chat.
- **Supabase** integration for data storage and messaging.

## Main features

- **AR View** (`ArViewScreen`)
  - Loads 3D models (GLB) from assets.
  - Plane detection and model placement on the surface.
  - Pinch to zoom.
  - Drag to move the model on the plane.
  - **AI assistant button**:
    - Toggle ON/OFF (round button at the top-right).
    - Assistant panel with **voice command** (speech-to-text).

- **Live Page** (`LivePage`)
  - Camera preview (live).
  - Text chat bound to a project (`projectTitle`).
  - Automatic message refresh.
  - Basic microphone / camera handling.

## Getting started

### Prerequisites

- Flutter installed (compatible with `sdk: ^3.7.2`).
- Android Studio / Xcode to run on an emulator or real device.

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## AR – technical notes

- AR plugin used: `ar_flutter_plugin_engine`.
- GLB models are copied into the app’s documents folder from the assets.
- Interaction:
  - **Tap** on a detected plane → place a 3D model.
  - **Pinch** → change the model scale.
  - **Drag** → move the model on the plane.

## Voice AI assistant

- Based on the `speech_to_text` package.
- Recognized text is sent to a handler (`_onSendAiMessage`) that can be wired to a backend AI.
- Microphone button has an animated wave effect while listening.

## Backend & AI services

- **`ai next_verse`**: Python subproject for AI services (FastAPI + DeepSeek/Gemini).
  - New **MindSpore** module (`ai next_verse/MindSpore.py`) to experiment with neural networks using MindSpore.
  - MindSpore installation depends on your platform (CPU / GPU) – see the official docs: https://www.mindspore.cn/install

## Project structure (quick view)

- `lib/screens/ar/ar_view_screen.dart`: AR screen + AI assistant.
- `lib/screens/projects/live_page.dart`: live page with camera/chat.
- `lib/config/`: UI configuration and other utilities.
- `ai next_verse/`: AI backend + MindSpore module for ML experimentation.

## License

Private project – internal use for the youth center (adapt if needed).
