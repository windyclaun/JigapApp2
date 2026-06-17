//
//  KantongCardView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct KantongCardView: View {
    let kantong: Kantong
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Icon + Persentase Alokasi
            HStack {
                Image(systemName: kantong.iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(kantong.themeColor.opacity(0.3))
                    .clipShape(Circle())
                
                Spacer()
                
                Text("\(kantong.allocationPercentage)%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            
            // Informasi Nama Kantong & Saldo
            VStack(alignment: .leading, spacing: 4) {
                Text(kantong.name)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formatShortCurrency(kantong.balance))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .frame(width: dynamicTypeSize.isAccessibilitySize ? .infinity : 110) // Responsif terhadap ukuran font
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.08, blue: 0.12)) // Dark purple-grey card
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.init(red: 1.0, green: 0.2, blue: 0.5).opacity(0.2), lineWidth: 1) // Glowing neon stroke tipis
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kantong \(kantong.name), alokasi \(kantong.allocationPercentage) persen, saldo \(Int(kantong.balance)) rupiah")
    }
    
    private func formatShortCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "Rp %.1fM", value / 1_000_000)
        } else {
            return String(format: "Rp %.0fk", value / 1_000)
        }
    }
}
