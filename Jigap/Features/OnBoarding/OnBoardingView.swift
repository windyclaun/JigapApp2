//
//  OnBoardingView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct OnBoardingView: View {
    var onAuthenticated: () -> Void = {}
    @State private var mode: AuthMode = .login
    
    var body: some View {
        ZStack {
            AuthBackground()
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    BrandHeader(compact: mode == .register)
                        .padding(.top, mode == .login ? 64 : 60)
                    
                    if mode == .login {
                        LoginPanel(
                            onSignIn: onAuthenticated,
                            onSwitchToRegister: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    mode = .register
                                }
                            },
                            onContinue: onAuthenticated
                        )
                        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    } else {
                        RegisterPanel(
                            onCreateAccount: onAuthenticated,
                            onSwitchToLogin: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    mode = .login
                                }
                            }
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
                    }
                    
                    Spacer(minLength: 24)
                    
                    footer
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var footer: some View {
        VStack(spacing: 6) {
            if mode == .login {
                Button(action: onAuthenticated) {
                    Label("Continue without account", systemImage: "arrow.right")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white.opacity(0.26))
                }
                .buttonStyle(.plain)
            }
            
            Text("Kantong - Premium Money Tracker")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.14))
        }
    }
}

private struct LoginPanel: View {
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

private struct RegisterPanel: View {
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

private struct BrandHeader: View {
    let compact: Bool
    
    var body: some View {
        VStack(spacing: compact ? 18 : 22) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(AuthPalette.accent)
                    .frame(width: 80, height: 80)
                    .shadow(color: AuthPalette.accent.opacity(0.52), radius: 28, x: 0, y: 14)
                
                Image(systemName: "handbag.fill")
                    .font(.system(size: 34, weight: .heavy))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.92))
            }
            .authLiquidGlass(tint: AuthPalette.accent.opacity(0.35), cornerRadius: 26, interactive: false)
            
            VStack(spacing: 8) {
                Text("Kantong")
                    .font(.system(size: 31, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                
                if !compact {
                    Text("Smart money, smarter you")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.52))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let iconName: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
                .frame(width: 22)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .tint(AuthPalette.accent)
        }
        .authFieldStyle()
    }
}

private struct AuthSecureField: View {
    @Binding var text: String
    @Binding var isVisible: Bool
    let placeholder: String
    var showsVisibilityToggle = true
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "lock")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
                .frame(width: 22)
            
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .tint(AuthPalette.accent)
            
            if showsVisibilityToggle {
                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white.opacity(0.46))
                }
                .buttonStyle(.plain)
            }
        }
        .authFieldStyle()
    }
}

private struct AuthPrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(AuthPalette.accent, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                .shadow(color: AuthPalette.accent.opacity(0.42), radius: 18, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .authLiquidGlass(tint: AuthPalette.accent.opacity(0.32), cornerRadius: 17, interactive: true)
    }
}

private struct AuthBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.0, blue: 0.055)
            LinearGradient(
                colors: [
                    Color(red: 0.21, green: 0.02, blue: 0.18).opacity(0.94),
                    Color(red: 0.07, green: 0.0, blue: 0.08).opacity(0.98),
                    Color(red: 0.02, green: 0.0, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [AuthPalette.accent.opacity(0.23), .clear],
                center: .topTrailing,
                startRadius: 12,
                endRadius: 270
            )
            RadialGradient(
                colors: [Color.purple.opacity(0.20), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 250
            )
        }
    }
}

private enum AuthMode {
    case login
    case register
}

private enum AuthPalette {
    static let accent = Color(red: 1.0, green: 0.11, blue: 0.46)
}

private extension View {
    func authFieldStyle() -> some View {
        self
            .padding(.horizontal, 17)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(AuthPalette.accent.opacity(0.24), lineWidth: 1)
            )
            .authLiquidGlass(tint: .white.opacity(0.10), cornerRadius: 17, interactive: true)
    }
    
    @ViewBuilder
    func authLiquidGlass(tint: Color = .white.opacity(0.12), cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
        }
    }
}

#Preview("Login") {
    OnBoardingView()
}
