//
//  MessageID.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/08/15.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class MessageID {
    
    let messageID: String
    let createAt: Timestamp
    
    init(dic: [String: Any]){
        self.messageID = dic["messageID"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        
    }
}
