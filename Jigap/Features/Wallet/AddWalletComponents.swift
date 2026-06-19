//
//  AddWalletComponents.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

// MARK: - Dynamic Preview Card
struct WalletPreviewCard: View {
    let selectedIcon: String
    let selectedColor: Color
    let walletName: String
    let initialBalance: String
    let allocationPercentage: Double
    
    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 13) {
                Image(systemName: selectedIcon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(selectedColor)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(walletName.isEmpty ? "Kantong Name" : walletName)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white.opacity(0.52))
                    
                    Text("Rp \(initialBalance.isEmpty ? "0" : initialBalance)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.12))
                            Capsule()
                                .fill(selectedColor)
                                .frame(width: proxy.size.width * CGFloat(allocationPercentage) / 100)
                        }
                    }
                    .frame(height: 5)
                    
                    Text("\(Int(allocationPercentage))% remaining")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.48))
                }
            }
        }
        .frame(width: 160, height: 160)
    }
}

// MARK: - Horizontal Icon Picker
struct IconPickerSection: View {
    let availableIcons: [String]
    @Binding var selectedIcon: String
    let selectedColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Icon")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.52))
            
            HStack(spacing: 12) {
                ForEach(availableIcons, id: \.self) { icon in
                    Button(action: { selectedIcon = icon }) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                            .background(selectedIcon == icon ? selectedColor.opacity(0.24) : .white.opacity(0.06))
                            .foregroundStyle(selectedIcon == icon ? selectedColor : .white.opacity(0.6))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 1.5))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Horizontal Theme Color Picker
struct ColorPickerSection: View {
    let availableColors: [Color]
    @Binding var selectedColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Theme Color")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.52))
            
            HStack(spacing: 14) {
                ForEach(availableColors, id: \.self) { color in
                    Button(action: { selectedColor = color }) {
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: selectedColor == color ? 2 : 0)
                            )
                            .shadow(color: color.opacity(0.4), radius: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
