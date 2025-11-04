import AVFoundation
import OSLog
import Speech

@MainActor
final class SpeechRecognitionService: NSObject, SFSpeechRecognizerDelegate {
    enum RecognitionError: LocalizedError {
        case authorizationDenied
        case recognizerUnavailable

        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "Microphone permissions are required to continue."
            case .recognizerUnavailable:
                return "Speech recognizer is currently unavailable."
            }
        }
    }

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?
    private let logger = Logger(subsystem: "com.emoassist.app", category: "speech")
    private var isAuthorized = false

    override init() {
        super.init()
        recognizer?.delegate = self
    }

    func prepare() async throws {
        guard !isAuthorized else { return }

        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authorizationStatus in
                continuation.resume(returning: authorizationStatus)
            }
        }

        switch status {
        case .authorized:
            isAuthorized = true
            logger.log("Speech recognition authorized")
        case .denied, .restricted:
            logger.error("Speech recognition authorization denied")
            throw RecognitionError.authorizationDenied
        case .notDetermined:
            logger.error("Speech recognition authorization not determined")
            throw RecognitionError.authorizationDenied
        @unknown default:
            logger.error("Speech recognition authorization unknown")
            throw RecognitionError.authorizationDenied
        }
    }

    func startStreaming() throws -> AsyncThrowingStream<String, Error> {
        guard isAuthorized else {
            throw RecognitionError.authorizationDenied
        }

        guard let recognizer, recognizer.isAvailable else {
            logger.error("Speech recognizer unavailable")
            throw RecognitionError.recognizerUnavailable
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        self.request = request

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        engine.prepare()
        try engine.start()
        logger.log("Speech engine started")

        return AsyncThrowingStream { continuation in
            self.continuation = continuation

            self.task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let result {
                    let transcription = result.bestTranscription.formattedString
                    self.logger.debug("Partial transcription: \(transcription, privacy: .public)")
                    continuation.yield(transcription)

                    if result.isFinal {
                        self.logger.log("Received final transcription")
                        continuation.finish()
                    }
                }

                if let error {
                    self.logger.error("Recognition error: \(error.localizedDescription, privacy: .public)")
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { [weak self] _ in
                self?.logger.log("Speech stream terminated")
                self?.stop()
            }
        }
    }

    func stop() {
        logger.log("Stopping speech engine")
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        continuation?.finish()
        continuation = nil
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        logger.log("Speech recognizer availability changed: \(available, privacy: .public)")
    }
}
