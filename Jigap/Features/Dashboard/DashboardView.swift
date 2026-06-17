//
//  DashboardView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

//
//  DashboardView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var store: FinancialStore
    var onSeeAllHistory: () -> Void // Closure untuk intercept pindah ke tab History
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gelap Premium senada dengan warna kartu kamu
                Color(red: 0.08, green: 0.05, blue: 0.07)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Ringkasan Total Saldo (Header)
                        dashboardHeader
                        
                        // 2. Section horizontal untuk daftar Kantong
                        kantongSection
                        
                        // 3. Section vertikal untuk transaksi terakhir
                        recentTransactionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Jigap")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SUBVIEWS DECOMPOSITION
extension DashboardView {
    
    // Header Ringkasan Saldo Utama
    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Saldo")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Menghitung total saldo dari seluruh kantong yang ada di store
            let totalBalance = store.daftarKantong.reduce(0) { $0 + $1.balance }
            
            Text(formatCurrency(totalBalance))
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.08, blue: 0.12))
        )
    }
    
    // Komponen Horizontal Scroll untuk Kantong
    private var kantongSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kantong Kamu")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Cukup passing objek Kantong secara langsung (Read-Only), terhindar dari error '$'
                    ForEach(store.daftarKantong) { kantong in
                        KantongCardView(kantong: kantong)
                    }
                }
            }
        }
    }
    
    // Komponen Daftar Transaksi Terakhir
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transaksi Terakhir")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Menuju tab history via closure yang dilempar dari TabBar
                Button(action: onSeeAllHistory) {
                    Text("See All")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.5))
                }
            }
            
            VStack(spacing: 4) {
                if store.daftarTransaksi.isEmpty {
                    Text("Belum ada transaksi")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                } else {
                    // Mengambil maksimal 5 transaksi terbaru untuk ditampilkan di dashboard
                    ForEach(store.daftarTransaksi.prefix(5)) { transaction in
                        // Mencari nama kantong pendukung berdasarkan UUID secara aman
                        let namaKantong = store.daftarKantong.first(where: { $0.id == transaction.sourceKantongId })?.name ?? "Umum"
                        
                        TransactionRowView(transaction: transaction, kantongName: namaKantong)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}

// MARK: - HELPERS
extension DashboardView {
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
}
//
//#Preview {
//    DashboardView(store: FinancialStore())
//        .preferredColorScheme(.dark)
//}
