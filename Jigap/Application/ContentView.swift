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
    // AppStorage akan membaca data yang sama dengan yang diubah di OnBoardingView
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                // Skenario 1: Jika sudah login, tampilkan Dashboard Utama
                TabBar(
                    selectedTab: $selectedTab,
                    isShowingAddMenu: $isShowingAddMenu,
                    store: store
                )
                .sheet(isPresented: $isShowingAddMenu) {
                    AddWalletView(store: store)
                }
                // Suntikkan environmentObject agar seluruh child view di dalam TabBar bisa mengakses store
                .environmentObject(store)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                // Skenario 2: Jika belum login, tahan user di halaman Onboarding (Sign In / Sign Up)
                OnBoardingView()
                    .environmentObject(store)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
