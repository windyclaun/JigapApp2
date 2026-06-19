//
//  JigapApp.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 12/06/26.
//

import SwiftUI

@main
struct JigapApp: App {
    // Tetap inisialisasi FinancialStore di sini jika dibutuhkan secara global
    @StateObject private var store = FinancialStore()
    
    var body: some Scene {
        WindowGroup {
            // GANTI DI SINI: Ubah menjadi OnBoardingView agar pertama kali run langsung masuk halaman login
            OnBoardingView()
                .environmentObject(store) // Jika onboarding membutuhkan akses ke data store
        }
    }
}
