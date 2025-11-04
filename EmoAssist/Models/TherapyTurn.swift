import Foundation

struct TherapyTurn: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let userUtterance: String
    let therapistResponse: String
    let detectedEmotion: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        userUtterance: String,
        therapistResponse: String,
        detectedEmotion: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.userUtterance = userUtterance
        self.therapistResponse = therapistResponse
        self.detectedEmotion = detectedEmotion
    }
}
