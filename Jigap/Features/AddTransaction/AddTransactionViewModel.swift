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
    @Published var isShowingCategoryForm = false
    @Published var newCategoryName = ""
    @Published var newCategorySymbolName = "tag.fill"
    
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
        if transactionType == .expense {
            return TransactionCategory.expenseDefaults + store.customExpenseCategories
        } else {
            return TransactionCategory.incomeDefaults + store.customIncomeCategories
        }
    }
    
    // MARK: - Actions
    
    func configureInitialSelection() {
        if let firstKantong = store.daftarKantong.first, !store.daftarKantong.contains(where: { $0.id == selectedKantongId }) {
            selectedKantongId = firstKantong.id
        }
    }
    
    func handleTypeChange(to newType: TransactionType) {
        selectedCategory = availableCategories[0]
        newCategorySymbolName = newType == .expense ? "tag.fill" : "banknote.fill"
    }
    
    func addCustomCategory() {
        store.addCustomCategory(
            name: newCategoryName,
            symbolName: newCategorySymbolName,
            isIncome: transactionType == .income
        )
        
        if let createdCategory = availableCategories.first(where: { $0.name.caseInsensitiveCompare(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame }) {
            selectedCategory = createdCategory
        }
        
        newCategoryName = ""
        isShowingCategoryForm = false
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
