//
//  Umiiiker.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/08/24.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class Umiiiker{
    
    let email: String
    let username: String
    let umiiikerId: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.umiiikerId = dic["umiiikerId"] as? String ?? ""
        
    }
    
}
