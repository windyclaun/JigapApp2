//
//  TransactionRowView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct TransactionRowView: View {
    // 1. Menerima data transaksi dinamis agar komponen ini bisa dipakai berulang kali (Reusable)
    let transaction: Transaction
    let kantongName: String // Untuk menampilkan nama kantong asal (cth: "RCA")
    
    // 2. Membaca ukuran font environment untuk mendeteksi fitur Accessibility Larger Text
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                // KONDISI ACCESSIBILITY: Jika font iPhone di-set sangat besar,
                // layout otomatis berubah jadi VERTICAL agar teks nominal tidak terpotong ke samping
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        categoryIcon
                        textInformation
                    }
                    amountText
                }
            } else {
                // KONDISI NORMAL: Layout horizontal standar yang rapi dan estetik
                HStack(alignment: .center, spacing: 12) {
                    categoryIcon
                    textInformation
                    Spacer()
                    amountText
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        // Background transparan gelap khas dark mode premium agar menyatu dengan Bento Box
        .background(Color(.systemBackground).opacity(0.05))
        // Menggabungkan elemen ke dalam satu kesatuan agar mudah dibaca oleh VoiceOver (Accessibility)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title), kategori \(transaction.category), menggunakan \(kantongName), jumlah \(transaction.isIncome ? "pemasukan" : "pengeluaran") \(Int(transaction.amount)) rupiah")
    }
    
    // MARK: - SUBCOMPONENTS (View Decomposition)
    
    // Subcomponent 1: Ikon Kategori Bulat Lingkaran
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color.init(red: 0.9, green: 0.1, blue: 0.4).opacity(0.15)) // Bulatan pink soft neon
                .frame(width: 40, height: 40)
            
            Image(systemName: getIconName(for: transaction.category))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.init(red: 1.0, green: 0.2, blue: 0.5)) // Ikon magenta terang (kontras tinggi)
        }
    }
    
    // Subcomponent 2: Informasi Teks (Judul Transaksi & Sub-info Nama Kantong)
    private var textInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(transaction.title)
                .font(.body) // Menggunakan Dynamic Type Font
                .fontWeight(.semibold)
                .foregroundColor(.white) // Putih tegas untuk dark mode
            
            // Format sub-info: "Kategori • Nama Kantong" (cth: "Coffee • RCA")
            Text("\(transaction.category) • \(kantongName)")
                .font(.footnote)
                .foregroundColor(.gray) // Abu-abu sekunder untuk hierarki visual
        }
    }
    
    // Subcomponent 3: Angka Nominal Uang (Merah untuk Keluar, Hijau untuk Masuk)
    private var amountText: some View {
        Text("\(transaction.isIncome ? "+" : "-") \(formatShortCurrency(transaction.amount))")
            .font(.system(.body, design: .rounded))
            .fontWeight(.bold)
            // Cerdas menentukan warna berdasarkan jenis transaksi (Sufficient Contrast)
            .foregroundColor(transaction.isIncome ? Color.green : Color.init(red: 1.0, green: 0.3, blue: 0.4))
    }
    
    // MARK: - HELPER FUNCTIONS
    
    // Memetakan string kategori ke SF Symbol Apple secara dinamis
    private func getIconName(for category: String) -> String {
        switch category.lowercased() {
        case "coffee", "food", "makanan": return "cup.and.saucer.fill"
        case "groceries", "belanja": return "cart.fill"
        case "salary", "gaji": return "banknote.fill"
        case "transport": return "car.fill"
        default: return "creditcard.fill"
        }
    }
    
    // Memformat angka besar menjadi singkatan estetik (cth: 35000 -> Rp 35k)
    private func formatShortCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "Rp %.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "Rp %.0fk", value / 1_000)
        } else {
            return String(format: "Rp %.0f", value)
        }
    }
}

// MARK: - PREVIEW TESTING
#Preview("Normal Dark Mode") {
    ZStack {
        Color(red: 0.08, green: 0.05, blue: 0.07).ignoresSafeArea() // BG Dark Mode Ungu Tua sesuai UI-mu
        
        TransactionRowView(
            transaction: Transaction(title: "Kopi Kenangan", amount: 35000, date: Date(), category: "Coffee", isIncome: false, sourceKantongId: UUID()),
            kantongName: "RCA"
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Accessibility Text Scale") {
    ZStack {
        Color(red: 0.08, green: 0.05, blue: 0.07).ignoresSafeArea()
        
        TransactionRowView(
            transaction: Transaction(title: "Kopi Kenangan", amount: 35000, date: Date(), category: "Coffee", isIncome: false, sourceKantongId: UUID()),
            kantongName: "RCA"
        )
        .environment(\.dynamicTypeSize, .accessibility3) // Simulasi jika teks iPhone sangat besar
        .padding()
    }
    .preferredColorScheme(.dark)
}
