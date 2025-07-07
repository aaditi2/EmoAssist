import SwiftUI

struct AgentCardView: View {
    let agent: Agent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: agent.avatarURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text(agent.name)
                .font(.headline)
                .foregroundColor(.white)

            Text(agent.specialty)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            HStack {
                Label("\(agent.rating, specifier: "%.1f")", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                Label("\(agent.callCount)k", systemImage: "phone.fill")
                    .foregroundColor(.white.opacity(0.6))
            }
            .font(.caption2)

            if agent.isFeatured {
                Text("⭐ Featured")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
