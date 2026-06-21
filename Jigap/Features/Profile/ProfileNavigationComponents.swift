//
//  ProfileNavigationComponents.swift
//  Jigap
//

import SwiftUI

struct ProfileDetailContainer<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            ProfileBackground(highContrast: false)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                content
                    .padding(22)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

struct ProfileNavigationRow<Destination: View>: View {
    let iconName: String
    let title: String
    let subtitle: String
    let tint: Color
    @ViewBuilder let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
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
                        .foregroundStyle(.white.opacity(0.60))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer(minLength: 10)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .profileLiquidGlass(tint: tint.opacity(0.08), cornerRadius: 16, interactive: true)
    }
}

extension View {
    func profileDetailTitle() -> some View {
        self
            .font(.caption)
            .fontWeight(.heavy)
            .textCase(.uppercase)
            .foregroundStyle(Color(red: 1.0, green: 0.58, blue: 0.72).opacity(0.86))
            .tracking(1.0)
    }
}
