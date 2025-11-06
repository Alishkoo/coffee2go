//
//  OrderComnpleteViewModel.swift
//  coffee2go
//
//  Created by Камила Багдат on 13.05.2025.
//

import Foundation
import SwiftUI

class OrderCompleteViewModel: ObservableObject {
    @Published var bonusEarned: Bool = true

    var completionMessage: String {
        bonusEarned
        ? "Ваши бонусы за игру были зачислены ☕️"
        : "Спасибо за заказ в Coffee2GO!"
    }

    @MainActor func goHomeAction() {
        AppRouter.shared.navigateTo(.map)
    }
}

