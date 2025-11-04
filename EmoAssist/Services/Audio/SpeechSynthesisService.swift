import AVFoundation
import OSLog

@MainActor
final class SpeechSynthesisService: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var continuation: CheckedContinuation<Void, Never>?
    private let logger = Logger(subsystem: "com.emoassist.app", category: "speech-synthesis")

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        logger.log("Speaking therapist response")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            if let pending = self.continuation {
                pending.resume()
            }
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
            }
            self.continuation = continuation
            self.synthesizer.speak(utterance)
        }
    }

    func stop() {
        logger.log("Stopping speech synthesis")
        synthesizer.stopSpeaking(at: .immediate)
        continuation?.resume()
        continuation = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let continuation {
            continuation.resume()
            self.continuation = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        if let continuation {
            continuation.resume()
            self.continuation = nil
        }
    }
}
