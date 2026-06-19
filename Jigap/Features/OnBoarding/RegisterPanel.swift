//
//  RegisterPanel.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 18/06/26.
//

import SwiftUI

struct RegisterPanel: View {
    let onCreateAccount: () -> Void
    let onSwitchToLogin: () -> Void
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    
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
            
            AuthPrimaryButton(title: "Create Account", action: onCreateAccount)
            
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
            onCreateAccount: { print("Create Account Tapped") },
            onSwitchToLogin: { print("Switch to Login Tapped") }
        )
        .padding(.horizontal, 30)
    }
    .preferredColorScheme(.dark)
}
