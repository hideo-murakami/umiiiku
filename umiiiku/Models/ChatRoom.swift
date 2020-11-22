//
//  ChatRoom.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/16.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class ChatRoom {
    
    let blockStatus: String
    let latestMessageId: String
    let members: [String]
    let createAt: Timestamp
    
    var latestMessage : Message?
    var lastSpeakerUid : String?
    var lastSpeakerCount : Int = 0
    var documentId : String?
    var partnerUser : User?
    var partnerUser1 : User?
    var unReadCount: Int = 0
    
    init(dic: [String: Any]) {
        
        self.blockStatus = dic["blockStatus"] as? String ?? ""
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
    }
}
