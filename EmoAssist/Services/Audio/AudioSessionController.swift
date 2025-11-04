import AVFoundation
import OSLog

@MainActor
final class AudioSessionController {
    static let shared = AudioSessionController()

    private let session = AVAudioSession.sharedInstance()
    private let logger = Logger(subsystem: "com.emoassist.app", category: "audio-session")

    private init() {}

    func activateTherapyMode() throws {
        logger.log("Activating audio session for therapy mode")
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Failed to activate audio session: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    func deactivate() {
        do {
            logger.log("Deactivating audio session")
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Failed to deactivate audio session: \(error.localizedDescription, privacy: .public)")
        }
    }
}
