//
//  AuthViewModel.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//


import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var isSignedIn = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var userName: String = ""
    @Published var email = ""
    @Published var password = ""
    
    init(){
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
           isSignedIn = UserDefaultsManager.shared.isUserLoggedIn()
           
           if isSignedIn, let userData = UserDefaultsManager.shared.getUserData() {
               self.userName = userData.name ?? ""
               self.email = userData.email
           }
       }
    
    func signUp() async throws {
        let user = try await AuthenticationManager.shared.createUser(email: email, password: password)
        
        UserDefaultsManager.shared.saveUserData(
            id: user.uid,
            email: email,
            name: userName
        )
    }
    
    func signIn() async throws {
        let user = try await AuthenticationManager.shared.signIn(email: email, password: password)
        
        UserDefaultsManager.shared.saveUserData(
            id: user.uid,
            email: email,
            name: user.uid
        )
    }
    
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
        } catch {
            print("error")
        }
        isSignedIn = false
        userName = ""
    }

    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
}
