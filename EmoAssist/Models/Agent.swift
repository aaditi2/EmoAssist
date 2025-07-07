import Foundation

enum AgentCategory: String, Codable, CaseIterable {
    case therapist = "Therapist"
    case celebrity = "Celebrity"
    case personality = "Personality"
}

struct Agent: Identifiable, Codable {
    var id: UUID
    var name: String
    var category: AgentCategory
    var specialty: String
    var description: String
    var avatarURL: String
    var backgroundGradient: String
    var callCount: Int
    var rating: Double
}

