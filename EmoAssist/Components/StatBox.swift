import SwiftUI

struct StatBox: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
