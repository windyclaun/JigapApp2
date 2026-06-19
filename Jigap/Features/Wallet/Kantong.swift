//
//  Kantong.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import Foundation
import SwiftUI

struct Kantong: Identifiable, Hashable, Codable { // <-- Tambahkan Codable di sini
    var id = UUID()
    var name: String
    var balance: Double
    var allocationPercentage: Int
    var iconName: String
    
    // Properti warna yang disimpan sebagai komponen RGB agar mematuhi Codable
    private var redComponent: Double
    private var greenComponent: Double
    private var blueComponent: Double
    
    // Computed property untuk memanggil Color asli di SwiftUI View kamu
    var themeColor: Color {
        Color(red: redComponent, green: greenComponent, blue: blueComponent)
    }
    
    // Custom initializer agar inisialisasi Color di Dummy Data kamu tidak pecah/eror
    init(id: UUID = UUID(), name: String, balance: Double, allocationPercentage: Int, iconName: String, themeColor: Color) {
        self.id = id
        self.name = name
        self.balance = balance
        self.allocationPercentage = allocationPercentage
        self.iconName = iconName
        
        // Ekstrak komponen warna dari SwiftUI Color
        let uiColor = UIColor(themeColor)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.redComponent = Double(r)
        self.greenComponent = Double(g)
        self.blueComponent = Double(b)
    }
}
