//
//  HistoryView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: FinancialStore = FinancialStore()
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedWalletId: UUID?
    
    private let accentColor = Color(red: 1.0, green: 0.18, blue: 0.48)
    private let incomeColor = Color(red: 0.18, green: 0.95, blue: 0.46)
    
    private var filteredTransactions: [Transaction] {
        store.daftarTransaksi.filter { transaction in
            let matchesSearch = searchText.isEmpty
                || transaction.title.localizedCaseInsensitiveContains(searchText)
                || transaction.category.localizedCaseInsensitiveContains(searchText)
                || store.getKantongName(for: transaction.sourceKantongId).localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || transaction.category == selectedCategory
            let matchesWallet = selectedWalletId == nil || transaction.sourceKantongId == selectedWalletId
            return matchesSearch && matchesCategory && matchesWallet
        }
        .sorted { $0.date > $1.date }
    }
    
    private var categories: [String] {
        ["All"] + Array(Set(store.daftarTransaksi.map(\.category))).sorted()
    }
    
    private var totalExpense: Double {
        store.daftarTransaksi.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        store.daftarTransaksi.filter(\.isIncome).reduce(0) { $0 + $1.amount }
    }
    
    private var netTotal: Double {
        totalIncome - totalExpense
    }
    
    private var groupedTransactions: [HistoryDaySection] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filteredTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return groups
            .map { date, transactions in
                HistoryDaySection(
                    title: sectionTitle(for: date),
                    date: date,
                    transactions: transactions.sorted { $0.date > $1.date }
                )
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                HistoryBackground()
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        HistorySearchBar(searchText: $searchText, tint: accentColor)
                        summaryCards
                        categoryFilter
                        walletFilter
                        transactionSections
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 42)
                    .padding(.bottom, 118)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Transaction History")
                .font(.system(.title, design: .rounded))
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            
            Text("\(store.daftarTransaksi.count) total transactions")
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(Color(red: 1.0, green: 0.52, blue: 0.72).opacity(0.72))
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: 12) {
            HistorySummaryCard(
                title: "Expenses",
                amount: totalExpense,
                prefix: "-Rp",
                tint: accentColor
            )
            
            HistorySummaryCard(
                title: "Income",
                amount: totalIncome,
                prefix: "+Rp",
                tint: incomeColor
            )
            
            HistorySummaryCard(
                title: "Net",
                amount: abs(netTotal),
                prefix: netTotal >= 0 ? "+Rp" : "-Rp",
                tint: netTotal >= 0 ? incomeColor : accentColor
            )
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    HistoryFilterChip(
                        title: category,
                        iconName: category == "All" ? nil : iconName(for: category),
                        isSelected: selectedCategory == category,
                        tint: accentColor
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private var walletFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                HistoryFilterChip(
                    title: "All Wallets",
                    iconName: nil,
                    isSelected: selectedWalletId == nil,
                    tint: accentColor
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        selectedWalletId = nil
                    }
                }
                
                ForEach(store.daftarKantong) { kantong in
                    HistoryFilterChip(
                        title: kantong.name,
                        iconName: kantong.iconName,
                        isSelected: selectedWalletId == kantong.id,
                        tint: kantong.themeColor
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            selectedWalletId = kantong.id
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private var transactionSections: some View {
        VStack(alignment: .leading, spacing: 18) {
            if groupedTransactions.isEmpty {
                EmptyHistoryState(tint: accentColor)
            } else {
                ForEach(groupedTransactions) { section in
                    HistorySectionView(
                        section: section,
                        store: store,
                        accentColor: accentColor,
                        iconName: iconName(for:),
                        noteText: noteText(for:),
                        formatCurrency: formatCurrency
                    )
                }
            }
        }
    }
    
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            let shortValue = value / 1_000_000
            return shortValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f.000.000", shortValue) : String(format: "%.1fM", shortValue)
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "coffee": return "cup.and.saucer.fill"
        case "food": return "fork.knife"
        case "groceries": return "cart.fill"
        case "salary": return "dollarsign.circle.fill"
        case "transport": return "scooter"
        case "shopping": return "bag.fill"
        case "subscription": return "play.rectangle.fill"
        default: return "creditcard.fill"
        }
    }
    
    private func noteText(for transaction: Transaction) -> String {
        switch transaction.category.lowercased() {
        case "coffee": return "Iced brown sugar"
        case "food": return "Nasi goreng spesial"
        case "groceries": return "Daily essentials"
        case "transport": return "Online ride"
        case "salary": return "Monthly income"
        default: return transaction.isIncome ? "Income received" : "Transaction detail"
        }
    }
}

private struct HistoryBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.0, blue: 0.06)
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.02, blue: 0.17).opacity(0.98),
                    Color(red: 0.08, green: 0.0, blue: 0.08).opacity(0.98),
                    Color(red: 0.02, green: 0.0, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.16, blue: 0.48).opacity(0.20), .clear],
                center: .topTrailing,
                startRadius: 10,
                endRadius: 260
            )
            RadialGradient(
                colors: [Color.purple.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 24,
                endRadius: 240
            )
        }
    }
}

private struct HistorySearchBar: View {
    @Binding var searchText: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(0.48))
            
            TextField("Search transactions...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .tint(tint)
                .textInputAutocapitalization(.never)
            
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.45), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 17)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
        .historyLiquidGlass(tint: .white.opacity(0.10), cornerRadius: 17, interactive: true)
    }
}

private struct HistorySummaryCard: View {
    let title: String
    let amount: Double
    let prefix: String
    let tint: Color
    
    var body: some View {
        VStack(spacing: 7) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.56))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            Text(prefix)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(tint)
            
            Text(formatAmount(amount))
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.heavy)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 78)
        .background(
            LinearGradient(
                colors: [Color(red: 0.29, green: 0.10, blue: 0.27).opacity(0.96), Color(red: 0.21, green: 0.08, blue: 0.24).opacity(0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.13), lineWidth: 1)
        )
        .historyLiquidGlass(tint: tint.opacity(0.18), cornerRadius: 20, interactive: false)
    }
    
    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

private struct HistoryFilterChip: View {
    let title: String
    let iconName: String?
    let isSelected: Bool
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.54))
            .padding(.horizontal, isSelected ? 17 : 14)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(isSelected ? tint : Color.white.opacity(0.08))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? tint.opacity(0.45) : .white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .historyLiquidGlass(tint: isSelected ? tint.opacity(0.42) : .white.opacity(0.08), cornerRadius: 18, interactive: true)
    }
}

private struct HistorySectionView: View {
    let section: HistoryDaySection
    @ObservedObject var store: FinancialStore
    let accentColor: Color
    let iconName: (String) -> String
    let noteText: (Transaction) -> String
    let formatCurrency: (Double) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(section.title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(red: 1.0, green: 0.42, blue: 0.68))
                Rectangle()
                    .fill(.white.opacity(0.07))
                    .frame(height: 1)
            }
            
            VStack(spacing: 0) {
                ForEach(section.transactions) { transaction in
                    HistoryTransactionRow(
                        transaction: transaction,
                        walletName: store.getKantongName(for: transaction.sourceKantongId),
                        accentColor: accentColor,
                        iconName: iconName(transaction.category),
                        note: noteText(transaction),
                        amountText: formatCurrency(transaction.amount)
                    )
                    
                    if transaction.id != section.transactions.last?.id {
                        Divider()
                            .background(.white.opacity(0.06))
                            .padding(.leading, 66)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.29, green: 0.10, blue: 0.22).opacity(0.94), Color(red: 0.22, green: 0.07, blue: 0.18).opacity(0.96)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
            .historyLiquidGlass(tint: accentColor.opacity(0.12), cornerRadius: 22, interactive: false)
        }
    }
}

private struct HistoryTransactionRow: View {
    let transaction: Transaction
    let walletName: String
    let accentColor: Color
    let iconName: String
    let note: String
    let amountText: String
    
    private var amountColor: Color {
        transaction.isIncome ? Color(red: 0.18, green: 0.95, blue: 0.46) : Color(red: 1.0, green: 0.42, blue: 0.66)
    }
    
    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(red: 1.0, green: 0.48, blue: 0.72))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 7) {
                    Text(walletName)
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(accentColor.opacity(0.18), in: Capsule())
                    
                    Text(transaction.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                }
                
                Text(note)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.38))
                    .lineLimit(1)
            }
            
            Spacer(minLength: 10)
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("\(transaction.isIncome ? "+Rp " : "-Rp ")\(amountText)")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(amountColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                
                Image(systemName: transaction.isIncome ? "arrow.down.left" : "arrow.up.right")
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .foregroundStyle(amountColor.opacity(0.72))
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 12)
    }
}

private struct EmptyHistoryState: View {
    let tint: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(tint)
            Text("No transactions found")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
            Text("Try another search or filter.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.48))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .historyLiquidGlass(tint: tint.opacity(0.14), cornerRadius: 22, interactive: false)
    }
}

private struct HistoryDaySection: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let transactions: [Transaction]
}

private extension View {
    @ViewBuilder
    func historyLiquidGlass(tint: Color = .white.opacity(0.12), cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
        }
    }
}

#Preview {
    HistoryView(store: FinancialStore())
        .preferredColorScheme(.dark)
}
