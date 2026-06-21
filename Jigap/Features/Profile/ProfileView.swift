//
//  ProfileView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: FinancialStore
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("appAppearanceMode") private var appAppearanceMode: String = "System"
    @AppStorage("appHighContrast") private var appHighContrast: Bool = false
    
    private let accentColor = ProfileStyle.accentColor
    
    private var displayName: String {
        store.allUsers[store.currentUserEmailPublic]?.name ?? "Guest"
    }
    
    private var displayEmail: String {
        store.currentUserEmailPublic == "guest" ? "guest@jigap.local" : store.currentUserEmailPublic
    }
    
    private var isGuestAccount: Bool {
        store.currentUserEmailPublic == "guest"
    }
    
    private var dailySpendingCap: Binding<Double> {
        Binding(
            get: { store.dailySpendingCap },
            set: { store.dailySpendingCap = $0 }
        )
    }
    
    private var monthlyIncome: Binding<Double> {
        Binding(
            get: { store.monthlyIncome },
            set: { store.monthlyIncome = $0 }
        )
    }
    
    var body: some View {
        ZStack {
            ProfileBackground(highContrast: appHighContrast)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderCard(
                        name: displayName,
                        subtitle: displayEmail,
                        walletCount: store.daftarKantong.count,
                        accentColor: accentColor
                    )
                    .padding(.top, 24)
                    
                    ProfileSection(title: "Profile") {
                        ProfileNavigationRow(
                            iconName: "paintbrush",
                            title: "Appearance",
                            subtitle: "Theme and contrast",
                            tint: accentColor
                        ) {
                            AppearanceSettingsView(
                                appearanceMode: $appAppearanceMode,
                                isHighContrastEnabled: $appHighContrast,
                                accentColor: accentColor
                            )
                        }
                        
                        ProfileDivider()
                        
                        ProfileNavigationRow(
                            iconName: "shield",
                            title: "Privacy & Security",
                            subtitle: "Password and account removal",
                            tint: accentColor
                        ) {
                            PrivacySecurityView(
                                isGuestAccount: isGuestAccount,
                                isLoggedIn: $isLoggedIn,
                                accentColor: accentColor,
                                updatePassword: updatePassword,
                                deleteAccount: deleteCurrentAccount
                            )
                        }
                        
                        ProfileDivider()
                        
                        ProfileNavigationRow(
                            iconName: "wallet.pass",
                            title: "Linked Wallets",
                            subtitle: "Manage kantong and daily cap",
                            tint: accentColor
                        ) {
                            LinkedWalletsSettingsView(
                                kantongs: store.daftarKantong,
                                dailySpendingCap: dailySpendingCap,
                                monthlyIncome: monthlyIncome,
                                accentColor: accentColor
                            )
                        }
                    }
                    
                    Text("Jigap v1.0.0")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(appHighContrast ? 0.45 : 0.22))
                        .frame(maxWidth: .infinity)
                    
                    SignOutButton(tint: accentColor, action: signOut)
                        .padding(.bottom, 108)
                }
                .padding(.horizontal, 22)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
    
    private func updatePassword(_ password: String) {
        store.updateCurrentUserPassword(to: password)
    }
    
    private func deleteCurrentAccount() {
        store.deleteCurrentAccount()
        isLoggedIn = false
    }
    
    private func signOut() {
        store.signOut()
        isLoggedIn = false
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(FinancialStore())
    }
}
