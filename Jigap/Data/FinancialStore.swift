//
//  FinancialStore.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 16/06/26.
//

import Foundation
import SwiftUI
import Combine

class FinancialStore: ObservableObject {
    // 1. DATA UTAMA (Single Source of Truth)
    // Menggunakan @Published agar setiap ada perubahan data, UI Dashboard langsung ter-update otomatis
    @Published var daftarKantong: [Kantong] = []
    @Published var daftarTransaksi: [Transaction] = []
    
    // Batas pengeluaran harian bawaan (Bisa diubah dinamis dari Onboarding nanti)
    @Published var dailySpendingCap: Double = 152000
    
    // ID Kantong bawaan untuk mempermudah inisialisasi data dummy
    private let rcaId = UUID()
    private let gopayId = UUID()
    private let danaId = UUID()
    
    init() {
        setupDummyData()
    }
    
    // 2. DATA DUMMY (Cara aman agar tidak memicu error 'Extra argument id')
        private func setupDummyData() {
            // Kita inisialisasi sebagai variabel biasa terlebih dahulu
            var rca = Kantong(name: "RCA", balance: 3520000, allocationPercentage: 44, iconName: "creditcard.fill", themeColor: Color(red: 0.2, green: 0.5, blue: 0.9))
            var gopay = Kantong(name: "GoPay", balance: 1520000, allocationPercentage: 19, iconName: "wallet.pass.fill", themeColor: Color(red: 0.0, green: 0.7, blue: 0.4))
            var dana = Kantong(name: "DANA", balance: 800000, allocationPercentage: 10, iconName: "b.square.fill", themeColor: Color(red: 0.1, green: 0.6, blue: 1.0))
            let gwd = Kantong(name: "GWD", balance: 400000, allocationPercentage: 5, iconName: "bitcoinsign.circle.fill", themeColor: Color(red: 0.9, green: 0.6, blue: 0.1))
            
            // Masukkan objek tersebut ke array utama
            daftarKantong = [rca, gopay, dana, gwd]
            
            // Ambil properti ID yang otomatis dibuat oleh sistem masing-masing objek untuk relasi transaksi
            daftarTransaksi = [
                Transaction(title: "Kopi Kenangan", amount: 35000, date: Date(), category: "Coffee", isIncome: false, sourceKantongId: rca.id),
                Transaction(title: "GrabFood", amount: 65000, date: Date(), category: "Food", isIncome: false, sourceKantongId: gopay.id),
                Transaction(title: "Indomaret", amount: 75000, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), category: "Groceries", isIncome: false, sourceKantongId: dana.id)
            ]
        }
    
    // 3. COMPUTED PROPERTIES (Kalkulasi Otomatis untuk Dashboard)
    
    // Menghitung total balance gabungan dari semua kantong secara real-time
    var totalBalance: Double {
        daftarKantong.reduce(0) { $0 + $1.balance }
    }
    
    // Menghitung total pengeluaran khusus hari ini saja untuk indikator progress bar harian
    var totalExpenseToday: Double {
        let calendar = Calendar.current
        return daftarTransaksi
            .filter { calendar.isDateInToday($0.date) && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Mendapatkan nama kantong berdasarkan ID-nya (Berguna untuk TransactionRowView)
    func getKantongName(for id: UUID) -> String {
        return daftarKantong.first(where: { $0.id == id })?.name ?? "Unknown"
    }
    
    // 4. LOGIKA UTAMA FINANSIAL (MUTASI DATA)
    
    // Fungsi untuk menambah transaksi baru sekaligus memotong/menambah saldo kantong yang bersangkutan
    func addTransaction(title: String, amount: Double, category: String, isIncome: Bool, kantongId: UUID) {
        let newTransaction = Transaction(
            title: title,
            amount: amount,
            date: Date(),
            category: category,
            isIncome: isIncome,
            sourceKantongId: kantongId
        )
        
        // 1. Masukkan transaksi baru ke baris paling atas di riwayat
        daftarTransaksi.insert(newTransaction, at: 0)
        
        // 2. Cari kantong yang digunakan, lalu sesuaikan saldonya secara otomatis
        if let index = daftarKantong.firstIndex(where: { $0.id == kantongId }) {
            if isIncome {
                daftarKantong[index].balance += amount
            } else {
                daftarKantong[index].balance -= amount
            }
        }
    }
}
