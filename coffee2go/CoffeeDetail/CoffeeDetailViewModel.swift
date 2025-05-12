//
//  CoffeeDetailViewModel.swift
//  coffee2go
//
//  Created by Камила Багдат on 11.05.2025.
//

import Foundation

class CoffeeDetailViewModel: ObservableObject {
    @Published var coffee = CoffeeDetailModel(
        name: "Latte",
        basePrice: 1200,
        selectedSize: .small
    )

    let availableSyrups = [
        AddOn(name: "Vanilla", price: 100, iconName: "Vanilla"),
        AddOn(name: "Caramel", price: 100, iconName: "Caramel"),
        AddOn(name: "Salted Caramel", price: 100, iconName: "SaltedCaramel")
    ]

    let availableMilks = [
        AddOn(name: "Almond", price: 200, iconName: "AlmondMilk"),
        AddOn(name: "Coconut", price: 200, iconName: "CoconutMilk"),
        AddOn(name: "Soy", price: 200, iconName: "SoyMilk")
    ]

    func toggleSyrup(_ syrup: AddOn) {
        if coffee.selectedSyrups.contains(syrup) {
            coffee.selectedSyrups.remove(syrup)
        } else {
            coffee.selectedSyrups.insert(syrup)
        }
    }

    func selectMilk(_ milk: AddOn) {
        coffee.selectedMilk = (coffee.selectedMilk == milk) ? nil : milk
    }

    func selectSize(_ size: CoffeeSize) {
        coffee.selectedSize = size
    }
}
