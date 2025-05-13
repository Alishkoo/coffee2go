//
//  CoffeeMenuViewModel.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 13.05.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CoffeeMenuViewModel: ObservableObject {
    @Published var coffeeItems: [CoffeeItem] = []
    @Published var selectedCategory: CoffeeCategory = .hotDrinks
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var featuredCoffee: CoffeeItem?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCoffeeItems()
        
        $selectedCategory
            .sink { [weak self] category in
                self?.filterCoffeeItems(by: category)
            }
            .store(in: &cancellables)
    }
    
    func loadCoffeeItems() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.coffeeItems = self.getMockCoffeeItems()
            
            self.featuredCoffee = self.coffeeItems.first(where: { $0.name == "Латте" })
            
            self.isLoading = false
        }
    }
    
    private func filterCoffeeItems(by category: CoffeeCategory) {
        //TODO: фильтрация
    }
    
    func selectCategory(_ category: CoffeeCategory) {
        selectedCategory = category
    }
    
    func selectCoffee(_ coffee: CoffeeItem) {
        let coffeeDetail = CoffeeDetailModel(
            name: coffee.name,
            basePrice: coffee.price,
            selectedSize: .medium
        )
        
        // Здесь обычно была бы навигация к детальному экрану
    }
    
    func getCoffeeItemsByCategory(_ category: CoffeeCategory) -> [CoffeeItem] {
        return coffeeItems.filter { $0.category == category }
    }
    
    private func getMockCoffeeItems() -> [CoffeeItem] {
        return [
            CoffeeItem(
                name: "Латте",
                price: 1200, 
                imageName: "latte", 
                category: .hotDrinks, 
                description: "Классический латте с нежной молочной пенкой"
            ),
            CoffeeItem(
                name: "Капучино",
                price: 1100, 
                imageName: "cappuccino", 
                category: .hotDrinks, 
                description: "Эспрессо с молоком и плотной молочной пенкой"
            ),
            CoffeeItem(
                name: "Горячий шоколад",
                price: 1300, 
                imageName: "hotchoco", 
                category: .hotDrinks, 
                description: "Насыщенный горячий шоколад с молоком"
            ),
            CoffeeItem(
                name: "Раф",
                price: 1400, 
                imageName: "raf", 
                category: .hotDrinks, 
                description: "Эспрессо с ванильным сахаром и взбитыми сливками"
            ),
            

            CoffeeItem(
                name: "Фрапучино",
                price: 1500, 
                imageName: "frappuccino", 
                category: .coldDrinks, 
                description: "Освежающий холодный кофейный напиток с молоком и льдом"
            ),
            CoffeeItem(
                name: "Айс Латте",
                price: 1300, 
                imageName: "latte", 
                category: .coldDrinks, 
                description: "Охлажденный латте со льдом"
            ),
            
            CoffeeItem(
                name: "Матча",
                price: 1600, 
                imageName: "matcha", 
                category: .specialties, 
                description: "Напиток из порошка зеленого чая матча с молоком"
            ),
            CoffeeItem(
                name: "Раф карамельный",
                price: 1600, 
                imageName: "raf", 
                category: .specialties, 
                description: "Фирменный раф с добавлением карамельного сиропа"
            )
        ]
    }
}
