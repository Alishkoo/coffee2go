//
//  OrderCompleteView.swift
//  coffee2go
//
//  Created by Камила Багдат on 13.05.2025.
//

import Foundation
import SwiftUI

struct OrderCompleteView: View {
    @StateObject private var viewModel = OrderCompleteViewModel()
    @EnvironmentObject var router: AppRouter

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color.green)
                .shadow(radius: 10)

            Text("Ваш заказ готов!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 8)

            Text(viewModel.completionMessage)
                .font(.system(size: 16))
                .foregroundColor(Color(white: 0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                router.navigateTo(.map,backButtonMode: .hide)
            }) {
                Text("На главную")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 165/255, green: 103/255, blue: 63/255))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 4)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
        .background(Color(hex: "412A1D").ignoresSafeArea())
    }
}


#Preview {
    OrderCompleteView()
}

