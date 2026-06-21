//
//  AddWalletView.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 17/06/26.
//

import SwiftUI

struct AddWalletView: View {
    @ObservedObject var store: FinancialStore
    @Environment(\.dismiss) private var dismiss
    
    // State lokal form input
    @State private var walletName: String = ""
    @State private var initialBalance: String = ""
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var selectedColor: Color = Color(red: 1.0, green: 0.18, blue: 0.48)
    
    // Konstanta Visual Properti
    private let darkBackground = Color(red: 0.045, green: 0.005, blue: 0.055)
    private let availableIcons = ["creditcard.fill", "banknote.fill", "cart.fill", "bag.fill", "heart.fill", "car.fill"]
    private let availableColors: [Color] = [
        Color(red: 1.0, green: 0.18, blue: 0.48), // Accent Pink
        Color(red: 0.18, green: 0.92, blue: 0.88), // Cyan
        .purple, .orange, .green, .blue
    ]
    
    private var balanceDoubleValue: Double {
        Double(initialBalance) ?? 0.0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                darkBackground
                    .ignoresSafeArea()
                
                LinearGradient(
                    colors: [Color(red: 0.2, green: 0.02, blue: 0.18).opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Kartu Preview Dinamis dari File Komponen
                        WalletPreviewCard(
                            selectedIcon: selectedIcon,
                            selectedColor: selectedColor,
                            walletName: walletName,
                            initialBalance: initialBalance
                        )
                        
                        // Form Kontainer Fields
                        VStack(alignment: .leading, spacing: 20) {
                            // Input Nama Kantong
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kantong Name")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.white.opacity(0.52))
                                
                                TextField("e.g., Coffee, Tabungan", text: $walletName)
                                    .font(.body)
                                    .padding()
                                    .background(.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .foregroundStyle(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.12), lineWidth: 1)
                                    )
                            }
                            
                            // Input Saldo Awal
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Initial Balance (Rp)")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.white.opacity(0.52))
                                
                                TextField("0", text: $initialBalance)
                                    .keyboardType(.numberPad)
                                    .font(.system(.body, design: .rounded))
                                    .padding()
                                    .background(.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .foregroundStyle(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.12), lineWidth: 1)
                                    )
                            }
                            
                            // Komponen Pemilih Ikon dari File Komponen
                            IconPickerSection(
                                availableIcons: availableIcons,
                                selectedIcon: $selectedIcon,
                                selectedColor: selectedColor
                            )
                            
                            // Komponen Pemilih Warna dari File Komponen
                            ColorPickerSection(
                                availableColors: availableColors,
                                selectedColor: $selectedColor
                            )
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(24)
                        
                        // Tombol Aksi Simpan
                        Button(action: saveWalletAction) {
                            Text("Create New Kantong")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(colors: [selectedColor, selectedColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: selectedColor.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .disabled(walletName.isEmpty)
                        .opacity(walletName.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Add New Kantong")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }
    
    // MARK: - Logic Action
    private func saveWalletAction() {
        store.addKantong(
            name: walletName,
            balance: balanceDoubleValue,
            iconName: selectedIcon,
            themeColor: selectedColor
        )
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    AddWalletView(store: FinancialStore())
        .preferredColorScheme(.dark)
}
