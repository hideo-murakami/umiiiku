//
//  BlockInfo.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/25.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation
import Firebase

class BlockInfo {
    
    let blockToName: String
    let blockToUserId: String
    let blockFromName: String
    let blockFromUserId: String
    let chatroomDocId: String
    
    init(dic: [String: Any]){
        self.blockToName = dic["blockToName"] as? String ?? ""
        self.blockToUserId = dic["blockToUserId"] as? String ?? ""
        self.blockFromName = dic["blockFromName"] as? String ?? ""
        self.blockFromUserId = dic["blockFromUserId"] as? String ?? ""
        self.chatroomDocId = dic["chatroomDocId"] as? String ?? ""
    }
}
