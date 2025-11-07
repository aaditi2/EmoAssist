# 🧠 EmoAssist – AI-Powered Voice Therapy Companion

**EmoAssist** is an AI-driven voice therapy app built with **SwiftUI**, **AVFoundation**, and **Speech Framework**, offering real-time speech recognition, emotion detection, and soothing AI responses through natural voice synthesis.  

---

## 🌟 Features

- 🎙️ **Real-Time Speech Recognition** – Seamless live transcription using Apple’s Speech framework.  
- 💬 **Therapeutic AI Responses** – Integrated **Together.ai** backend that provides calming, emotion-aware replies.  
- 🧘 **Emotion Detection** – Detects tone (calm, anxious, reflective, etc.) using contextual AI analysis.  
- 🔊 **Voice Synthesis** – Responds with gentle, natural-sounding speech using `AVSpeechSynthesizer`.  
- 🪄 **Privacy-Focused Design** – All speech and transcripts are processed locally and cleared automatically.  
- 🌈 **Apple-Style Interface** – Minimal, glassmorphic SwiftUI design inspired by Apple’s health and mindfulness apps.  

---

## 🧩 Tech Stack

| Layer | Technologies |
|-------|---------------|
| **UI / UX** | SwiftUI, SF Symbols, UIKit gradient bridge |
| **Audio Processing** | AVFoundation, `AVAudioSession` |
| **Speech Recognition** | `SFSpeechRecognizer`, Async Streams |
| **Voice Generation** | `AVSpeechSynthesizer`, async-safe handling |
| **Backend (LLM)** | Together.ai REST API |
| **Architecture** | MVVM, `@MainActor`, `async/await` concurrency |
| **Logging** | OSLog with structured subsystem categories |

---

## 📸 Screenshots
<img src="https://github.com/user-attachments/assets/68a6b705-4f3e-43ba-aa0d-1949020ed3d6" width="230"/>
<img src="https://github.com/user-attachments/assets/28bcb7a2-149c-4bc0-9123-d7713a08c1b4" width="230"/>
<img src="https://github.com/user-attachments/assets/22d462e2-6f78-47c7-85c2-f229a3ebcfed" width="230"/>

---
## 🛠️ Setup Instructions

 Clone the repository  
   ```bash
   git clone https://github.com/aaditi2/EmoAssist.git
   cd EmoAssist
