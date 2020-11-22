//
//  BaseTabBarController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/25.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    enum ControllerName: Int {
        case news,chat,mypage,map
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        
    }
    
    private func setupViewControllers(){
        viewControllers?.enumerated().forEach({ (index, viewController) in
            
            if let name = ControllerName.init(rawValue: index) {
                switch name {
                case .news:
                    setTabbarInfo(viewController, selectedImageName: "news-icon_on", unselectedImageName: "news-icon_off", title: "ニュース")
                    
                case .chat:
                    setTabbarInfo(viewController, selectedImageName: "chat-icon_on", unselectedImageName: "chat-icon_off", title: "チャット")
                    
                case .mypage:
                    setTabbarInfo(viewController, selectedImageName: "profile-icon_on", unselectedImageName: "profile-icon_off", title: "マイページ")
                    
                case .map:
                    setTabbarInfo(viewController, selectedImageName: "profile-icon_on", unselectedImageName: "profile-icon_off", title: "マップ")
                }
            }
            
        })
    }
    
    private func setTabbarInfo(_ viewController: UIViewController, selectedImageName: String, unselectedImageName: String, title: String) {
        
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.image = UIImage(named: unselectedImageName)?.resize(size: .init(width: 20, height: 20))?.withRenderingMode(.alwaysOriginal)
        viewController.tabBarItem.title = title
        
    }
}
