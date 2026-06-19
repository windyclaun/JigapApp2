//
//  LoginPanel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

struct LoginPanel: View {
    let onSignIn: () -> Void
    let onSwitchToRegister: () -> Void
    let onContinue: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    
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
            
            AuthPrimaryButton(title: "Sign In", action: onSignIn)
            
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
        // Menggunakan background auth yang sudah kita pisah agar tampilannya sinematik
        AuthBackground()
            .ignoresSafeArea()
        
        LoginPanel(
            onSignIn: { print("Sign In Tapped") },
            onSwitchToRegister: { print("Switch to Register Tapped") },
            onContinue: { print("Continue Tapped") }
        )
        .padding(.horizontal, 30)
    }
    .preferredColorScheme(.dark)
}
