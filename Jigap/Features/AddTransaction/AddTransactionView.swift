//
//  AddTransactionView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct AddTransactionView: View {
    @StateObject private var viewModel: AddTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(store: FinancialStore) {
        self._viewModel = StateObject(wrappedValue: AddTransactionViewModel(store: store))
    }
    
    var body: some View {
        ZStack {
            AddTransactionBackground()
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    Capsule()
                        .fill(.white.opacity(0.32))
                        .frame(width: 42, height: 5)
                        .padding(.top, 14)
                    
                    header
                    formContent
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: viewModel.configureInitialSelection)
        .onChange(of: viewModel.transactionType) { _, newType in
            viewModel.handleTypeChange(to: newType)
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            Text("Add Transaction")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.heavy)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.glass)
        }
    }
    
    private var formContent: some View {
//        @Bindable var viewModel = viewModel
        return LiquidGlassStack {
            VStack(alignment: .leading, spacing: 20) {
                TransactionTypePicker(selection: $viewModel.transactionType)
                
                AmountGlassField(
                    amountString: $viewModel.amountString,
                    type: viewModel.transactionType
                )
                
                CategoryPicker(
                    categories: viewModel.availableCategories,
                    selectedCategory: $viewModel.selectedCategory,
                    tint: viewModel.transactionType.tintColor
                )
                
                WalletGlassPicker(
                    kantongs: viewModel.store.daftarKantong,
                    selectedKantongId: $viewModel.selectedKantongId,
                    selectedKantong: viewModel.selectedKantong
                )
                
                MetadataFields(
                    transactionDate: $viewModel.transactionDate,
                    note: $viewModel.note
                )
                
                saveButton
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            viewModel.saveTransaction {
                dismiss()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.canSave ? "checkmark.circle.fill" : viewModel.selectedCategory.symbolName)
                    .font(.system(.body, weight: .bold))
                Text(viewModel.canSave ? "Save Transaction" : "Enter amount to continue")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.heavy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .foregroundStyle(viewModel.canSave ? .white : .white.opacity(0.62))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(viewModel.canSave ? viewModel.transactionType.tintColor : Color.white.opacity(0.08))
        )
        .liquidGlass(tint: viewModel.canSave ? viewModel.transactionType.tintColor : .white.opacity(0.12), cornerRadius: 16, interactive: true)
        .disabled(!viewModel.canSave)
    }
}

// MARK: - Private Extensions & Subviews
private struct LiquidGlassStack<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 18) {
                content
            }
        } else {
            content
        }
    }
}

private struct AddTransactionBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.045, green: 0.0, blue: 0.07)
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.02, blue: 0.20).opacity(0.95),
                    Color(red: 0.07, green: 0.0, blue: 0.10),
                    Color(red: 0.02, green: 0.0, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.12, blue: 0.48).opacity(0.26), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 240
            )
            RadialGradient(
                colors: [Color.purple.opacity(0.24), .clear],
                center: .topLeading,
                startRadius: 24,
                endRadius: 260
            )
        }
    }
}

private struct TransactionTypePicker: View {
    @Binding var selection: TransactionType
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        
        layout {
            ForEach(TransactionType.allCases) { type in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selection = type
                    }
                } label: {
                    Label(type.title, systemImage: type.symbolName)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(selection == type ? .white : .white.opacity(0.58))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selection == type ? type.tintColor : .clear)
                        )
                }
                .buttonStyle(.plain)
                .liquidGlass(tint: selection == type ? type.tintColor : .white.opacity(0.08), cornerRadius: 16, interactive: true)
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct AmountGlassField: View {
    @Binding var amountString: String
    let type: TransactionType
    
    @ScaledMetric(relativeTo: .largeTitle) private var amountFontSize: CGFloat = 48
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel(title: "Amount", systemImage: "dollarsign")
            
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Rp")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(type.tintColor)
                
                TextField("0", text: $amountString)
                    .keyboardType(.numberPad)
                    .font(.system(size: amountFontSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .tint(type.tintColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.30, green: 0.13, blue: 0.34).opacity(0.92), Color(red: 0.19, green: 0.14, blue: 0.32).opacity(0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(type.tintColor.opacity(0.25), lineWidth: 1.2)
        )
        .liquidGlass(tint: type.tintColor.opacity(0.18), cornerRadius: 22, interactive: false)
    }
}

private struct CategoryPicker: View {
    let categories: [TransactionCategory]
    @Binding var selectedCategory: TransactionCategory
    let tint: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .sectionTitleStyle()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories) { category in
                        CategoryGlassButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            tint: tint
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct CategoryGlassButton: View {
    let category: TransactionCategory
    let isSelected: Bool
    let tint: Color
    let action: () -> Void
    
    @ScaledMetric(relativeTo: .body) private var buttonWidth: CGFloat = 78
    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 82
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.symbolName)
                    .font(.system(.title3, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                Text(category.name)
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.62))
            .frame(width: buttonWidth, height: buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.42) : Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(isSelected ? tint.opacity(0.72) : .white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .liquidGlass(tint: isSelected ? tint.opacity(0.42) : .white.opacity(0.08), cornerRadius: 17, interactive: true)
    }
}

private struct WalletGlassPicker: View {
    let kantongs: [Kantong]
    @Binding var selectedKantongId: UUID
    let selectedKantong: Kantong?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet (Kantong)")
                .sectionTitleStyle()
            
            Menu {
                ForEach(kantongs) { kantong in
                    Button {
                        selectedKantongId = kantong.id
                    } label: {
                        Label("\(kantong.name) - \(formatCurrency(kantong.balance))", systemImage: kantong.iconName)
                    }
                }
            } label: {
                let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout(spacing: 14))
                
                layout {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.18, blue: 0.48).opacity(0.22))
                            .frame(width: 46, height: 46)
                        Image(systemName: selectedKantong?.iconName ?? "wallet.pass.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(selectedKantong?.themeColor ?? .white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedKantong?.name ?? "Select Wallet")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        Text("Balance: \(formatCurrency(selectedKantong?.balance ?? 0))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.52))
                    }
                    
                    if !dynamicTypeSize.isAccessibilitySize { Spacer() }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.52))
                }
                .padding(17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.11), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .liquidGlass(tint: .white.opacity(0.10), cornerRadius: 18, interactive: true)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
}

private struct MetadataFields: View {
    @Binding var transactionDate: Date
    @Binding var note: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 12)) : AnyLayout(HStackLayout(spacing: 12))
        
        layout {
            // FIX: Baris `@Bindable var test = self` dihapus sepenuhnya agar tidak memicu compile error
            VStack(alignment: .leading, spacing: 9) {
                SectionLabel(title: "Date", systemImage: "calendar")
                DatePicker("", selection: $transactionDate, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color(red: 1.0, green: 0.18, blue: 0.48))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .metadataGlassField()
            
            VStack(alignment: .leading, spacing: 9) {
                SectionLabel(title: "Note", systemImage: "note.text")
                TextField("Optional note...", text: $note)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .tint(Color(red: 1.0, green: 0.18, blue: 0.48))
                    .lineLimit(1)
            }
            .metadataGlassField()
        }
    }
}

private struct SectionLabel: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption)
            .fontWeight(.heavy)
            .textCase(.uppercase)
            .foregroundStyle(Color(red: 1.0, green: 0.58, blue: 0.72).opacity(0.72))
            .tracking(1.2)
    }
}

private extension View {
    @ViewBuilder
    func liquidGlass(tint: Color = .white.opacity(0.12), cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self.bottomAestheticBorder(cornerRadius: cornerRadius)
        }
    }
    
    @ViewBuilder
    func bottomAestheticBorder(cornerRadius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(0.15), .clear, .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
    
    func sectionTitleStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.heavy)
            .textCase(.uppercase)
            .foregroundStyle(Color(red: 1.0, green: 0.58, blue: 0.72).opacity(0.72))
            .tracking(1.2)
    }
    
    func metadataGlassField() -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
            .liquidGlass(tint: .white.opacity(0.10), cornerRadius: 16, interactive: true)
    }
}

#Preview {
    AddTransactionView(store: FinancialStore())
        .preferredColorScheme(.dark)
}
