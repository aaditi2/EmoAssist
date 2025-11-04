import Foundation
import OSLog

@MainActor
final class VoiceTherapyViewModel: ObservableObject {
    enum SessionState: Equatable {
        case idle, listening, thinking, speaking, error

        var statusText: String {
            switch self {
            case .idle:      return "Ready to listen"
            case .listening: return "Listening…"
            case .thinking:  return "Processing feelings…"
            case .speaking:  return "Responding"
            case .error:     return "Needs attention"
            }
        }
    }

    struct IdentifiableError: Identifiable {
        let id = UUID()
        let message: String
    }

    // MARK: - Published State
    @Published var sessionState: SessionState = .idle
    @Published var transcript: String = ""
    @Published var conversation: [TherapyTurn] = []
    @Published var detectedEmotion: String? = nil
    @Published var activeError: IdentifiableError?

    // MARK: - Services
    private let speechService = SpeechRecognitionService()
    private let audioSession = AudioSessionController.shared
    private let synthesisService = SpeechSynthesisService()
    private var pipeline: TherapyPipeline?
    private let logger = Logger(subsystem: "com.emoassist.app", category: "voice-view-model")
    private var transcriptionTask: Task<Void, Never>?

    // MARK: - Init
    init() {
        Task {
            self.pipeline = GPTTherapyPipeline()
            logger.log("Therapy pipeline initialized")
        }
    }

    // MARK: - Setup
    func prepareSession() async {
        do {
            // Request both permissions first
            try await speechService.ensureAllPermissions()
            
            // Then activate audio session
            try audioSession.activateTherapyMode()
            
            // Prepare recognizer safely
            try await speechService.configureRecognizer()
            
            logger.log("Therapy session ready")
        } catch {
            handleError(error)
        }
    }


    // MARK: - Mic Control
    func toggleMicrophone() async {
        switch sessionState {
        case .idle, .error:
            await startListening()
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

    // MARK: - Listening
    private func startListening() async {
        logger.log("Starting listening phase")
        transcript = ""

        do {
            try audioSession.activateTherapyMode()
            let stream = try await speechService.startStreaming()
            sessionState = .listening

            transcriptionTask?.cancel()
            transcriptionTask = Task { [weak self] in
                guard let self else { return }
                do {
                    for try await partial in stream {
                        guard !Task.isCancelled else { break }
                        await MainActor.run { self.transcript = partial }
                    }
                } catch {
                    await MainActor.run { self.handleError(error) }
                }
            }
        } catch {
            handleError(error)
        }
    }

    // MARK: - Processing
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

        guard let pipeline else {
            handleErrorMessage("Therapy pipeline not initialized yet.")
            return
        }

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

    // MARK: - Playback
    private func cancelPlayback() {
        logger.log("Cancelling playback")
        synthesisService.stop()
        audioSession.deactivate()
        sessionState = .idle
    }

    // MARK: - Errors
    private func handleError(_ error: Error) {
        logger.error("Pipeline error: \(error.localizedDescription, privacy: .public)")
        audioSession.deactivate()
        activeError = IdentifiableError(message: error.localizedDescription)
        sessionState = .error
    }

    private func handleErrorMessage(_ message: String) {
        logger.error("Pipeline error: \(message, privacy: .public)")
        audioSession.deactivate()
        activeError = IdentifiableError(message: message)
        sessionState = .error
    }
}
