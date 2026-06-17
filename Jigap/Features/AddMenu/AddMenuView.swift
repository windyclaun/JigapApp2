//
//  AddMenuView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct AddMenuView: View {
    @ObservedObject var store: FinancialStore
    
    var body: some View {
        AddTransactionView(store: store)
    }
}

#Preview {
    AddMenuView(store: FinancialStore())
        .preferredColorScheme(.dark)
}
