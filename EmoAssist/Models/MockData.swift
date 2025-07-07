import Foundation

let mockAgents: [Agent] = [
    Agent(
        id: UUID(),
        name: "Sara",
        category: .therapist,
        specialty: "Empathetic listener",
        description: "A kind-hearted therapist ready to help you feel better.",
        avatarURL: "https://images.unsplash.com/photo-...",
        backgroundGradient: "linear-gradient(135deg, #66eeaa 0%, #764bba2 100%)",
        isFeatured: true,
        callCount: 12,
        rating: 4.8
    ),
    Agent(
        id: UUID(),
        name: "SRK",
        category: .celebrity,
        specialty: "Bollywood-style inspiration",
        description: "Romantic, poetic, and philosophical — just like Shah Rukh Khan.",
        avatarURL: "https://images.unsplash.com/photo-...",
        backgroundGradient: "linear-gradient(135deg, #ff8c8c 0%, #ffcc70 100%)",
        isFeatured: false,
        callCount: 20,
        rating: 4.6
    ),
    Agent(
        id: UUID(),
        name: "Dr. Jones",
        category: .therapist,
        specialty: "Cognitive therapy",
        description: "Practical advice and mindful exercises to help you grow.",
        avatarURL: "https://images.unsplash.com/photo-...",
        backgroundGradient: "linear-gradient(135deg, #66eeaa 0%, #764bba 100%)",
        isFeatured: false,
        callCount: 5,
        rating: 4.7
    )
]
