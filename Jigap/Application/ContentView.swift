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
        TabBar(
            selectedTab: $selectedTab,
            isShowingAddMenu: $isShowingAddMenu,
            store: store
        )
        .sheet(isPresented: $isShowingAddMenu) {
            AddWalletView(store: store)
        }
    }
}

#Preview {
    ContentView()
}
