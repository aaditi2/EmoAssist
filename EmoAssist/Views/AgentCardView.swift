import SwiftUI

struct AgentCardView: View {
    let agent: Agent
    var width: CGFloat = 200
    var height: CGFloat = 250

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: agent.avatarURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 100)
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

        }
        .padding()
        .frame(width: width, height: height, alignment: .topLeading)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
