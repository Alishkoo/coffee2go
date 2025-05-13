//
//  CoffeeMenuModel.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 13.05.2025.
//

import Foundation

struct CoffeeItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
    let imageName: String
    let category: CoffeeCategory
    let description: String
    
    static func getImageName(_ baseName: String) -> String {
        return baseName.lowercased()
    }
}

enum CoffeeCategory: String, CaseIterable {
    case hotDrinks = "hot_drinks"
    case coldDrinks = "cold_drinks"
    case specialties = "specialties"
    
    var displayName: String {
        switch self {
        case .hotDrinks:
            return "Горячие напитки"
        case .coldDrinks:
            return "Холодные напитки"
        case .specialties:
            return "Фирменные"
        }
    }
}
