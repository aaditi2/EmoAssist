import Foundation
import OSLog

@MainActor
final class VoiceTherapyViewModel: ObservableObject {
    enum SessionState: Equatable {
        case idle
        case listening
        case thinking
        case speaking
        case error

        var statusText: String {
            switch self {
            case .idle:
                return "Ready to listen"
            case .listening:
                return "Listening…"
            case .thinking:
                return "Processing feelings…"
            case .speaking:
                return "Responding"
            case .error:
                return "Needs attention"
            }
        }
    }

    struct IdentifiableError: Identifiable {
        let id = UUID()
        let message: String
    }

    @Published var sessionState: SessionState = .idle
    @Published var transcript: String = ""
    @Published var conversation: [TherapyTurn] = []
    @Published var detectedEmotion: String? = nil
    @Published var activeError: IdentifiableError?

    private let speechService = SpeechRecognitionService()
    private let audioSession = AudioSessionController.shared
    private let synthesisService = SpeechSynthesisService()
    private let pipeline: TherapyPipeline
    private let logger = Logger(subsystem: "com.emoassist.app", category: "voice-view-model")

    private var transcriptionTask: Task<Void, Never>?

    init(pipeline: TherapyPipeline = GPTTherapyPipeline()) {
        self.pipeline = pipeline
    }

    func prepareSession() async {
        do {
            try await speechService.prepare()
        } catch {
            handleError(error)
        }
    }

    func toggleMicrophone() {
        switch sessionState {
        case .idle, .error:
            startListening()
        case .listening:
            stopListeningAndProcess()
        case .thinking, .speaking:
            cancelPlayback()
        }
    }

    func reset() {
        speechService.stop()
        audioSession.deactivate()
        transcriptionTask?.cancel()
        transcriptionTask = nil
        sessionState = .idle
        transcript = ""
    }

    private func startListening() {
        logger.log("Starting listening phase")
        transcript = ""

        do {
            try audioSession.activateTherapyMode()
            let stream = try speechService.startStreaming()
            sessionState = .listening

            transcriptionTask?.cancel()
            transcriptionTask = Task { [weak self] in
                guard let self else { return }

                do {
                    for try await partial in stream {
                        guard !Task.isCancelled else { break }
                        await MainActor.run {
                            self.transcript = partial
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.handleError(error)
                    }
                }
            }
        } catch {
            handleError(error)
        }
    }

    private func stopListeningAndProcess() {
        logger.log("Stopping listening phase")
        speechService.stop()
        transcriptionTask?.cancel()
        transcriptionTask = nil
        audioSession.deactivate()

        let utterance = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !utterance.isEmpty else {
            sessionState = .idle
            return
        }

        sessionState = .thinking
        Task { [weak self] in
            await self?.process(utterance: utterance)
        }
    }

    private func process(utterance: String) async {
        logger.log("Processing transcript with therapy pipeline")
        do {
            let turn = try await pipeline.respond(to: utterance, history: conversation)
            conversation.append(turn)
            detectedEmotion = turn.detectedEmotion

            sessionState = .speaking
            await synthesisService.speak(turn.therapistResponse)
            sessionState = .idle
            transcript = ""
        } catch {
            handleError(error)
        }
    }

    private func cancelPlayback() {
        logger.log("Cancelling playback")
        synthesisService.stop()
        audioSession.deactivate()
        sessionState = .idle
    }

    private func handleError(_ error: Error) {
        logger.error("Pipeline error: \(error.localizedDescription, privacy: .public)")
        audioSession.deactivate()
        activeError = IdentifiableError(message: error.localizedDescription)
        sessionState = .error
    }
}
