//
//  CategorySectionView.swift
//  EmoAssist
//
//  Created by Aditi More on 7/6/25.
//


import SwiftUI

struct CategorySectionView: View {
    var title: String
    var agents: [Agent]
    var icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(agents) { agent in
                        AgentCardView(agent: agent)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}
