//
//  CoffeeDetailView.swift
//  coffee2go
//
//  Created by Камила Багдат on 11.05.2025.
//

import SwiftUI

struct SyrupSelectionView: View {
    @ObservedObject var viewModel: CoffeeDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Syrup")
                .foregroundColor(.white)
                .font(.headline)

            HStack {
                ForEach(viewModel.availableSyrups) { syrup in
                    Button(action: {
                        viewModel.toggleSyrup(syrup)
                    }) {
                        if UIImage(named: syrup.iconName) != nil {
                            Image(syrup.iconName)
                                .resizable()
                                .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: syrup.iconName)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding()
                    .background(viewModel.coffee.selectedSyrups.contains(syrup) ? Color.beige : Color.lighterBrown.opacity(0.8))
                    .clipShape(Circle())
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct MilkSelectionView: View {
    @ObservedObject var viewModel: CoffeeDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Alternative Milk")
                .foregroundColor(.white)
                .font(.headline)

            HStack {
                ForEach(viewModel.availableMilks) { milk in
                    Button(action: {
                        viewModel.selectMilk(milk)
                    }) {
                        if UIImage(named: milk.iconName) != nil {
                            Image(milk.iconName)
                                .resizable()
                                .frame(width: 50, height: 50)
                        } else {
                            Image(systemName: milk.iconName)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding()
                    .background(viewModel.coffee.selectedMilk == milk ? Color.beige : Color.lighterBrown.opacity(0.8))
                    .clipShape(Circle())
                    .foregroundColor(.white)
                }
            }
        }
    }
}


struct CoffeeView: View {
    @StateObject private var viewModel = CoffeeDetailViewModel()
    @EnvironmentObject var router: AppRouter

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 30) {
                Image(.capuccino)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.white)

                Text(viewModel.coffee.name)
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                
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
                                    .fontWeight(.medium)
                                    .frame(width: 40, height: 40)
                                    .background(viewModel.coffee.selectedSize == size ? Color.pochtiWhite : Color.lighterBrown.opacity(0.7))
                                    .clipShape(Circle())
                                    .foregroundColor(viewModel.coffee.selectedSize == size ? Color.darkBrown : Color.pochtiWhite.opacity(0.7))
                            }
                        }
                    }


                    Text("\(viewModel.coffee.price) ₸")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.pochtiWhite)
                        .cornerRadius(20)
                        .foregroundColor(.darkBrown)
                        .fontWeight(.bold)
                }
                .background(Color.esheOdinBrown)
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .padding()
            
        }
    }
}


#Preview {
    CoffeeView()
}
