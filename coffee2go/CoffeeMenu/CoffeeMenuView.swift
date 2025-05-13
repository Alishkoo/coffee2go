//
//  CoffeeMenuView.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 13.05.2025.
//

import SwiftUI

struct CoffeeMenuView: View {
    @StateObject private var viewModel = CoffeeMenuViewModel()
    @EnvironmentObject var router: AppRouter
    
    private let backgroundColor = Color(hex: "#412A1D")
    private let cardBackgroundColor = Color(hex: "#BFB19F")
    private let accentColor = Color.white
    private let textColor = Color.white
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                featuredCoffee
                
                categorySelector
                
                coffeeGrid
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .navigationTitle("Меню")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCoffeeItems()
        }
    }
    
    private var featuredCoffee: some View {
        VStack {
            ZStack {
                Image(viewModel.featuredCoffee?.imageName ?? "latte")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding(.top, 40)
                
            }
            
            Text(viewModel.featuredCoffee?.name ?? "Латте")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .padding(.top, 10)
            
            Text("\(viewModel.featuredCoffee?.price ?? 1200) тг")
                .font(.title3)
                .foregroundColor(textColor.opacity(0.8))
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(CoffeeCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category,
                        action: {
                            withAnimation(.easeInOut) {
                                viewModel.selectCategory(category)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var coffeeGrid: some View {
        ScrollView {
            VStack(spacing: 16) {
                let categoryItems = viewModel.getCoffeeItemsByCategory(viewModel.selectedCategory)
                
                if categoryItems.isEmpty {
                    Text("В этой категории пока нет напитков")
                        .foregroundColor(textColor.opacity(0.7))
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(categoryItems) { coffee in
                            coffeeCard(coffee)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let firstItem = categoryItems.first {
                        largeCoffeeCard(firstItem)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func coffeeCard(_ coffee: CoffeeItem) -> some View {
        Button(action: {
            let coffeeDetail = CoffeeDetailModel(
                name: coffee.name,
                basePrice: coffee.price,
                selectedSize: .medium
            )
            router.navigateTo(.coffeeDetail(coffee: coffeeDetail), backButtonMode: .show)
        }) {
            VStack(spacing: 8) {
                Image(coffee.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .padding(.top, 10)
                
                Text(coffee.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("\(coffee.price) тг")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(cardBackgroundColor)
            .cornerRadius(16)
        }
    }
    
    private func largeCoffeeCard(_ coffee: CoffeeItem) -> some View {
        Button(action: {
            let coffeeDetail = CoffeeDetailModel(
                name: coffee.name,
                basePrice: coffee.price,
                selectedSize: .medium
            )
            router.navigateTo(.coffeeDetail(coffee: coffeeDetail), backButtonMode: .show)
        }) {
            HStack(spacing: 16) {
                Image(coffee.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(coffee.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("\(coffee.price) тг")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                }
                .padding(.vertical, 16)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(cardBackgroundColor)
            .cornerRadius(16)
        }
    }
}


private struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
            Button(action: action) {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                        ,
                        alignment: .bottom
                    )
            }
        }
}


