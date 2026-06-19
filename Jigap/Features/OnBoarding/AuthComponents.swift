//
//  AuthComponents.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

// MARK: - Enums & Constants
enum AuthMode {
    case login
    case register
}

enum AuthPalette {
    static let accent = Color(red: 1.0, green: 0.11, blue: 0.46)
}

// MARK: - Reusable Modifiers
extension View {
    func authFieldStyle() -> some View {
        self
            .padding(.horizontal, 17)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(AuthPalette.accent.opacity(0.24), lineWidth: 1)
            )
            .authLiquidGlass(tint: .white.opacity(0.10), cornerRadius: 17, interactive: true)
    }
    
    @ViewBuilder
    func authLiquidGlass(tint: Color = .white.opacity(0.12), cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
        }
    }
}
