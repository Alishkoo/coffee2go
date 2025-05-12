//
//  UserModel.swift
//  coffee2go
//
//  Created by Alibek Baisholanov on 12.05.2025.
//


import Foundation
import FirebaseAuth

struct UserModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}
