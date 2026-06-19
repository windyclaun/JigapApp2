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
    @Published var daftarKantong: [Kantong] = [] {
        didSet { saveUserData() }
    }
    @Published var daftarTransaksi: [Transaction] = [] {
        didSet { saveUserData() }
    }
    @Published var dailySpendingCap: Double = 152000 {
        didSet { saveUserData() }
    }
    
    // Tempat penyimpanan terpusat seluruh user dalam bentuk JSON String
    @AppStorage("all_users_financial_data") private var allUsersRawData: String = "{}"
    
    // Email user yang sedang aktif saat ini (Tetap private untuk keamanan enkapsulasi)
    private var currentUserEmail: String = "guest"
    
    // 🌟 Jembatan Akses Publik untuk ProfileView & View Eksternal Lainnya
    var currentUserEmailPublic: String {
        return currentUserEmail
    }
    
    // MARK: - Model Kontainer (Ditambahkan password agar OnBoardingView bisa memvalidasi)
    struct UserDataModel: Codable {
        var name: String
        var password: String
        var kantong: [Kantong]
        var transaksi: [Transaction]
        var spendingCap: Double
    }
    
    // MARK: - Computed Property Pembantu untuk OnBoardingView
    /// Mengembalikan dictionary semua user yang ter-decode dari JSON string AppStorage
    var allUsers: [String: UserDataModel] {
        guard let data = allUsersRawData.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: UserDataModel].self, from: data)) ?? [:]
    }
    
    init() {
        // Jangan panggil setupDummyData secara mentah di sini agar tidak menimpa akun lain
    }
    
    // 2. LOGIKA SWITCH AKUN (Dipanggil saat Login Berhasil)
    func switchAccount(to email: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.currentUserEmail = cleanedEmail
        
        if let userSpecificData = allUsers[cleanedEmail] {
            // Jika user sudah ada di storage lokal, muat datanya
            self.daftarKantong = userSpecificData.kantong
            self.daftarTransaksi = userSpecificData.transaksi
            self.dailySpendingCap = userSpecificData.spendingCap
        } else {
            // Jika user baru pertama kali masuk/daftar, buatkan template kantong default khusus dia
            setupDefaultKantongForNewUser()
        }
    }
    
    // MARK: - LOGIKA DAFTAR USER BARU (Dipanggil dari RegisterPanel via OnBoardingView)
    func registerNewUser(name: String, email: String, password: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var currentUsersList = allUsers
        
        // Buat temporary template kantong bawaan untuk user baru
        let rca = Kantong(name: "RCA", balance: 3520000, allocationPercentage: 44, iconName: "creditcard.fill", themeColor: Color(red: 0.2, green: 0.5, blue: 0.9))
        let gopay = Kantong(name: "GoPay", balance: 1520000, allocationPercentage: 19, iconName: "wallet.pass.fill", themeColor: Color(red: 0.0, green: 0.7, blue: 0.4))
        let dana = Kantong(name: "DANA", balance: 800000, allocationPercentage: 10, iconName: "b.square.fill", themeColor: Color(red: 0.1, green: 0.6, blue: 1.0))
        let gwd = Kantong(name: "GWD", balance: 400000, allocationPercentage: 5, iconName: "bitcoinsign.circle.fill", themeColor: Color(red: 0.9, green: 0.6, blue: 0.1))
        
        let defaultKantong = [rca, gopay, dana, gwd]
        let defaultTransaksi = [
            Transaction(title: "Welcome Bonus \(name)", amount: 50000, date: Date(), category: "Bonus", isIncome: true, sourceKantongId: rca.id)
        ]
        
        // Simpan ke struk model baru
        let newUserModel = UserDataModel(
            name: name,
            password: password,
            kantong: defaultKantong,
            transaksi: defaultTransaksi,
            spendingCap: 152000
        )
        
        currentUsersList[cleanedEmail] = newUserModel
        
        // Save langsung ke AppStorage string
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
    }
    
    // 3. LOGIKA SAVE DATA KELOKAL PER USER
    private func saveUserData() {
        guard currentUserEmail != "guest", !currentUserEmail.isEmpty else { return }
        
        var currentUsersList = allUsers
        
        // Ambil data nama & password lama agar tidak hilang saat data transaksi di-update
        let oldName = currentUsersList[currentUserEmail]?.name ?? "User"
        let oldPassword = currentUsersList[currentUserEmail]?.password ?? ""
        
        // Bungkus data aktif saat ini
        let currentData = UserDataModel(
            name: oldName,
            password: oldPassword,
            kantong: daftarKantong,
            transaksi: daftarTransaksi,
            spendingCap: dailySpendingCap
        )
        currentUsersList[currentUserEmail] = currentData
        
        // Encode kembali ke AppStorage
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
    }
    
    // Template bawaan untuk setiap user baru saat dipanggil switchAccount pertama kali
    private func setupDefaultKantongForNewUser() {
        let rca = Kantong(name: "RCA", balance: 3520000, allocationPercentage: 44, iconName: "creditcard.fill", themeColor: Color(red: 0.2, green: 0.5, blue: 0.9))
        let gopay = Kantong(name: "GoPay", balance: 1520000, allocationPercentage: 19, iconName: "wallet.pass.fill", themeColor: Color(red: 0.0, green: 0.7, blue: 0.4))
        let dana = Kantong(name: "DANA", balance: 800000, allocationPercentage: 10, iconName: "b.square.fill", themeColor: Color(red: 0.1, green: 0.6, blue: 1.0))
        let gwd = Kantong(name: "GWD", balance: 400000, allocationPercentage: 5, iconName: "bitcoinsign.circle.fill", themeColor: Color(red: 0.9, green: 0.6, blue: 0.1))
        
        self.daftarKantong = [rca, gopay, dana, gwd]
        self.dailySpendingCap = 152000
        
        self.daftarTransaksi = [
            Transaction(title: "Welcome Bonus", amount: 50000, date: Date(), category: "Bonus", isIncome: true, sourceKantongId: rca.id)
        ]
    }
    
    // 4. COMPUTED PROPERTIES
    var totalBalance: Double {
        daftarKantong.reduce(0) { $0 + $1.balance }
    }
    
    var totalExpenseToday: Double {
        let calendar = Calendar.current
        return daftarTransaksi
            .filter { calendar.isDateInToday($0.date) && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getKantongName(for id: UUID) -> String {
        return daftarKantong.first(where: { $0.id == id })?.name ?? "Unknown"
    }
    
    func addTransaction(title: String, amount: Double, category: String, isIncome: Bool, kantongId: UUID) {
        let newTransaction = Transaction(title: title, amount: amount, date: Date(), category: category, isIncome: isIncome, sourceKantongId: kantongId)
        daftarTransaksi.insert(newTransaction, at: 0)
        
        if let index = daftarKantong.firstIndex(where: { $0.id == kantongId }) {
            if isIncome {
                daftarKantong[index].balance += amount
            } else {
                daftarKantong[index].balance -= amount
            }
        }
    }
}
