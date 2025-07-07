import Foundation

// MARK: - Codable structs
struct ChatRequest: Codable {
    let message: String
}



// MARK: - API Service
class ApiService {
    static let shared = ApiService()
    
    private init() {}
    
    func getReply(for message: String) async -> String? {
        guard let url = URL(string: "http://10.0.0.122:8080/chat") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(message: message)
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            return decoded.reply
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
            return nil
        }
    }
}
