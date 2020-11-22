//
//  Assistant.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/07.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Assistant{
    
    let email: String
    let username: String
    let assistantId: String
    let profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.assistantId = dic["assistantId"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        
    }
    
}
