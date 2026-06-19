//
//  ProfileComponents.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

// MARK: - Background
struct ProfileBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.0, blue: 0.055)
            LinearGradient(
                colors: [
                    Color(red: 0.23, green: 0.02, blue: 0.19).opacity(0.95),
                    Color(red: 0.07, green: 0.0, blue: 0.08).opacity(0.98),
                    Color(red: 0.02, green: 0.0, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.16, blue: 0.48).opacity(0.20), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color.purple.opacity(0.16), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 250
            )
        }
    }
}

// MARK: - Header Card (Dioptimasi untuk inisial nama dinamis)
struct ProfileHeaderCard: View {
    let name: String
    let subtitle: String
    let walletCount: Int
    let accentColor: Color
    
    // Mengambil huruf pertama dari nama untuk avatar profile secara dinamis
    private var nameInitial: String {
        guard let firstChar = name.trimmingCharacters(in: .whitespacesAndNewlines).first else { return "G" }
        return String(firstChar).uppercased()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 70, height: 70)
                    .shadow(color: accentColor.opacity(0.45), radius: 18, x: 0, y: 8)
                Text(nameInitial) // Menampilkan inisial huruf dinamis
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            .offset(y: 12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                Text("\(subtitle) • \(walletCount) wallets")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.50))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.38, green: 0.13, blue: 0.34).opacity(0.94), Color(red: 0.24, green: 0.08, blue: 0.24).opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1.2)
        )
        .profileLiquidGlass(tint: accentColor.opacity(0.16), cornerRadius: 22, interactive: false)
    }
}

// MARK: - Section Container
struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(Color(red: 1.0, green: 0.58, blue: 0.72).opacity(0.70))
                .tracking(0.8)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.29, green: 0.10, blue: 0.26).opacity(0.94), Color(red: 0.23, green: 0.08, blue: 0.22).opacity(0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.13), lineWidth: 1)
            )
            .profileLiquidGlass(tint: .white.opacity(0.10), cornerRadius: 22, interactive: false)
        }
    }
}

// MARK: - Menu Row
struct ProfileMenuRow: View {
    let iconName: String
    let title: String
    let subtitle: String
    let tint: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.66))
                    .frame(width: 43, height: 43)
                    .background(tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer(minLength: 10)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.28))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .profileLiquidGlass(tint: tint.opacity(0.08), cornerRadius: 16, interactive: true)
    }
}

// MARK: - Divider
struct ProfileDivider: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.06))
            .frame(height: 1)
            .padding(.leading, 75)
    }
}

// MARK: - Sign Out Button (Ditambahkan parameter action closure)
struct SignOutButton: View {
    let tint: Color
    var action: () -> Void = {} // Callback untuk menerima aksi dari luar view
    
    var body: some View {
        Button(action: action) {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.heavy)
                .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.66))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(Color(red: 0.30, green: 0.02, blue: 0.12).opacity(0.42), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(tint.opacity(0.32), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .profileLiquidGlass(tint: tint.opacity(0.10), cornerRadius: 18, interactive: true)
    }
}

// MARK: - Glass Effects Modifier
extension View {
    @ViewBuilder
    func profileLiquidGlass(tint: Color = .white.opacity(0.12), cornerRadius: CGFloat, interactive: Bool = false) -> some View {
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
