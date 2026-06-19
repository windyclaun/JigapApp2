//
//  LoginPanel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

struct LoginPanel: View {
    // Membawa email dan password ke OnBoardingView untuk divalidasi ke FinancialStore lokal
    let onSignIn: (String, String) -> Void
    let onSwitchToRegister: () -> Void
    let onContinue: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
    // Status pesan eksternal yang diikat dengan OnBoardingView/FinancialStore
    @Binding var errorMessage: String?
    @State private var successMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Welcome back")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                
                Text("Sign in to your account")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.52))
            }
            
            VStack(spacing: 16) {
                AuthTextField(
                    text: $email,
                    placeholder: "Email address",
                    iconName: "envelope",
                    keyboardType: .emailAddress
                )
                
                AuthSecureField(
                    text: $password,
                    isVisible: $isPasswordVisible,
                    placeholder: "Password"
                )
                
                Button(action: {}) {
                    Text("Forgot password?")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(AuthPalette.accent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .buttonStyle(.plain)
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
            
            AuthPrimaryButton(title: "Sign In", action: {
                errorMessage = nil
                successMessage = nil
                
                // Validasi input awal secara lokal
                if email.isEmpty || password.isEmpty {
                    withAnimation(.easeInOut) {
                        errorMessage = "Email dan password tidak boleh kosong."
                    }
                    return
                }
                
                // Pengecekan diserahkan ke parent view yang memegang instance FinancialStore
                onSignIn(email, password)
                
                // Jika setelah dieksekusi tidak ada error eksternal, asumsikan transisi sukses
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if errorMessage == nil {
                        withAnimation(.easeInOut) {
                            successMessage = "Login berhasil! Memuat data akun..."
                        }
                    }
                }
            })
            
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(.white.opacity(0.50))
                Button("Sign Up", action: onSwitchToRegister)
                    .fontWeight(.heavy)
                    .foregroundStyle(AuthPalette.accent)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Login Panel") {
    ZStack {
        AuthBackground()
            .ignoresSafeArea()
        
        LoginPanel(
            onSignIn: { email, password in print("Sign In: \(email) - \(password)") },
            onSwitchToRegister: { print("Switch to Register Tapped") },
            onContinue: { print("Continue Tapped") },
            errorMessage: .constant(nil)
        )
        .padding(.horizontal, 30)
    }
    .preferredColorScheme(.dark)
}
