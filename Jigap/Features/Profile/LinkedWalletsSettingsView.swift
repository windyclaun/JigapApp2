//
//  LinkedWalletsSettingsView.swift
//  Jigap
//

import SwiftUI

struct LinkedWalletsSettingsView: View {
    let kantongs: [Kantong]
    @Binding var dailySpendingCap: Double
    @Binding var monthlyIncome: Double
    let accentColor: Color
    
    @State private var dailyCapText = ""
    @State private var monthlyIncomeText = ""
    
    var body: some View {
        ProfileDetailContainer(title: "Linked Wallets") {
            VStack(alignment: .leading, spacing: 18) {
                incomeSection
                walletListSection
            }
            .onAppear(perform: syncIncomeTexts)
        }
    }
    
    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Income Settings")
                .profileDetailTitle()
            
            IncomeInputField(
                title: "Daily Max Income",
                placeholder: "Daily max income",
                text: $dailyCapText,
                accentColor: accentColor,
                onChange: updateDailyCap
            )
            
            IncomeInputField(
                title: "Monthly Income",
                placeholder: "Monthly income",
                text: $monthlyIncomeText,
                accentColor: accentColor,
                onChange: updateMonthlyIncome
            )
            
            Text("Daily max: \(CurrencyFormatter.rupiah(dailySpendingCap))")
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.78))
            
            Text("Monthly income: \(CurrencyFormatter.rupiah(monthlyIncome))")
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.78))
        }
    }
    
    private var walletListSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Manage Your Kantong")
                .profileDetailTitle()
                .padding(.top, 8)
            
            if kantongs.isEmpty {
                Text("No kantong linked yet.")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.62))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                ForEach(kantongs) { kantong in
                    LinkedWalletRow(kantong: kantong)
                }
            }
        }
    }
    
    private func syncIncomeTexts() {
        dailyCapText = dailySpendingCap == 0 ? "" : String(Int(dailySpendingCap))
        monthlyIncomeText = monthlyIncome == 0 ? "" : String(Int(monthlyIncome))
    }
    
    private func updateDailyCap() {
        guard let value = Double(dailyCapText) else { return }
        dailySpendingCap = value
    }
    
    private func updateMonthlyIncome() {
        guard let value = Double(monthlyIncomeText) else { return }
        monthlyIncome = value
    }
}

private struct IncomeInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let accentColor: Color
    let onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.62))
            
            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .tint(accentColor)
                .padding(16)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onSubmit(onChange)
                .onChange(of: text) { _, _ in onChange() }
        }
    }
}

private struct LinkedWalletRow: View {
    let kantong: Kantong
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: kantong.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(kantong.themeColor)
                .frame(width: 42, height: 42)
                .background(kantong.themeColor.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(kantong.name)
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                Text("Balance: \(CurrencyFormatter.rupiah(kantong.balance))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.62))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

enum CurrencyFormatter {
    static func rupiah(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
}
