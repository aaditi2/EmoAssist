import SwiftUI

struct HomeView: View {
    @State private var featuredAgents: [Agent] = []
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

                // MARK: - Featured Agent
                if let featured = featuredAgents.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🌟 Featured")
                            .font(.headline)
                            .foregroundColor(.white)

                        AgentCardView(agent: featured)
                    }
                    .padding(.horizontal)
                }

                // MARK: - Categories
                ForEach(groupedAgents().sorted(by: { $0.key < $1.key }), id: \.key) { category, agents in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category)
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
        let all = mockAgents
        self.featuredAgents = all.filter { $0.isFeatured }
        self.allAgents = all
    }

    private func groupedAgents() -> [String: [Agent]] {
        Dictionary(grouping: allAgents.filter { !$0.isFeatured }, by: { $0.category.rawValue })
    }
}
