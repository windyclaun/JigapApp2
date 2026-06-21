//
//  ContentView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 12/06/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = FinancialStore()
    @State private var selectedTab = 0
    @State private var isShowingAddMenu = false
    
    // MARK: - Kunci Monitor Status Login
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("appAppearanceMode") private var appAppearanceMode: String = "System"
    
    private var preferredColorScheme: ColorScheme? {
        switch appAppearanceMode {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil
        }
    }
    
    private var isAuthenticated: Bool {
        isLoggedIn && !store.currentUserEmailPublic.isEmpty
    }
    
    var body: some View {
        Group {
            if isAuthenticated {
                // Skenario 1: Jika sudah login, tampilkan Dashboard Utama
                TabBar(
                    selectedTab: $selectedTab,
                    isShowingAddMenu: $isShowingAddMenu,
                    store: store
                )
                // Suntikkan environmentObject agar seluruh child view di dalam TabBar bisa mengakses store
                .environmentObject(store)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                OnBoardingView()
                    .environmentObject(store)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear(perform: validateSession)
        .onChange(of: isLoggedIn) { _, _ in
            validateSession()
        }
    }
    
    private func validateSession() {
        if isLoggedIn && store.currentUserEmailPublic.isEmpty {
            isLoggedIn = false
        }
    }
}

#Preview {
    ContentView()
}
