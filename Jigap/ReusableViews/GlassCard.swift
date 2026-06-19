//
//  GlassCard.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content
    
    init(cornerRadius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.08, blue: 0.19).opacity(0.98),
                                Color(red: 0.28, green: 0.10, blue: 0.25).opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.14), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 18, x: 0, y: 12)
    }
}
//
//#Preview {
//    GlassCard()
//}
