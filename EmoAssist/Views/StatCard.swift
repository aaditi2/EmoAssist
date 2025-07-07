import SwiftUI

struct StatCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(width: 115, height: 80)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
