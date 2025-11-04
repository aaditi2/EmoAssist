import SwiftUI

struct VoiceTherapyView: View {
    @StateObject private var viewModel = VoiceTherapyViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                statusCard
                liveTranscriptCard
                conversationTimeline
                Spacer()
                microphoneButton
            }
            .padding()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("EmoAssist")
        }
        .task {
            await viewModel.prepareSession()
        }
        .alert(item: $viewModel.activeError) { alert in
            Alert(
                title: Text("Something went wrong"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    viewModel.reset()
                }
            )
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(viewModel.sessionState.statusText)
                .font(.title2.weight(.semibold))
            if let emotion = viewModel.detectedEmotion, !emotion.isEmpty {
                Label {
                    Text(emotion.capitalized)
                        .font(.headline)
                } icon: {
                    Image(systemName: "heart.text.square")
                        .foregroundStyle(.pink)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.pink.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No emotion detected yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var liveTranscriptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Transcript")
                .font(.caption)
                .foregroundStyle(.secondary)
            if viewModel.transcript.isEmpty {
                Text("Tap the microphone and start talking whenever you're ready.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                Text(viewModel.transcript)
                    .font(.body.monospaced())
                    .foregroundStyle(.primary)
                    .transition(.opacity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var conversationTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Therapy Timeline")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.conversation.isEmpty {
                Text("Your private, on-device transcript stays here and clears automatically after every response.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.conversation) { turn in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("You")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(turn.userUtterance)
                                    .font(.body)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Text("EmoAssist")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(turn.therapistResponse)
                                    .font(.body)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .frame(maxHeight: 220)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var microphoneButton: some View {
        Button(action: viewModel.toggleMicrophone) {
            VStack(spacing: 8) {
                Image(systemName: viewModel.sessionState == .listening ? "stop.circle.fill" : "waveform.circle.fill")
                    .font(.system(size: 64))
                    .symbolRenderingMode(.hierarchical)
                Text(buttonLabel)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(buttonGradient)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
        }
        .disabled(viewModel.sessionState == .thinking)
        .opacity(viewModel.sessionState == .thinking ? 0.6 : 1)
    }

    private var buttonLabel: String {
        switch viewModel.sessionState {
        case .idle, .error:
            return "Start Talking"
        case .listening:
            return "Finish Thought"
        case .thinking:
            return "Analyzing…"
        case .speaking:
            return "Stop Voice"
        }
    }

    private var buttonGradient: LinearGradient {
        switch viewModel.sessionState {
        case .idle, .error:
            return LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
        case .listening:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case .thinking:
            return LinearGradient(colors: [.gray, .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        case .speaking:
            return LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
        }
    }
}

#Preview {
    VoiceTherapyView()
}
