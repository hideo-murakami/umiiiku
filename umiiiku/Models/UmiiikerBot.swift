//
//  UmiiikerBot.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/09/19.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class UmiiikerBot {
    
    let chatText: String
    let chatCount: Int
    
    init(dic: [String: Any]){
        self.chatText = dic["chatText"] as? String ?? ""
        self.chatCount = dic["chatCount"] as? Int ?? 0
        
    }
}
