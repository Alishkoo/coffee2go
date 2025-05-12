//
//  UserDefaultsManager.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private init() {}
    
    
    private enum Keys {
        static let isUserLoggedIn = "isUserLoggedIn"
        static let userId = "userId"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let userPhotoURL = "userPhotoURL"
        static let lastLoginDate = "lastLoginDate"
    }
    
    
    func setUserLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: Keys.isUserLoggedIn)
    }
    
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.isUserLoggedIn)
    }
    
    
    func saveUserData(id: String, email: String, name: String? = nil, photoURL: String? = nil) {
        UserDefaults.standard.set(id, forKey: Keys.userId)
        UserDefaults.standard.set(email, forKey: Keys.userEmail)
        
        if let name = name {
            UserDefaults.standard.set(name, forKey: Keys.userName)
        }
        
        if let photoURL = photoURL {
            UserDefaults.standard.set(photoURL, forKey: Keys.userPhotoURL)
        }
        
        UserDefaults.standard.set(Date(), forKey: Keys.lastLoginDate)
 
        setUserLoggedIn(true)
    }
    
    func getUserData() -> (id: String, email: String, name: String?, photoURL: String?, lastLoginDate: Date?)? {
        guard let userId = UserDefaults.standard.string(forKey: Keys.userId),
              let userEmail = UserDefaults.standard.string(forKey: Keys.userEmail) else {
            return nil
        }
        
        let userName = UserDefaults.standard.string(forKey: Keys.userName)
        let userPhotoURL = UserDefaults.standard.string(forKey: Keys.userPhotoURL)
        let lastLoginDate = UserDefaults.standard.object(forKey: Keys.lastLoginDate) as? Date
        
        return (id: userId, email: userEmail, name: userName, photoURL: userPhotoURL, lastLoginDate: lastLoginDate)
    }
    
    func updateUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: Keys.userName)
    }
    
    func updateUserPhotoURL(_ photoURL: String) {
        UserDefaults.standard.set(photoURL, forKey: Keys.userPhotoURL)
    }
    
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: Keys.userId)
        UserDefaults.standard.removeObject(forKey: Keys.userEmail)
        UserDefaults.standard.removeObject(forKey: Keys.userName)
        UserDefaults.standard.removeObject(forKey: Keys.userPhotoURL)
        UserDefaults.standard.removeObject(forKey: Keys.lastLoginDate)
        
        setUserLoggedIn(false)
    }
}
