//
//  FirebaseAuthService.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//

import Foundation
import FirebaseAuth


final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init(){ }
    
    
    func getAuthenticatedUser() throws -> UserModel{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return  UserModel(user: user)
    }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> UserModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let result = UserModel(user: authDataResult.user)
    
        return result
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> UserModel{
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let result = UserModel(user: authDataResult.user)
        print(authDataResult.user)
        return result
    }
    
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
}
