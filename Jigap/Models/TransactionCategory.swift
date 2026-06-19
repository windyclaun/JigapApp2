//
//  TransactionCategory.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import Foundation

struct TransactionCategory: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var symbolName: String
    
    // Default kategori untuk Pengeluaran (Expense)
    static let expenseDefaults: [TransactionCategory] = [
        TransactionCategory(name: "Food", symbolName: "fork.knife"),
        TransactionCategory(name: "Shopping", symbolName: "bag.fill"),
        TransactionCategory(name: "Transport", symbolName: "car.fill"),
        TransactionCategory(name: "Bills", symbolName: "doc.plaintext.fill"),
        TransactionCategory(name: "Entertainment", symbolName: "popcorn.fill")
    ]
    
    // Default kategori untuk Pemasukan (Income)
    static let incomeDefaults: [TransactionCategory] = [
        TransactionCategory(name: "Salary", symbolName: "dollarsign.circle.fill"),
        TransactionCategory(name: "Investment", symbolName: "chart.line.uptrend.xyaxis"),
        TransactionCategory(name: "Freelance", symbolName: "laptopcomputer"),
        TransactionCategory(name: "Gift", symbolName: "gift.fill")
    ]
}
