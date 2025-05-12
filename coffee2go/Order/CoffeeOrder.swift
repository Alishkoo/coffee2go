//
//  CoffeeItem.swift
//  coffee2go
//
//  Created by Камила Багдат on 12.05.2025.
//

import Foundation

struct CoffeeOrder: Identifiable {
    let id = UUID()
    let name: String
    let size: CoffeeSize 
    let price: Int
    let imageName: String
    var quantity: Int = 1
}
