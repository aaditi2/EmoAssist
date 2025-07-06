import SwiftUI
import AVFoundation

struct VoiceTherapyView: View {
    @State private var isListening = false
    @State private var recordedText = ""
    @State private var response = ""
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 30) {
            Text("🎙️ EmoAssist – Voice Therapy")
                .font(.title2)
                .bold()

            Spacer()

            if isListening {
                ProgressView("Listening...")
            } else if !response.isEmpty {
                Text("Sara: \(response)")
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                startSession()
            }) {
                Text(isListening ? "Listening..." : "Tap to Speak")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isListening)

            Spacer()
        }
        .padding()
    }

    func startSession() {
        isListening = true
        recordedText = "I feel like I’m not good enough lately." // Simulated for now

        // Simulated API call
        Task {
            if let reply = await fetchReply(for: recordedText) {
                self.response = reply
                speak(reply)
            } else {
                self.response = "Sorry, I couldn’t understand."
            }
            isListening = false
        }
    }

    func fetchReply(for message: String) async -> String? {
        guard let url = URL(string: "http://127.0.0.1:8080/chat") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            // Debug logs to inspect what you're getting
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Server raw response: \(raw)")
            }

            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            return decoded.reply

        } catch {
            print("❌ API decoding error: \(error.localizedDescription)")
        }

        return nil
    }


    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

struct ChatResponse: Codable {
    let reply: String
}

