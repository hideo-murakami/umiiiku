//
//  MapViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/21.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var defaultChatRoomButton: UIButton!
    @IBOutlet weak var danangChatRoomButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultChatRoomButton.addTarget(self, action: #selector(tappeddefaultChatRoomButton), for: .touchUpInside)
        
    }
    
    @objc func tappeddefaultChatRoomButton() {
        print("デフォルトチャットルームが選択されました")
        
        let storyboard = UIStoryboard(name: "ChatList", bundle: nil)
        let chatListViewController = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        chatListViewController.modalPresentationStyle = .fullScreen
//        self.present(chatListViewController, animated: true, completion: nil)
        
        
//        let vc = ChatListViewController()
        let rootVC = UIApplication.shared.windows.first?.rootViewController as? UITabBarController
        let navigationController = rootVC?.children[1] as? UINavigationController
        rootVC?.selectedIndex = 1
        navigationController?.pushViewController(chatListViewController, animated: false)

        
//        chatRoomViewController.user = user
//        chatRoomViewController.chatCount = (user?.chatCount ?? 0) as Int
//        chatRoomViewController.chatroom = chatrooms[safe: indexPath.row]
//        chatRoomViewController.umiiikerId = self.umiiikerId
//        chatRoomViewController.assistantId = self.assistantId
//        chatRoomViewController.assistantUsername = self.assistantUsername
//        chatRoomViewController.assistantProfileImageUrl = self.assistantProfileImageUrl
    }
    
}
