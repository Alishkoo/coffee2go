//
//  MainView.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 10.05.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Coffee2Go")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color(UIColor(red: 0.33, green: 0.2, blue: 0.08, alpha: 1.0)))
            
            Image("coffee_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Button(action: {
                router.navigateTo(.map)
            }) {
                HStack {
                    Image(systemName: "map")
                    Text("Найти кофейни")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color(UIColor(red: 0.33, green: 0.2, blue: 0.08, alpha: 1.0)))
                .cornerRadius(15)
            }
            
            Button(action: {
                router.navigateTo(.game, backButtonMode: .show)
            }) {
                HStack {
                    Image(systemName: "gamecontroller")
                    Text("Игровой режим")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color.green)
                .cornerRadius(15)
            }
            
            Button(action: {
                router.navigateTo(.login, backButtonMode: .custom(title: "anuar lox"))
            }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Настройки")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 250, height: 50)
                .background(Color.gray)
                .cornerRadius(15)
            }
        }
        .padding()
        .navigationTitle("Coffee2Go")
        .navigationBarHidden(true)
    }
}
