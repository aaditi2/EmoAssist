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
                HStack(spacing: 16) {
                    StatCard(title: String(format: "%.1f", agent.rating), subtitle: "Rating")
                    StatCard(title: "\(agent.callCount)k", subtitle: "Calls")
                    StatCard(title: "24/7", subtitle: "Available")
                }
                .frame(maxWidth: .infinity)

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
