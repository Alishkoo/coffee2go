//
//  MainView.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 10.05.2025.
//


// на будущее как запускать игру
import SwiftUI

struct MainView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
        Button(action: {
            self.startGame()
        }) {
            Text("Play Game")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        
    }
    
    
    func startGame() {
        // Получаем UIViewController, в котором размещен данный SwiftUI view
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            
            // Создаем GameViewController
            let gameVC = GameViewController()
            
            // Настраиваем полноэкранный режим
            gameVC.modalPresentationStyle = .fullScreen
            
            // Показываем GameViewController
            rootViewController.present(gameVC, animated: true, completion: nil)
        }
    }
}

#Preview {
    MainView()
}
