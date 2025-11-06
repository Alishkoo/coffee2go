//
//  AuthViewModel.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//  Hardened: move sensitive session id to Keychain, validate inputs, clear password, better error flow.
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

   
    private let sessionKey = "com.coffee2go.sessionID"

    init() {
        checkLoginStatus()
    }

    
    func checkLoginStatus() {
        if let _ = KeychainHelper.read(for: sessionKey) {
            isSignedIn = true
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
            email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        } else {
            isSignedIn = false
            userName = ""
            email = ""
        }
    }

    
    func signUp() async throws {
        guard isValidEmail(email) else {
            showError("Invalid email format")
            return
        }
        guard password.count >= 8 else {
            showError("Password must be at least 8 characters")
            return
        }

        do {
            let user = try await AuthenticationManager.shared.createUser(email: email, password: password)

            let sessionIdentifier = user.uid
            let saved = KeychainHelper.save(sessionIdentifier, for: sessionKey)
            if !saved {
                showError("Failed to store session securely")
                return
            }

            UserDefaults.standard.set(true, forKey: "isSignedIn")
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")

            password = ""

            isSignedIn = true
        } catch {
            showError("Sign up failed: \(error.localizedDescription)")
        }
    }

    /// Sign in: validate, call auth, store session id in Keychain, clear password
    func signIn() async throws {
        guard isValidEmail(email) else {
            showError("Invalid email format")
            return
        }
        guard !password.isEmpty else {
            showError("Password required")
            return
        }

        do {
            let user = try await AuthenticationManager.shared.signIn(email: email, password: password)

            // Store uid (or server session token) securely in Keychain
            let sessionIdentifier = user.uid
            let saved = KeychainHelper.save(sessionIdentifier, for: sessionKey)
            if !saved {
                showError("Failed to store session securely")
                return
            }


            UserDefaults.standard.set(true, forKey: "isSignedIn")
            UserDefaults.standard.set(userName, forKey: "userName")
            UserDefaults.standard.set(email, forKey: "userEmail")

         
            password = ""

            isSignedIn = true
        } catch {
            showError("Sign in failed: \(error.localizedDescription)")
        }
    }

   
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
        } catch {
            showError("Sign out failed")
        }

        KeychainHelper.delete(for: sessionKey)
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        isSignedIn = false
        userName = ""
        email = ""
    }

    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }

    // Basic email regex validation (client-side only)
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(email.startIndex..<email.endIndex, in: email)
        return re?.firstMatch(in: email, options: [], range: range) != nil
    }
}
