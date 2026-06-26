//
//  RegisterPanel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

struct RegisterPanel: View {
    let onCreateAccount: (String, String, String) -> Void
    let onSwitchToLogin: () -> Void
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @Binding var errorMessage: String?
    @State private var successMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Create account")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                
                Text("Start tracking your money today")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.52))
            }
            
            VStack(spacing: 16) {
                AuthTextField(
                    text: $fullName,
                    placeholder: "Full name",
                    iconName: "person"
                )
                
                AuthTextField(
                    text: $email,
                    placeholder: "Email address",
                    iconName: "envelope",
                    keyboardType: .emailAddress
                )
                
                AuthSecureField(
                    text: $password,
                    isVisible: $isPasswordVisible,
                    placeholder: "Password (min. 6 chars)"
                )
                
                AuthSecureField(
                    text: $confirmPassword,
                    isVisible: .constant(false),
                    placeholder: "Confirm password",
                    showsVisibilityToggle: false
                )
            }
            
            // MARK: - Banner Status (Sukses / Eror)
            if let error = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if let success = successMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(success)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity)
            }
            
            AuthPrimaryButton(title: "Create Account", action: {
                errorMessage = nil
                successMessage = nil
                
                // 1. Validasi Input Kosong
                if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                    withAnimation(.easeInOut) {
                        errorMessage = "Semua kolom wajib diisi."
                    }
                    return
                }
                
                // 2. Validasi Minimal Karakter Password
                if password.count < 6 {
                    withAnimation(.easeInOut) {
                        errorMessage = "Password minimal terdiri dari 6 karakter."
                    }
                    return
                }
                
                // 3. Validasi Kecocokan Password
                if password != confirmPassword {
                    withAnimation(.easeInOut) {
                        errorMessage = "Konfirmasi password tidak cocok."
                    }
                    return
                }
                
                // Lemparkan data ke OnBoardingView
                onCreateAccount(fullName, email, password)
                
                // Jika tidak ada error dari Store
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if errorMessage == nil {
                        withAnimation(.easeInOut) {
                            successMessage = "Akun berhasil dibuat! Silakan masuk."
                        }
                    }
                }
            })
            
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundStyle(.white.opacity(0.50))
                Button("Sign In", action: onSwitchToLogin)
                    .fontWeight(.heavy)
                    .foregroundStyle(AuthPalette.accent)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Register Panel") {
    ZStack {
        AuthBackground()
            .ignoresSafeArea()
        
        RegisterPanel(
            onCreateAccount: { name, email, pass in print("Register: \(name) - \(email)") },
            onSwitchToLogin: { print("Switch to Login Tapped") },
            errorMessage: .constant(nil)
        )
        .padding(.horizontal, 30)
    }
    .preferredColorScheme(.dark)
}
