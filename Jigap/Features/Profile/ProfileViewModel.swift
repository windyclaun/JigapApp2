//
//  ProfileViewModel.swift
//  Jigap
//

import SwiftUI

final class ProfileViewModel {
    private let store: FinancialStore
    private let signOutHandler: () -> Void
    
    init(store: FinancialStore, signOutHandler: @escaping () -> Void) {
        self.store = store
        self.signOutHandler = signOutHandler
    }
    
    var displayName: String {
        store.allUsers[store.currentUserEmailPublic]?.name ?? "Guest"
    }
    
    var displayEmail: String {
        store.currentUserEmailPublic == "guest" ? "guest@jigap.local" : store.currentUserEmailPublic
    }
    
    var walletCount: Int {
        store.daftarKantong.count
    }
    
    func signOut() {
        store.signOut()
        signOutHandler()
    }
}

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
}

enum ProfileStyle {
    static let accentColor = Color(red: 1.0, green: 0.18, blue: 0.48)
}
