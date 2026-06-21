//
//  DashboardView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    var onShowHistory: () -> Void = {}
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var isShowingAddMenu = false

    init(store: FinancialStore = FinancialStore(), onShowHistory: @escaping () -> Void = {}) {
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(store: store))
        self.onShowHistory = onShowHistory
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                dashboardBackground
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerView
                        balanceCard
                        kantongSection
                        weeklyFlowCard
                        recentActivityCard
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 112)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isShowingAddMenu) {
                AddWalletView(store: viewModel.store)
            }
        }
    }
    
    private var dashboardBackground: some View {
        ZStack {
            viewModel.darkBackground
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.02, blue: 0.22).opacity(0.78),
                    Color(red: 0.08, green: 0.00, blue: 0.08).opacity(0.95),
                    Color(red: 0.015, green: 0.00, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [viewModel.accentColor.opacity(0.28), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 260
            )
            RadialGradient(
                colors: [Color.purple.opacity(0.22), .clear],
                center: .topLeading,
                startRadius: 18,
                endRadius: 220
            )
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            Color.clear
                .frame(width: 44, height: 44)
            
            Spacer()
            
            VStack(spacing: 3) {
                Text(viewModel.currentMonthTitle)
                    .font(.caption2)
                    .fontWeight(.heavy)
                    .foregroundStyle(viewModel.accentColor.opacity(0.72))
                    .tracking(1.4)
                
                Text("Financial Planner")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(viewModel.accentColor)
                            .shadow(color: viewModel.accentColor.opacity(0.48), radius: 12, x: 0, y: 4)
                    )
                    .overlay(Circle().stroke(.white.opacity(0.38), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
        .padding(.horizontal, 24)
    }
    
    private var balanceCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.54))
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.caption2)
                        Text("+ 2.4%")
                            .font(.caption)
                            .fontWeight(.heavy)
                    }
                    .foregroundStyle(Color(red: 0.94, green: 0.48, blue: 0.76))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.14), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.formatCurrency(viewModel.store.totalBalance))
                        .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 34 : 38, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                    
                    Text("Monthly income: \(viewModel.formatCurrency(viewModel.store.monthlyIncome))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.44))
                }
                
                VStack(spacing: 9) {
                    HStack {
                        Text("Daily Cap Usage")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white.opacity(0.52))
                        Spacer()
                        Text("\(viewModel.formatShortCurrency(viewModel.store.totalExpenseToday)) / \(viewModel.formatShortCurrency(viewModel.store.dailySpendingCap))")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(Color(red: 0.27, green: 1.0, blue: 0.54))
                    }
                    
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.12))
                            Capsule()
                                .fill(LinearGradient(colors: [Color(red: 0.2, green: 0.94, blue: 0.46), viewModel.cyanColor], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * viewModel.dailyProgress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(12)
                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var kantongSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Kantong")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: {
                    isShowingAddMenu = true
                }) {
                    Label("wallets", systemImage: "plus")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(Color(red: 1.0, green: 0.48, blue: 0.72))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(viewModel.accentColor.opacity(0.18), in: Capsule())
                        .overlay(Capsule().stroke(viewModel.accentColor.opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            
            if viewModel.store.daftarKantong.isEmpty {
                emptyKantongState
                    .padding(.horizontal, 24)
            } else if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    ForEach(viewModel.store.daftarKantong) { kantong in
                        walletCard(kantong)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.store.daftarKantong) { kantong in
                            walletCard(kantong)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private var emptyKantongState: some View {
        Button {
            isShowingAddMenu = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "wallet.pass")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(viewModel.accentColor)
                    .frame(width: 42, height: 42)
                    .background(viewModel.accentColor.opacity(0.16), in: Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("No kantong yet")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                    Text("Add your first wallet to start tracking balances.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.54))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private var weeklyFlowCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Weekly Flow")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        Text("Total spent this week")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.43))
                    }
                    
                    Spacer()
                    
                    Text(viewModel.formatShortCurrency(viewModel.weeklyTotal))
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color(red: 1.0, green: 0.44, blue: 0.68))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(viewModel.accentColor.opacity(0.2), in: Capsule())
                }
                
                HStack(alignment: .bottom, spacing: 16) {
                    ForEach(viewModel.weeklyBars) { bar in
                        VStack(spacing: 8) {
                            Text(viewModel.formatShortCurrency(bar.amount))
                                .font(.caption2)
                                .fontWeight(.heavy)
                                .foregroundStyle(.white.opacity(bar.amount > 0 ? 0.70 : 0.28))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                            
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: bar.isToday ? [viewModel.accentColor, Color(red: 1.0, green: 0.08, blue: 0.36)] : [viewModel.accentColor.opacity(0.76), viewModel.accentColor.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 24, height: bar.height)
                                .overlay(alignment: .top) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.white.opacity(bar.isToday ? 0.18 : 0.12))
                                        .frame(height: 8)
                                        .padding(.horizontal, 3)
                                        .padding(.top, 3)
                                }
                                .shadow(color: bar.isToday ? viewModel.accentColor.opacity(0.42) : .clear, radius: 10, x: 0, y: 0)
                            
                            Text(bar.label)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(bar.isToday ? 0.82 : 0.42))
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(bar.label), spent \(viewModel.formatCurrency(bar.amount))")
                    }
                }
                .frame(height: 140, alignment: .bottom)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var recentActivityCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Recent Activity")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: onShowHistory) {
                        HStack(spacing: 7) {
                            Text("See all")
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                        }
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color(red: 1.0, green: 0.44, blue: 0.68))
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(spacing: 14) {
                    ForEach(viewModel.store.daftarTransaksi.prefix(3)) { transaction in
                        dashboardTransactionRow(transaction)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func walletCard(_ kantong: Kantong) -> some View {
        GlassCard(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: kantong.iconName)
                    .font(.system(size: 19, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(kantong.themeColor)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(kantong.name)
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white.opacity(0.52))
                    
                    Text(viewModel.formatShortBalance(kantong.balance))
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                }

            }
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : 132, height: dynamicTypeSize.isAccessibilitySize ? nil : 118, alignment: .leading)
    }
    
    private func dashboardTransactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(viewModel.accentColor.opacity(0.16))
                    .frame(width: 42, height: 42)
                Image(systemName: viewModel.iconName(for: transaction.category))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.48, blue: 0.72))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 7) {
                    Text(viewModel.store.getKantongName(for: transaction.sourceKantongId))
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(viewModel.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.accentColor.opacity(0.18), in: Capsule())
                    
                    Text(transaction.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.42))
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 10)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.isIncome ? "+" : "-")\(viewModel.formatShortCurrency(transaction.amount))")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(transaction.isIncome ? Color.green : Color(red: 1.0, green: 0.42, blue: 0.66))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: transaction.isIncome ? "arrow.down.left" : "arrow.up.right")
                        .font(.caption2)
                    Text(viewModel.formatTransactionDate(transaction.date))
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white.opacity(0.42))
            }
        }
    }
}

#Preview {
    DashboardView(store: FinancialStore())
        .preferredColorScheme(.dark)
}
