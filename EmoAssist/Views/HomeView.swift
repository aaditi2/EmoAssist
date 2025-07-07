import SwiftUI

struct HomeView: View {
    @State private var allAgents: [Agent] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // MARK: - Hero
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emo Assistant")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                    Text("Experience meaningful conversations with AI personalities crafted for every need")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.subheadline)
                }
                .padding(.horizontal)

                // MARK: - Stats
                HStack(spacing: 11) {
                    StatCard(title: "24/7", subtitle: "Available")
                    StatCard(title: "50+", subtitle: "AI Agents")
                    StatCard(title: "1M+", subtitle: "Conversations")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // MARK: - Categories
                ForEach(groupedAgentsOrdered(), id: \.0) { category, agents in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(agents) { agent in
                                    AgentCardView(agent: agent)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 20)
        }
        .background(
            LinearGradient(colors: [Color.black, Color.blue], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear {
            loadMockData()
        }
    }

    // MARK: - Mock Data
    private func loadMockData() {
        self.allAgents = mockAgents
    }

    private func groupedAgentsOrdered() -> [(AgentCategory, [Agent])] {
        let groups = Dictionary(grouping: allAgents, by: { $0.category })
        let order: [AgentCategory] = [.therapist, .celebrity, .personality]
        return order.compactMap { cat in
            guard let agents = groups[cat] else { return nil }
            return (cat, agents)
        }
    }
}
