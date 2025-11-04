import Foundation
import OSLog

protocol TherapyPipeline {
    func respond(to utterance: String, history: [TherapyTurn]) async throws -> TherapyTurn
}

@MainActor
final class GPTTherapyPipeline: TherapyPipeline {
    private let service: TogetherTherapyService
    private let logger = Logger(subsystem: "com.emoassist.app", category: "therapy-pipeline")

    init(service: TogetherTherapyService = TogetherTherapyService()) {
        self.service = service
    }

    func respond(to utterance: String, history: [TherapyTurn]) async throws -> TherapyTurn {
        logger.log("Generating therapeutic response")
        let support = try await service.generateSupport(for: utterance, history: history)

        return TherapyTurn(
            id: UUID(),
            timestamp: Date(),
            userUtterance: utterance,
            therapistResponse: support.support,
            detectedEmotion: support.emotion
        )
    }
}
