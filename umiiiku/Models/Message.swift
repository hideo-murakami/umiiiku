//
//  Message.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/18.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    let name: String
    let message: String
    let uid: String
    let createAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]){
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
    
        
    }

    
}
