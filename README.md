# EmoAssist – Audio-Only Emotion-Aware Therapist

EmoAssist is a privacy-first Siri-style companion that delivers real-time voice therapy with Together.ai powered emotional intelligence. The app captures your voice privately on device, streams transcriptions with Swift Concurrency, and returns empathetic, emotionally-aware responses that are read back with natural speech.

## Features

- 🎙️ **Real-time voice sessions** – tap once to start talking and EmoAssist keeps an on-device transcript that clears after every response.
- 🧠 **GPT-based emotional support** – Together.ai's Llama 3.1 Turbo powers the therapist persona and returns both a supportive reply and the emotion it hears in your voice.
- ⚡ **Swift Concurrency audio runtime** – modular `SpeechRecognitionService`, `SpeechSynthesisService`, and `AudioSessionController` keep latency low while remaining testable.
- 📊 **Structured telemetry** – OSLog instrumentation across the pipeline makes it easy to diagnose latency or availability issues in production.
- 🌐 **Future-ready architecture** – shared services and pipelines are platform agnostic, making it simple to extend EmoAssist to watchOS or other Apple platforms.

## Getting Started

1. Open `EmoAssist.xcodeproj` in Xcode 15 or newer.
2. Provide a Together.ai API key in `Secrets.swift` (already referenced by `TogetherTherapyService`).
3. Build & run on an iOS 17 simulator or device with a working microphone.
4. Tap the microphone button, speak naturally, and wait for EmoAssist to respond.

## Privacy

All voice audio stays on device – only the text transcription is sent to Together.ai for response generation. No conversation history is persisted after the session ends.

## Architecture Overview

```
VoiceTherapyView
   └── VoiceTherapyViewModel
           ├── SpeechRecognitionService (AVAudioEngine + SFSpeechRecognizer)
           ├── SpeechSynthesisService (AVSpeechSynthesizer)
           ├── AudioSessionController (AVAudioSession lifecycle)
           └── GPTTherapyPipeline → TogetherTherapyService → Together.ai
```

Logs are emitted with `OSLog` categories so that you can plug into the Console app or oslog streams for diagnostics.
