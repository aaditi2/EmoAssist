# EmoAssist

EmoAssist is an iOS 17 SwiftUI application that delivers a private, audio-only therapy experience. The app captures speech on-device, converts it to text with `SFSpeechRecognizer`, routes the transcript through a Together.ai powered therapy pipeline, and speaks an empathetic response back to the user. The entire conversation lifecycle is orchestrated with Swift Concurrency and instrumented with `OSLog` so that every stage—listening, thinking, and speaking—remains observable.

## Features

- 🎙️ **Hands-free voice sessions** – `VoiceTherapyView` and `VoiceTherapyViewModel` coordinate microphone access, transcription streaming, and playback state transitions.
- 🧠 **Therapy pipeline with Together.ai** – `GPTTherapyPipeline` composes recent `TherapyTurn` history and calls `TogetherTherapyService` for emotion-aware support.
- 🔊 **Robust audio stack** – `SpeechRecognitionService`, `AudioSessionController`, and `SpeechSynthesisService` manage permissions, audio routing, and natural speech output.
- 📓 **Conversation timeline** – Each exchange is rendered in a secure, on-device timeline that clears between sessions for privacy.
- 🌌 **Explorable agent catalog (prototype)** – SwiftUI views such as `HomeView`, `AgentCardView`, and `AgentDetailView` showcase mock conversational agents for future expansion.

## Project Structure

```
EmoAssist/
├─ EmoAssist.xcodeproj           # Xcode project targeting iOS 17+
├─ EmoAssistApp.swift            # SwiftUI entry point
├─ ContentView.swift             # Hosts the active feature screen
├─ VoiceTherapyView.swift        # Primary user experience
├─ ViewModels/
│  └─ VoiceTherapyViewModel.swift
├─ Services/
│  ├─ Audio/
│  │  ├─ AudioSessionController.swift
│  │  ├─ SpeechRecognitionService.swift
│  │  └─ SpeechSynthesisService.swift
│  ├─ Therapy/
│  │  └─ TherapyPipeline.swift
│  └─ ApiService.swift           # Together.ai integration
├─ Models/                       # Agent & therapy domain models
├─ Views/                        # Additional SwiftUI screens (prototype catalog)
└─ Extensions/
   └─ Color+Hex.swift            # Utility initialiser for hex colours
```

## Getting Started

1. **Requirements**
   - Xcode 15 or newer
   - iOS 17 simulator or device with working microphone
   - Together.ai API key
2. **Clone & open** – `git clone` the repo and open `EmoAssist.xcodeproj` in Xcode.
3. **Configure secrets** – Replace the placeholder token in `Secrets.swift` with your Together.ai API key. Avoid committing real keys; consider moving this value into an `.xcconfig` or environment-specific build setting for production use.
4. **Select a run destination** – Choose an iOS 17+ simulator (or a physical device with microphone access) and build (`⌘B`).
5. **Grant permissions on first launch** – The app will request Speech Recognition and Microphone permissions via `SpeechRecognitionService.ensureAllPermissions()`.

## Using EmoAssist

1. Tap the microphone button to activate listening. The status card will transition to **Listening…**, and the transcript area will stream partial text using an `AsyncThrowingStream`.
2. Tap the button again to finish speaking. The view model sends the transcript to `GPTTherapyPipeline`, which aggregates recent conversation context and calls Together.ai.
3. EmoAssist speaks the therapist’s response with `AVSpeechSynthesizer` while updating the detected emotion badge.
4. Each `TherapyTurn` is appended to the timeline. Stopping playback or encountering an error automatically deactivates the `AVAudioSession` to release the microphone.

## Architecture Highlights

- **Swift Concurrency throughout** – The voice session life cycle uses async/await for permission handling, audio streaming, API calls, and speech synthesis.
- **Error handling & recovery** – All services log to `OSLog` and surface user-facing errors through `VoiceTherapyViewModel.IdentifiableError`, allowing the UI to present alerts and reset safely.
- **Dependency seams for testing** – `TherapyPipeline` is protocol-oriented, enabling alternative implementations (e.g., offline mock therapy) to be injected for previews or tests.
- **Privacy-first design** – Only text transcripts leave the device; audio buffers stay local. The timeline is cleared when the session resets, and no persistence layer is enabled by default.

## Development Notes

- **Mock catalog** – `mockAgents` in `Models/MockData.swift` powers the exploratory `HomeView` and related UI components. These views are not yet wired into `ContentView` but provide a foundation for future navigation or onboarding experiences.
- **Secrets management** – The repository currently stores the API key constant for convenience. Replace it with a secure mechanism (e.g., environment-specific `.xcconfig` file or CI secrets) before distributing the app.
- **Logging** – Categories such as `speech-service`, `therapy-pipeline`, and `voice-view-model` make it easy to filter logs in the Console app during debugging.

## Roadmap Ideas

- Integrate the agent catalog into the main navigation and allow users to pick a persona before starting therapy.
- Add persistence for conversation history with user consent, leveraging Core Data or CloudKit.
- Provide unit tests around `VoiceTherapyViewModel` and introduce dependency injection for the speech services.
- Offer offline fallback responses when Together.ai is unavailable.

## License

This project is provided as-is for demonstration purposes. Consult the repository owner for licensing details before using EmoAssist in production.
