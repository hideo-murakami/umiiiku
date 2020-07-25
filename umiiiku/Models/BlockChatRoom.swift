//
//  BlockChatRoom.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/21.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class BlockChatRoom {
    
    let chatroomDocId: String
    let createAt: Timestamp
    let fromName: String
    let fromUid: String
    
    var documentId : String?
    
    init(dic: [String: Any]) {
        
        self.chatroomDocId = dic["chatroomDocId"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.fromName = dic["fromName"] as? String ?? ""
        self.fromUid = dic["fromUid"] as? String ?? ""
        
    }
    
}
