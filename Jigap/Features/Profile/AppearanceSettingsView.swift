//
//  AppearanceSettingsView.swift
//  Jigap
//

import SwiftUI

struct AppearanceSettingsView: View {
    @Binding var appearanceMode: String
    @Binding var isHighContrastEnabled: Bool
    let accentColor: Color
    
    var body: some View {
        ProfileDetailContainer(title: "Appearance") {
            VStack(alignment: .leading, spacing: 18) {
                Text("Theme")
                    .profileDetailTitle()
                
                Picker("Theme", selection: $appearanceMode) {
                    ForEach(AppAppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .tint(accentColor)
                
                Toggle(isOn: $isHighContrastEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("High Contrast")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        Text("Increase text and border contrast")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.70))
                    }
                }
                .tint(accentColor)
                .padding(16)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Text("Jigap follows Dynamic Type from iOS Settings. Use Settings > Accessibility > Display & Text Size to make fonts larger across the app.")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
