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
    let profileImageUrl: String
    let isRead: Bool
    let createAt: Timestamp
    
    var partnerUser: User?
    var partnerUser1: User?
    var messageProfileImageUrl: String = ""
    
    init(dic: [String: Any]){
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.isRead = dic["isRead"] as? Bool ?? false
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        
    }
}
