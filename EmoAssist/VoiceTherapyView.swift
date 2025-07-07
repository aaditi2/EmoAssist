import SwiftUI

struct VoiceTherapyView: View {
    @State private var isListening = false

    var body: some View {
        VStack(spacing: 24) {
            Text("🎙️ Talk to your AI Therapist")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)

            Spacer()

            // Call a Friend Button
            NavigationLink(destination: HomeView()) {
                Label("🧠 Call a Friend", systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(12)
            }

        }
        .padding()
        .navigationTitle("Emo Assistant")
    }
}
