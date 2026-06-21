//
//  PrivacySecurityView.swift
//  Jigap
//

import SwiftUI

struct PrivacySecurityView: View {
    let isGuestAccount: Bool
    @Binding var isLoggedIn: Bool
    let accentColor: Color
    let updatePassword: (String) -> Void
    let deleteAccount: () -> Void
    
    @State private var newPassword = ""
    @State private var statusMessage: String?
    @State private var isShowingDeleteConfirmation = false
    
    private var canSavePassword: Bool {
        newPassword.count >= 6 && !isGuestAccount
    }
    
    var body: some View {
        ProfileDetailContainer(title: "Privacy") {
            VStack(alignment: .leading, spacing: 18) {
                passwordSection
                
                Divider().overlay(.white.opacity(0.18))
                
                deleteAccountButton
            }
            .confirmationDialog("Delete this account?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete Account", role: .destructive) {
                    deleteAccount()
                    isLoggedIn = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes the saved profile, wallets, and transactions on this device.")
            }
        }
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Password")
                .profileDetailTitle()
            
            SecureField("New password", text: $newPassword)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .tint(accentColor)
                .padding(16)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .disabled(isGuestAccount)
            
            Button {
                updatePassword(newPassword)
                newPassword = ""
                statusMessage = "Password updated."
            } label: {
                Text("Update Password")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSavePassword)
            .opacity(canSavePassword ? 1 : 0.55)
            
            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
        }
    }
    
    private var deleteAccountButton: some View {
        Button(role: .destructive) {
            isShowingDeleteConfirmation = true
        } label: {
            Label("Delete Account", systemImage: "trash")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(Color(red: 1.0, green: 0.55, blue: 0.62))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isGuestAccount)
        .opacity(isGuestAccount ? 0.55 : 1)
    }
}
