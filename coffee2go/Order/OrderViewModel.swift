//
//  OrderViewModel.swift
//  coffee2go
//
//  Created by Камила Багдат on 12.05.2025.
//

import Foundation
import SwiftUI

final class OrderViewModel: ObservableObject {
    static let shared = OrderViewModel()
    
    @Published var orders: [CoffeeOrder] = []
    @Published var recommendations: [CoffeeOrder] = [
        CoffeeOrder(name: "Сappuccino", size: .medium, price: 1300, imageName: "cappuccino"),
        CoffeeOrder(name: "Frapuccino", size: .medium, price: 1500, imageName: "frappuccino"),
        CoffeeOrder(name: "Matcha Chai", size: .medium, price: 1200, imageName: "matcha"),
        CoffeeOrder(name: "Hot Chocolate", size: .medium, price: 1200, imageName: "hotchoco"),
        CoffeeOrder(name: "Raf", size: .medium, price: 1300, imageName: "raf")
    ]

    var total: Int {
        orders.reduce(0) { $0 + ($1.price * $1.quantity) }
    }

    func addToOrder(_ item: CoffeeOrder) {
        if let index = orders.firstIndex(where: { $0.name == item.name && $0.size == item.size }) {
            orders[index].quantity += 1
        } else {
            orders.append(item)
        }
    }
    
    func increaseQuantity(of item: CoffeeOrder) {
        guard let index = orders.firstIndex(where: { $0.id == item.id }) else { return }
        orders[index].quantity += 1
    }
    
    func decreaseQuantity(of item: CoffeeOrder) {
        guard let index = orders.firstIndex(where: { $0.id == item.id }) else { return }
        if orders[index].quantity > 1 {
            orders[index].quantity -= 1
        } else {
            deleteOrder(item)
        }
    }

    func deleteOrder(_ item: CoffeeOrder) {
        orders.removeAll { $0.id == item.id }
    }
}
