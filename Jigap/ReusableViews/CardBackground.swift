//
//  CardBackground.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct CardBackground: View {
    let cornerRadius: CGFloat
    private let cardColor = Color(red: 0.22, green: 0.08, blue: 0.19)
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [cardColor.opacity(0.98), Color(red: 0.28, green: 0.10, blue: 0.25).opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 12)
    }
}

#Preview {
    CardBackground(cornerRadius: 16)
}
