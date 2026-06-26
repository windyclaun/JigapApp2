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
    @Published var daftarKantong: [Kantong] = [] {
        didSet { saveUserData() }
    }
    @Published var daftarTransaksi: [Transaction] = [] {
        didSet { saveUserData() }
    }
    @Published var dailySpendingCap: Double = 0 {
        didSet { saveUserData() }
    }
    @Published var monthlyIncome: Double = 0 {
        didSet { saveUserData() }
    }
    @Published var customExpenseCategories: [TransactionCategory] = [] {
        didSet { saveUserData() }
    }
    @Published var customIncomeCategories: [TransactionCategory] = [] {
        didSet { saveUserData() }
    }
    
    @AppStorage("all_users_financial_data") private var allUsersRawData: String = "{}"
    
    @AppStorage("current_user_email") private var currentUserEmail: String = ""
    
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
        var monthlyIncome: Double
        var customExpenseCategories: [TransactionCategory]
        var customIncomeCategories: [TransactionCategory]
        
        init(
            name: String,
            password: String,
            kantong: [Kantong],
            transaksi: [Transaction],
            spendingCap: Double,
            monthlyIncome: Double = 0,
            customExpenseCategories: [TransactionCategory] = [],
            customIncomeCategories: [TransactionCategory] = []
        ) {
            self.name = name
            self.password = password
            self.kantong = kantong
            self.transaksi = transaksi
            self.spendingCap = spendingCap
            self.monthlyIncome = monthlyIncome
            self.customExpenseCategories = customExpenseCategories
            self.customIncomeCategories = customIncomeCategories
        }
        
        private enum CodingKeys: String, CodingKey {
            case name, password, kantong, transaksi, spendingCap, monthlyIncome, customExpenseCategories, customIncomeCategories
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            password = try container.decode(String.self, forKey: .password)
            kantong = try container.decode([Kantong].self, forKey: .kantong)
            transaksi = try container.decode([Transaction].self, forKey: .transaksi)
            spendingCap = try container.decode(Double.self, forKey: .spendingCap)
            monthlyIncome = try container.decodeIfPresent(Double.self, forKey: .monthlyIncome) ?? 0
            customExpenseCategories = try container.decodeIfPresent([TransactionCategory].self, forKey: .customExpenseCategories) ?? []
            customIncomeCategories = try container.decodeIfPresent([TransactionCategory].self, forKey: .customIncomeCategories) ?? []
        }
    }
    
    var allUsers: [String: UserDataModel] {
        guard let data = allUsersRawData.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: UserDataModel].self, from: data)) ?? [:]
    }
    
    init() {
        if !currentUserEmail.isEmpty {
            loadCurrentAccountData()
        }
    }
    
    // 2. LOGIKA SWITCH AKUN (Dipanggil saat Login Berhasil)
    func switchAccount(to email: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.currentUserEmail = cleanedEmail
        loadCurrentAccountData()
    }
    
    private func loadCurrentAccountData() {
        guard !currentUserEmail.isEmpty else { return }
        
        if let userSpecificData = allUsers[currentUserEmail] {
            let cleanedUserData = removingUnusedLegacySeedKantong(from: userSpecificData)
            if cleanedUserData.kantong.count != userSpecificData.kantong.count {
                saveUserDataModel(cleanedUserData, for: currentUserEmail)
            }
            
            self.daftarKantong = cleanedUserData.kantong
            self.daftarTransaksi = cleanedUserData.transaksi
            self.dailySpendingCap = cleanedUserData.spendingCap
            self.monthlyIncome = cleanedUserData.monthlyIncome
            self.customExpenseCategories = cleanedUserData.customExpenseCategories
            self.customIncomeCategories = cleanedUserData.customIncomeCategories
        } else {
            setupDefaultKantongForNewUser()
        }
    }
        func registerNewUser(name: String, email: String, password: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var currentUsersList = allUsers
        
        let defaultKantong: [Kantong] = []
        let defaultTransaksi: [Transaction] = []
        
        let newUserModel = UserDataModel(
            name: name,
            password: password,
            kantong: defaultKantong,
            transaksi: defaultTransaksi,
            spendingCap: 0,
            monthlyIncome: 0,
            customExpenseCategories: [],
            customIncomeCategories: []
        )
        
        currentUsersList[cleanedEmail] = newUserModel
        
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
    }
    
    private func saveUserData() {
        guard currentUserEmail != "guest", !currentUserEmail.isEmpty else { return }
        
        var currentUsersList = allUsers
        
        let oldName = currentUsersList[currentUserEmail]?.name ?? "User"
        let oldPassword = currentUsersList[currentUserEmail]?.password ?? ""
        
        let currentData = UserDataModel(
            name: oldName,
            password: oldPassword,
            kantong: daftarKantong,
            transaksi: daftarTransaksi,
            spendingCap: dailySpendingCap,
            monthlyIncome: monthlyIncome,
            customExpenseCategories: customExpenseCategories,
            customIncomeCategories: customIncomeCategories
        )
        currentUsersList[currentUserEmail] = currentData
        
        // Encode kembali ke AppStorage
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
    }
    
    private func setupDefaultKantongForNewUser() {
        self.daftarKantong = []
        self.dailySpendingCap = 0
        self.monthlyIncome = 0
        self.daftarTransaksi = []
        self.customExpenseCategories = []
        self.customIncomeCategories = []
    }
    
    private func removingUnusedLegacySeedKantong(from userData: UserDataModel) -> UserDataModel {
        let legacySeedNames: Set<String> = ["rca", "gopay", "dana", "gwd"]
        let usedKantongIds = Set(userData.transaksi.map(\.sourceKantongId))
        let cleanedKantong = userData.kantong.filter { kantong in
            let normalizedName = kantong.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let isLegacySeed = legacySeedNames.contains(normalizedName)
            let isUnused = kantong.balance == 0 && !usedKantongIds.contains(kantong.id)
            return !(isLegacySeed && isUnused)
        }
        
        guard cleanedKantong.count != userData.kantong.count else { return userData }
        
        return UserDataModel(
            name: userData.name,
            password: userData.password,
            kantong: cleanedKantong,
            transaksi: userData.transaksi,
            spendingCap: userData.spendingCap,
            monthlyIncome: userData.monthlyIncome,
            customExpenseCategories: userData.customExpenseCategories,
            customIncomeCategories: userData.customIncomeCategories
        )
    }
    
    private func saveUserDataModel(_ userData: UserDataModel, for email: String) {
        var currentUsersList = allUsers
        currentUsersList[email] = userData
        
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
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
    
    func addKantong(name: String, balance: Double, iconName: String, themeColor: Color) {
        let newKantong = Kantong(
            name: name,
            balance: balance,
            allocationPercentage: 0,
            iconName: iconName,
            themeColor: themeColor
        )
        daftarKantong.append(newKantong)
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
    
    func addCustomCategory(name: String, symbolName: String, isIncome: Bool) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        
        let newCategory = TransactionCategory(name: cleanedName, symbolName: symbolName)
        if isIncome {
            guard !customIncomeCategories.contains(where: { $0.name.caseInsensitiveCompare(cleanedName) == .orderedSame }) else { return }
            customIncomeCategories.append(newCategory)
        } else {
            guard !customExpenseCategories.contains(where: { $0.name.caseInsensitiveCompare(cleanedName) == .orderedSame }) else { return }
            customExpenseCategories.append(newCategory)
        }
    }
    
    func updateCurrentUserPassword(to newPassword: String) {
        guard currentUserEmail != "guest", !currentUserEmail.isEmpty else { return }
        var currentUsersList = allUsers
        guard var user = currentUsersList[currentUserEmail] else { return }
        user.password = newPassword
        currentUsersList[currentUserEmail] = user
        
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
    }
    
    func deleteCurrentAccount() {
        guard currentUserEmail != "guest", !currentUserEmail.isEmpty else { return }
        var currentUsersList = allUsers
        currentUsersList.removeValue(forKey: currentUserEmail)
        
        if let encoded = try? JSONEncoder().encode(currentUsersList),
           let jsonString = String(data: encoded, encoding: .utf8) {
            allUsersRawData = jsonString
        }
        
        signOut()
    }
    
    func signOut() {
        currentUserEmail = ""
        daftarKantong = []
        daftarTransaksi = []
        dailySpendingCap = 0
        monthlyIncome = 0
        customExpenseCategories = []
        customIncomeCategories = []
    }
}
