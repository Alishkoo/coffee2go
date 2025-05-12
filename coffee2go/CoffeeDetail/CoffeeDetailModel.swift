//
//  CoffeeDetailModel.swift
//  coffee2go
//
//  Created by Камила Багдат on 11.05.2025.
//

import Foundation

struct AddOn: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
    let iconName: String
}

enum CoffeeSize: String, CaseIterable {
    case small = "S"
    case medium = "M"
    case large = "L"
}

struct CoffeeDetailModel: Equatable, Hashable {
    let name: String
    let basePrice: Int
    var selectedSize: CoffeeSize = .small
    var selectedSyrups: Set<AddOn> = []
    var selectedMilk: AddOn?

    var price: Int {
        let sizeMultiplier: Double
        switch selectedSize {
        case .small: sizeMultiplier = 1.0
        case .medium: sizeMultiplier = 1.25
        case .large: sizeMultiplier = 1.5
        }

        let syrupsTotal = selectedSyrups.reduce(0) { $0 + $1.price }
        let milkTotal = selectedMilk?.price ?? 0

        return Int(Double(basePrice) * sizeMultiplier) + syrupsTotal + milkTotal
    }
}

