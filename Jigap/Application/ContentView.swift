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
    
    var body: some View {
        // Panggil Reusable View Tab Bar buatan kita
        TabBar(
            selectedTab: $selectedTab,
            isShowingAddMenu: $isShowingAddMenu,
            store: store
        )
        // Lembar input transaksi yang ditaruh terpusat pada tingkat root layar
        .sheet(isPresented: $isShowingAddMenu) {
            AddMenuView(store: store)
        }
    }
}

#Preview {
    ContentView()
}
