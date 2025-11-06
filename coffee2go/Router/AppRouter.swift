//
//  AppRouter.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//

import UIKit
import SwiftUI
import YandexMapsMobile


enum BackButtonMode {
    case show
    case hide
    case custom(title: String)
}


enum AppScreen {
    case main
    case map
    case coffeeDetail(coffee: CoffeeDetailModel)
    case order
    case coffeeMenu
    case game
    case settings
    case login
    case register
    case preparingOrder
    case orderComplete
}

class AppRouter: ObservableObject {
    static let shared = AppRouter()
    
    private var navigationController: UINavigationController?
    
    private init() {}
    
    
    @MainActor func setup(with window: UIWindow) {
        
//        UserDefaultsManager.shared.clearUserData()
        
        let isUserLoggedIn = UserDefaultsManager.shared.isUserLoggedIn()
        let rootViewController: UIViewController
        
        if isUserLoggedIn {
            let mapVC = MapViewController()
            rootViewController = mapVC
        } else {
            let loginView = LoginView()
                .environmentObject(AuthViewModel())
            rootViewController = UIHostingController(rootView: loginView.environmentObject(self))
        }
        
     
        let navController = UINavigationController(rootViewController: rootViewController)
        
  
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        
     
        navController.isNavigationBarHidden = true
        
      
        navigationController = navController
        
     
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
    
 
    @MainActor func navigateTo(_ screen: AppScreen, backButtonMode: BackButtonMode = .show, animated: Bool = true) {
        guard let navigationController = navigationController else {
            print("Ошибка: навигационный контроллер не инициализирован")
            return
        }
        
       
        let viewController: UIViewController
        
        switch screen {
        case .main:
            let mainView = MainView()
            viewController = UIHostingController(rootView: mainView.environmentObject(self))
            viewController.title = "Coffee2Go"
            viewController.navigationController?.isNavigationBarHidden = true
            
        case .map:
            viewController = MapViewController()
            
        case .coffeeMenu:
                let coffeeMenuView = CoffeeMenuView()
                viewController = UIHostingController(rootView: coffeeMenuView.environmentObject(self))
                navigationController.isNavigationBarHidden = false
        
        case .coffeeDetail(let coffee):
                let coffeeViewModel = CoffeeDetailViewModel(coffee: coffee)
                
                let coffeeDetailView = CoffeeView(viewModel: coffeeViewModel)
                    .environmentObject(self)
                
                let hostController = UIHostingController(rootView: coffeeDetailView)
                
                viewController = hostController
                navigationController.isNavigationBarHidden = false
            
        case .order:
                let orderView = OrderView()
                    .environmentObject(self)
                
                viewController = UIHostingController(rootView: orderView)
                navigationController.isNavigationBarHidden = false
            
        case .orderComplete:
            let orderCompleteView = OrderCompleteView()
                .environmentObject(self)
            
            viewController = UIHostingController(rootView: orderCompleteView)
            
            
        case .preparingOrder:
            let preparingOrderView = PreparingOrderView()
                .environmentObject(self)
            
            viewController = UIHostingController(rootView: preparingOrderView)
            navigationController.isNavigationBarHidden = true
            
        case .login:
            let loginView = LoginView()
                .environmentObject(AuthViewModel())
            viewController = UIHostingController(rootView: loginView.environmentObject(self))
            navigationController.isNavigationBarHidden = true
            
        case .register:
            let registerView = RegisterView()
                .environmentObject(AuthViewModel())
            viewController = UIHostingController(rootView: registerView.environmentObject(self))
            
        case .game:
            let gameVC = GameViewController()
            viewController = gameVC
            navigationController.isNavigationBarHidden = false
            
        case .settings:
            viewController = createSettingsVC()
            navigationController.isNavigationBarHidden = false
        }
        
        configureBackButton(for: viewController, mode: backButtonMode)
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    private func configureBackButton(for viewController: UIViewController, mode: BackButtonMode) {
        switch mode {
        case .show:
            viewController.navigationItem.hidesBackButton = false
            viewController.navigationItem.leftBarButtonItem = nil
            
        case .hide:
            viewController.navigationItem.hidesBackButton = true
            
        case .custom(let title):
            viewController.navigationItem.hidesBackButton = false
            let backButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(handleBackAction))
            viewController.navigationItem.leftBarButtonItem = backButton
        }
    }
    
    @objc private func handleBackAction() {
        goBack()
    }
    

    func goBack(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
        
        if navigationController?.topViewController === navigationController?.viewControllers.first {
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    func goToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
        navigationController?.isNavigationBarHidden = true
    }
    

    @MainActor func presentModally(_ screen: AppScreen, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = navigationController else {
            print("Ошибка: навигационный контроллер не инициализирован")
            return
        }
        
        let viewController: UIViewController
        
        switch screen {
        case .main:
            let mainView = MainView()
            viewController = UIHostingController(rootView: mainView.environmentObject(self))
            
        case .map:
            viewController = MapViewController()
            
        case .coffeeMenu:
                let coffeeMenuView = CoffeeMenuView()
                viewController = UIHostingController(rootView: coffeeMenuView.environmentObject(self))
                navigationController.isNavigationBarHidden = false
            
        case .order:
                let orderView = OrderView()
                    .environmentObject(self)
                
                viewController = UIHostingController(rootView: orderView)
                navigationController.isNavigationBarHidden = false
            
        case .preparingOrder:
            let preparingOrderView = PreparingOrderView()
                .environmentObject(self)
            
            viewController = UIHostingController(rootView: preparingOrderView)
            navigationController.isNavigationBarHidden = true
            
        case .orderComplete:
            let orderCompleteView = OrderCompleteView()
                .environmentObject(self)
            
            viewController = UIHostingController(rootView: orderCompleteView)
            
        case .coffeeDetail:
            let coffeeDetailView = CoffeeView()
            viewController = UIHostingController(rootView: coffeeDetailView.environmentObject(self))
            
        case .game:
            let gameVC = GameViewController()
            viewController = gameVC
            
        case .settings:
            viewController = createSettingsVC()
            
        case .login:
            let loginView = LoginView()
                .environmentObject(AuthViewModel())
            viewController = UIHostingController(rootView: loginView.environmentObject(self))
            navigationController.isNavigationBarHidden = true
            
        case .register:
            let registerView = RegisterView()
                .environmentObject(AuthViewModel())
            viewController = UIHostingController(rootView: registerView.environmentObject(self))
        }
        
        navigationController.present(viewController, animated: animated, completion: completion)
    }

    func dismissModal(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }
    

    private func createSettingsVC() -> UIViewController {
        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .white
        settingsVC.title = "Настройки"
        
        let label = UILabel()
        label.text = "Настройки приложения"
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        settingsVC.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: settingsVC.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: settingsVC.view.centerYAnchor)
        ])
        
        return settingsVC
    }
}
