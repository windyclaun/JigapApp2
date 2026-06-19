//
//  ProfileView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var store: FinancialStore = FinancialStore()
    private let accentColor = Color(red: 1.0, green: 0.18, blue: 0.48)
    
    var body: some View {
        ZStack {
            ProfileBackground()
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCard(
                        name: "Guest",
                        subtitle: "Kantong user",
                        walletCount: store.daftarKantong.count,
                        accentColor: accentColor
                    )
                    .padding(.top, 70)
                    
                    ProfileSection(title: "Preferences") {
                        ProfileMenuRow(iconName: "bell", title: "Notifications", subtitle: "Daily reminders & alerts", tint: accentColor)
                        ProfileDivider()
                        ProfileMenuRow(iconName: "moon", title: "Appearance", subtitle: "Dark mode", tint: accentColor)
                    }
                    
                    ProfileSection(title: "Account") {
                        ProfileMenuRow(iconName: "shield", title: "Privacy & Security", subtitle: "Password, biometrics", tint: accentColor)
                        ProfileDivider()
                        ProfileMenuRow(iconName: "wallet.pass", title: "Linked Wallets", subtitle: "Manage your kantongs", tint: accentColor)
                    }
                    
                    ProfileSection(title: "Support") {
                        ProfileMenuRow(iconName: "star", title: "Rate Kantong", subtitle: "Love the app? Tell us!", tint: accentColor)
                        ProfileDivider()
                        ProfileMenuRow(iconName: "questionmark.circle", title: "Help & FAQ", subtitle: "Get support", tint: accentColor)
                    }
                    
                    SignOutButton(tint: accentColor)
                    
                    Text("Kantong v1.0.0")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.18))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 108)
                }
                .padding(.horizontal, 22)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
}
