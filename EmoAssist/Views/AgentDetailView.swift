import SwiftUI

struct AgentDetailView: View {
    let agent: Agent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(agent.name)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text(agent.specialty)
                    .foregroundColor(.white.opacity(0.7))

                // Stats
                HStack {
                    StatBox(title: String(format: "%.1f", agent.rating), subtitle: "Rating")
                    StatBox(title: "\(agent.callCount)k", subtitle: "Calls")
                    StatBox(title: "24/7", subtitle: "Available")
                }

                // About
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(agent.description)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
