//
//  User.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/13.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class User{
    
    let email: String
    let username: String
    let createAt: Timestamp
    let profileImageUrl: String
    let token: String
    let chatCount: Int
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.token = dic["token"] as? String ?? ""
        self.chatCount = dic["chatCount"] as? Int ?? 0
        
    }
    
}
