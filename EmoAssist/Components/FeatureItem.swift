import SwiftUI

struct FeatureItem: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(LinearGradient(colors: [.purple, .blue],
                                   startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }
}
