//
//  Kantong.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import Foundation
import SwiftUI

struct Kantong: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var balance: Double
    var allocationPercentage: Int
    var iconName: String
    var themeColor: Color
}
