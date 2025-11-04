import Foundation
import AVFoundation
import Speech
import OSLog

@MainActor
final class SpeechRecognitionService: NSObject {
    private let engine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let logger = Logger(subsystem: "com.emoassist.app", category: "speech-service")

    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    // MARK: - Combined Permissions

    /// Requests both Speech and Microphone permissions in proper order.
    func ensureAllPermissions() async throws {
        try await ensureSpeechPermissions()
        try await ensureMicPermissions()
    }

    private func ensureSpeechPermissions() async throws {
        logger.log("Requesting Speech Recognition permission")

        let status = await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { cont.resume(returning: $0) }
        }

        guard status == .authorized else {
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"]
            )
        }
    }

    private func ensureMicPermissions() async throws {
        logger.log("Requesting Microphone permission")

        let session = AVAudioSession.sharedInstance()
        let permission = session.recordPermission
        switch permission {
        case .granted:
            return
        case .denied:
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -11,
                userInfo: [NSLocalizedDescriptionKey: "Microphone access denied"]
            )
        case .undetermined:
            let granted = await withCheckedContinuation { cont in
                session.requestRecordPermission { cont.resume(returning: $0) }
            }
            guard granted else {
                throw NSError(
                    domain: "SpeechRecognitionService",
                    code: -12,
                    userInfo: [NSLocalizedDescriptionKey: "Microphone permission not granted"]
                )
            }
        @unknown default:
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -13,
                userInfo: [NSLocalizedDescriptionKey: "Unknown microphone permission state"]
            )
        }
    }

    // MARK: - Configuration

    /// Configures the speech recognizer once permissions are granted.
    func configureRecognizer() async throws {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        guard recognizer != nil else {
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Speech recognizer unavailable"]
            )
        }
        logger.log("Speech recognizer configured")
    }

    // MARK: - Start Streaming

    func startStreaming() async throws -> AsyncThrowingStream<String, Error> {
        logger.log("Starting speech stream safely")

        guard let recognizer else {
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Recognizer not configured"]
            )
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else {
            throw NSError(
                domain: "SpeechRecognitionService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create recognition request"]
            )
        }

        request.shouldReportPartialResults = true

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0) // safety: ensure no duplicate taps
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        engine.prepare()
        try engine.start()  // Safe because we’re already on @MainActor

        logger.log("Audio engine started")

        return AsyncThrowingStream { continuation in
            self.continuation = continuation

            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let error {
                    self.logger.error("Recognition error: \(error.localizedDescription, privacy: .public)")
                    continuation.finish(throwing: error)
                    self.stop()
                    return
                }

                if let text = result?.bestTranscription.formattedString {
                    continuation.yield(text)
                }

                if result?.isFinal == true {
                    continuation.finish()
                    self.stop()
                }
            }

            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.logger.log("Speech stream terminated")
                    self.stop()
                }
            }
        }
    }

    // MARK: - Stop

    func stop() {
        logger.log("Stopping speech engine")
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        continuation?.finish()
        continuation = nil
    }
}
