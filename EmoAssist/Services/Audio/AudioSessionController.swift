import AVFoundation
import OSLog

@MainActor
final class AudioSessionController {
    static let shared = AudioSessionController()

    private let session = AVAudioSession.sharedInstance()
    private let logger = Logger(subsystem: "com.emoassist.app", category: "audio-session")

    private init() {}

    /// Activate the session in voice-chat mode (safe order + correct flags)
    func activateTherapyMode() throws {
        logger.log("Activating audio session for therapy mode")

        do {
            // 1️⃣ Configure first
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers]
            )

            // 2️⃣ Activate with no options; NotifyOthersOnDeactivation is for deactivation
            try session.setActive(true)
            logger.log("Audio session activated successfully")
        } catch {
            logger.error("Failed to activate audio session: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    /// Deactivate and release mic access cleanly
    func deactivate() {
        do {
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
            logger.log("Audio session deactivated")
        } catch {
            logger.error("Failed to deactivate audio session: \(error.localizedDescription, privacy: .public)")
        }
    }
}
