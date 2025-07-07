//
//  StatCard.swift
//  EmoAssist
//
//  Created by Aditi More on 7/6/25.
//
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
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}
