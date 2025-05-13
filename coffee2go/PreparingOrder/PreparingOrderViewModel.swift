//
//  PreparingOrderViewModel.swift
//  coffee2go
//
//  Created by Камила Багдат on 13.05.2025.
//

import Foundation

class PreparingOrderViewModel: ObservableObject {
    @Published var isPlayingGame = false

    @MainActor func playGame() {
        isPlayingGame = true
        AppRouter.shared.navigateTo(.game)
    }

    @MainActor func goHome() {
        AppRouter.shared.navigateTo(.map)
    }
}
