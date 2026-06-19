//
//  DashboardViewModel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

//
//  DashboardViewModel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var store: FinancialStore
    
    let accentColor = Color(red: 1.0, green: 0.18, blue: 0.48)
    let cyanColor = Color(red: 0.18, green: 0.92, blue: 0.88)
    let darkBackground = Color(red: 0.045, green: 0.005, blue: 0.055)
    
    init(store: FinancialStore = FinancialStore()) {
        self.store = store
    }
    
    // MARK: - Perhitungan (Calculated Properties)
    
    var dailyProgress: CGFloat {
        guard store.dailySpendingCap > 0 else { return 0 }
        return min(CGFloat(store.totalExpenseToday / store.dailySpendingCap), 1)
    }
    
    var weeklyTotal: Double {
        store.daftarTransaksi
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    var weeklyBars: [WeeklyBar] {
        [
            WeeklyBar(label: "Sen", height: 54, isToday: false),
            WeeklyBar(label: "Sel", height: 38, isToday: false),
            WeeklyBar(label: "Rab", height: 74, isToday: false),
            WeeklyBar(label: "Kam", height: 43, isToday: false),
            WeeklyBar(label: "Jum", height: 90, isToday: true),
            WeeklyBar(label: "Sab", height: 64, isToday: false),
            WeeklyBar(label: "Min", height: 35, isToday: false)
        ]
    }
    
    var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    
    // MARK: - Formatting Helpers (Backend Formatting)
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
    
    func formatShortCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "Rp %.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "Rp %.0fK", value / 1_000)
        } else {
            return String(format: "Rp %.0f", value)
        }
    }
    
    func formatShortBalance(_ value: Double) -> String {
        if value >= 1_000_000 {
            let shortValue = value / 1_000_000
            return shortValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "Rp %.0fM", shortValue) : String(format: "Rp %.1fM", shortValue)
        } else if value >= 1_000 {
            return String(format: "Rp %.0fK", value / 1_000)
        } else {
            return String(format: "Rp %.0f", value)
        }
    }
    
    func formatTransactionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "coffee": return "cup.and.saucer.fill"
        case "food": return "fork.knife"
        case "groceries": return "cart.fill"
        case "salary": return "banknote.fill"
        case "transport": return "car.fill"
        default: return "creditcard.fill"
        }
    }
}

// Model internal untuk chart mingguan tetap berada di sisi logic
struct WeeklyBar: Identifiable {
    let id = UUID()
    let label: String
    let height: CGFloat
    let isToday: Bool
}
