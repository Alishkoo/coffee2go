//
//  PreparingOrderView.swift
//  coffee2go
//
//  Created by Камила Багдат on 13.05.2025.
//

import SwiftUI

struct PreparingOrderView: View {
    @StateObject private var viewModel = PreparingOrderViewModel()
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
            }
            .padding()

            Spacer()

            Text("Your order is")
                .foregroundColor(.white.opacity(0.7))
                .font(.title3)

            Text("ГОТОВИТЬСЯ...")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Image(.fourelements)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 160)
                .cornerRadius(12)

            VStack(spacing: 4) {
                Text("Пока вы ждете сыграйте в игру")
                    .foregroundColor(.orange)
                Text("и получите бонусы")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .multilineTextAlignment(.center)
            .font(.footnote)

            Button(action: {
                viewModel.playGame()
            }) {
                Text("play")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)

            Button(action: {
                viewModel.goHome()
            }) {
                Text("go home")
                
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
            }

            Spacer()
        }
        .padding()
        .background(Color(hex: "#412a1d").ignoresSafeArea())
    }
}

#Preview {
    PreparingOrderView()
}
