//
//   OnBoardingView.swift
//   Jigap
//
//   Created by Windy Claudia Napitupulu on 14/06/26.
//

import SwiftUI

struct OnBoardingView: View {
    // Ambil store global yang disuntikkan dari JigapApp.swift
    @EnvironmentObject var store: FinancialStore
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var onAuthenticated: () -> Void = {}
    @State private var mode: AuthMode = .login
    
    // MARK: - State Tambahan untuk Validasi Pesan
    @State private var authErrorMessage: String? = nil
    
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
                            onSignIn: { emailData, passwordData in
                                let cleanedEmail = emailData.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                // Ambil daftar user berbasis memori di FinancialStore
                                if let user = store.allUsers[cleanedEmail] {
                                    if user.password == passwordData {
                                        // 1. Set nama user aktif di store finansial jika cocok
                                        store.switchAccount(to: cleanedEmail)
                                        // 2. Trigger ganti halaman ke dashboard
                                        withAnimation { isLoggedIn = true }
                                        onAuthenticated()
                                    } else {
                                        withAnimation(.easeInOut) {
                                            authErrorMessage = "Password yang kamu masukkan salah."
                                        }
                                    }
                                } else {
                                    withAnimation(.easeInOut) {
                                        authErrorMessage = "Akun tidak ditemukan. Silakan Sign Up terlebih dahulu."
                                    }
                                }
                            },
                            onSwitchToRegister: {
                                authErrorMessage = nil // Reset pesan saat tukar halaman
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    mode = .register
                                }
                            },
                            onContinue: {
                                // Masuk sebagai guest dari tombol dalam panel
                                store.switchAccount(to: "guest_user")
                                withAnimation { isLoggedIn = true }
                                onAuthenticated()
                            },
                            errorMessage: $authErrorMessage // Ikat state error ke panel login
                        )
                        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    } else {
                        RegisterPanel(
                            onCreateAccount: { nameData, emailData, passwordData in
                                // Validasi memori lokal: Cek jika email sudah terpakai
                                if store.allUsers[emailData] != nil {
                                    withAnimation(.easeInOut) {
                                        authErrorMessage = "Email ini sudah terdaftar di perangkat ini."
                                    }
                                } else {
                                    // 1. Buatkan akun memori terpisah baru di FinancialStore
                                    store.registerNewUser(name: nameData, email: emailData, password: passwordData)
                                    store.switchAccount(to: emailData)
                                    
                                    // 2. Langsung login masuk dashboard
                                    withAnimation { isLoggedIn = true }
                                    onAuthenticated()
                                }
                            },
                            onSwitchToLogin: {
                                authErrorMessage = nil // Reset pesan saat tukar halaman
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    mode = .login
                                }
                            },
                            errorMessage: $authErrorMessage // Ikat state error ke panel register
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
    
    // MARK: - Perbaikan Logika Tombol Guest Mode di Footer
    private var footer: some View {
        VStack(spacing: 6) {
            if mode == .login {
                Button(action: {
                    // FIX: Set status akun & trigger perpindahan view root
                    store.switchAccount(to: "guest_user")
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        isLoggedIn = true
                    }
                    onAuthenticated()
                }) {
                    Label("Continue without account", systemImage: "arrow.right")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white.opacity(0.26))
                }
                .buttonStyle(.plain)
            }
            
            Text("Jigap - Premium Money Tracker")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.white.opacity(0.14))
        }
    }
}

// MARK: - Subviews
struct BrandHeader: View {
    let compact: Bool
    
    var body: some View {
        VStack(spacing: compact ? 18 : 22) {
            Image("LogoApp")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: AuthPalette.accent.opacity(0.52), radius: 28, x: 0, y: 14)
            .authLiquidGlass(tint: AuthPalette.accent.opacity(0.35), cornerRadius: 26, interactive: false)
            
            VStack(spacing: 8) {
                Text("Jigap")
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

struct AuthTextField: View {
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

struct AuthSecureField: View {
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

struct AuthPrimaryButton: View {
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

struct AuthBackground: View {
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

#Preview("Login") {
    OnBoardingView()
        .environmentObject(FinancialStore())
}
