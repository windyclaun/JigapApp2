//
//  AddTransactionViewModel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI
import Combine

class AddTransactionViewModel: ObservableObject {
    @Published var store: FinancialStore
    
    // State data transaksi
    @Published var transactionType: TransactionType = .expense
    @Published var amountString = ""
    @Published var selectedCategory: TransactionCategory
    @Published var selectedKantongId = UUID()
    @Published var transactionDate = Date()
    @Published var note = ""
    
    init(store: FinancialStore) {
        self.store = store
        self.selectedCategory = TransactionCategory.expenseDefaults[0]
    }
    
    // MARK: - Calculated Properties (Logic)
    
    var canSave: Bool {
        Double(amountString) != nil && !amountString.isEmpty
    }
    
    var selectedKantong: Kantong? {
        store.daftarKantong.first { $0.id == selectedKantongId }
    }
    
    var availableCategories: [TransactionCategory] {
        transactionType == .expense ? TransactionCategory.expenseDefaults : TransactionCategory.incomeDefaults
    }
    
    // MARK: - Actions
    
    func configureInitialSelection() {
        if let firstKantong = store.daftarKantong.first, !store.daftarKantong.contains(where: { $0.id == selectedKantongId }) {
            selectedKantongId = firstKantong.id
        }
    }
    
    func handleTypeChange(to newType: TransactionType) {
        selectedCategory = newType == .expense ? TransactionCategory.expenseDefaults[0] : TransactionCategory.incomeDefaults[0]
    }
    
    func saveTransaction(completion: () -> Void) {
        guard let amount = Double(amountString), canSave else { return }
        let title = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? selectedCategory.name : note
        
        store.addTransaction(
            title: title,
            amount: amount,
            category: selectedCategory.name,
            isIncome: transactionType == .income,
            kantongId: selectedKantongId
        )
        
        completion()
    }
}
