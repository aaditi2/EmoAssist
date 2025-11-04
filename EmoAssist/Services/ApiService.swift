import Foundation
import OSLog

struct TogetherChatMessage: Codable {
    let role: String
    let content: String
}

struct TogetherChatRequest: Codable {
    let model: String
    let messages: [TogetherChatMessage]
    let temperature: Double
    let topP: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topP = "top_p"
        case maxTokens = "max_tokens"
    }
}

struct TogetherChatChoice: Codable {
    let message: TogetherChatMessage
}

struct TogetherChatResponse: Codable {
    let choices: [TogetherChatChoice]
}

struct TherapeuticSupport: Codable {
    let support: String
    let emotion: String
}

final class TogetherTherapyService {
    private let endpoint = URL(string: "https://api.together.xyz/v1/chat/completions")!
    private let session: URLSession
    private let logger = Logger(subsystem: "com.emoassist.app", category: "together")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateSupport(
        for utterance: String,
        history: [TherapyTurn]
    ) async throws -> TherapeuticSupport {
        var messages: [TogetherChatMessage] = [
            TogetherChatMessage(
                role: "system",
                content: "You are EmoAssist, a compassionate voice therapist. Keep answers concise, soothing, and actionable. Respond in JSON with keys support and emotion."
            )
        ]

        let recentHistory = history.suffix(6)
        for turn in recentHistory {
            messages.append(TogetherChatMessage(role: "user", content: turn.userUtterance))
            messages.append(TogetherChatMessage(role: "assistant", content: turn.therapistResponse))
        }

        messages.append(TogetherChatMessage(role: "user", content: utterance))

        let requestPayload = TogetherChatRequest(
            model: "meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo",
            messages: messages,
            temperature: 0.7,
            topP: 0.9,
            maxTokens: 512
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard !Secrets.togetherAPIKey.isEmpty else {
            logger.error("Together API key missing")
            throw URLError(.userAuthenticationRequired)
        }
        request.setValue("Bearer \(Secrets.togetherAPIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestPayload)

        logger.log("Sending Together request")
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            logger.error("Together request failed: \(httpResponse.statusCode, privacy: .public) body=\(body, privacy: .public)")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TogetherChatResponse.self, from: data)
        guard
            let content = decoded.choices.first?.message.content.data(using: .utf8),
            let support = try? JSONDecoder().decode(TherapeuticSupport.self, from: content)
        else {
            logger.error("Failed to decode therapeutic response")
            throw URLError(.cannotParseResponse)
        }

        logger.log("Received therapeutic support with emotion \(support.emotion, privacy: .public)")
        return support
    }
}
