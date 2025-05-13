//
//  CoffeeDetailView.swift
//  coffee2go
//
//  Created by Камила Багдат on 11.05.2025.
//

import SwiftUI

struct SyrupSelectionView: View {
    @ObservedObject var viewModel: CoffeeDetailViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Syrup")
                .foregroundColor(.white)
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.availableSyrups) { syrup in
                    Button(action: {
                        viewModel.toggleSyrup(syrup)
                    }) {
                        Image(uiImage: UIImage(named: syrup.iconName) ?? UIImage(systemName: syrup.iconName)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding()
                            .frame(width: 100, height: 150)
                            .background(
                                viewModel.coffee.selectedSyrups.contains(syrup)
                                ? Color.beige
                                : Color.pochtiWhite
                            )
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                }
            }
        }
    }
}


struct MilkSelectionView: View {
    @ObservedObject var viewModel: CoffeeDetailViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("Alternative Milk")
                .foregroundColor(.white)
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.availableMilks) { milk in
                    Button(action: {
                        viewModel.selectMilk(milk)
                    }) {
                        Image(uiImage: UIImage(named: milk.iconName) ?? UIImage(systemName: milk.iconName)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding()
                            .frame(width: 100, height: 150)
                            .background(
                                viewModel.coffee.selectedMilk == milk
                                ? Color.beige
                                : Color.pochtiWhite
                            )
                            .cornerRadius(24)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                }
            }
        }
    }
}


struct CoffeeView: View {
    @ObservedObject var viewModel: CoffeeDetailViewModel
    @EnvironmentObject var router: AppRouter
    
    init(viewModel: CoffeeDetailViewModel = CoffeeDetailViewModel()) {
        self.viewModel = viewModel
    }
    
    private func getImageName() -> String {
        let coffeeName = viewModel.coffee.name.lowercased()
    
        switch coffeeName {
        case "латте":
            return "latte"
        case "капучино":
            return "cappuccino"
        case "фрапучино":
            return "frappuccino"
        case "матча":
            return "matcha"
        case "горячий шоколад":
            return "hotchoco"
        case "раф":
            return "raf"
        default:
            return "latte"
        }
    }
    
    private func addToOrder() {
        let order = CoffeeOrder(
            name: viewModel.coffee.name,
            size: viewModel.coffee.selectedSize,
            price: viewModel.coffee.price,
            imageName: getImageName()
        )
        
        let orderViewModel = OrderViewModel.shared
        orderViewModel.addToOrder(order)
        
        router.navigateTo(.order, backButtonMode: .show)
    }
    
    
    var body: some View {
        ZStack {
            Color.lighterBrown.ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    Image(getImageName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                    
                    Rectangle()
                        .fill(Color.lighterBrown)
                        .frame(height: 40)
                        .offset(y: 60)
                    
                    
                    Text(viewModel.coffee.name)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.pochtiWhite)
                        .offset(y: 65)
                }
                
                SyrupSelectionView(viewModel: viewModel)
                MilkSelectionView(viewModel: viewModel)
                
                Spacer()
                
                HStack {
                    HStack(spacing: 16) {
                        ForEach(CoffeeSize.allCases, id: \.self) { size in
                            Button(action: {
                                viewModel.selectSize(size)
                            }) {
                                Text(size.rawValue)
                                    .fontWeight(.bold)
                                    .frame(width: 50, height: 50)
                                    .background(viewModel.coffee.selectedSize == size ? Color.pochtiWhite : Color.lighterBrown.opacity(0.7))
                                    .clipShape(Circle())
                                    .foregroundColor(viewModel.coffee.selectedSize == size ? Color.darkBrown : Color.pochtiWhite.opacity(0.7))
                            }
                        }
                    }
                    
                    
                    Button(action: {
                        addToOrder()
                    }){
                        Text("\(viewModel.coffee.price) ₸")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.pochtiWhite)
                            .cornerRadius(20)
                            .foregroundColor(.darkBrown)
                            .fontWeight(.bold)
                    }
                    .background(Color.lighterBrown)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    }
                
            }
            .padding()
            
        }
    }
}


#Preview {
    CoffeeView()
}
