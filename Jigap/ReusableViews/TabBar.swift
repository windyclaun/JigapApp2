//
//  TabBar.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct TabBar: View {
    // Mengikat state tab aktif dan trigger modal dari ContentView
    @Binding var selectedTab: Int
    @Binding var isShowingAddMenu: Bool
    
    // Menerima data store agar bisa dilempar ke halaman Dashboard & History
    @ObservedObject var store: FinancialStore
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                // TAB 1: DASHBOARD
                DashboardView(store: store) {
                    selectedTab = 2
                }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0) // Menandai index tab
                
                // TAB 2: TOMBOL ADD TRANSACTION (Trik intercept ketukan tab native)
                Color.clear
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(1)
                
                // TAB 3: HISTORY
                HistoryView(store: store)
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
                    .tag(2)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        .tint(Color(red: 1.0, green: 0.2, blue: 0.5))
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 {
                isShowingAddMenu = true
                selectedTab = oldValue
            }
        }
    }
}

#Preview {
    TabBar(selectedTab: .constant(0), isShowingAddMenu: .constant(false), store: FinancialStore())
        .preferredColorScheme(.dark)
}
