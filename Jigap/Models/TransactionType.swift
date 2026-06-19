//
//  TransactionType.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

enum TransactionType: String, CaseIterable, Identifiable {
    case expense
    case income
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
    
    var symbolName: String {
        switch self {
        case .expense: return "arrow.up.right.circle.fill"
        case .income: return "arrow.down.left.circle.fill"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .expense: return Color(red: 1.0, green: 0.18, blue: 0.48) // Pink/Neon Red cerah
        case .income: return Color(red: 0.0, green: 0.82, blue: 0.62) // Mint Green cerah
        }
    }
}
