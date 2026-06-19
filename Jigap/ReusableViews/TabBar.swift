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
                // TAB 1: DASHBOARD (Ikon House)
                DashboardView(store: store) {
                    selectedTab = 2 // Alihkan ke History jika memicu "See All"
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                
                // TAB 2: INTERCEPT UNTUK ADD TRANSACTION (Ikon Plus)
                Color.clear
                    .tabItem {
                        Label("Add", systemImage: "plus")
                    }
                    .tag(1)
                
                // TAB 3: HISTORY (Ikon Clock)
                HistoryView(store: store)
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                    .tag(2)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        .tint(Color(red: 1.0, green: 0.18, blue: 0.48)) // Disamakan dengan warna accent pink utama
        .onChange(of: selectedTab) { oldValue, newValue in
            // Jika user mengetan ikon plus (tab 1), intercept dan munculkan modal sheet
            if newValue == 1 {
                isShowingAddMenu = true
                selectedTab = oldValue // Kembalikan sorotan tab aktif ke halaman sebelumnya
            }
        }
        // Di sinilah tempat modular terbaik untuk menembakkan modal AddTransactionView
        .sheet(isPresented: $isShowingAddMenu) {
            AddTransactionView(store: store)
        }
    }
}

#Preview {
    TabBar(selectedTab: .constant(0), isShowingAddMenu: .constant(false), store: FinancialStore())
        .preferredColorScheme(.dark)
}
