//
//  Transaction.swift
//  Jigap
//
//  Created by Windy Claudia Napitupulu on 14/06/26.
//

import Foundation

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isIncome: Bool
    var sourceKantongId: UUID
}
