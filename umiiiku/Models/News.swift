//
//  News.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/14.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import Foundation

class News: Decodable {
    
    let contents: [Content]
    
}

class Content: Decodable{
    
    let title: String
    let banner: BannerInfo
    let description: String
    let detail: String
    
}

class BannerInfo: Decodable {
    
    let url: String
}
