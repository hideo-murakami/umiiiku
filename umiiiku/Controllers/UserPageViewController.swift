//
//  UserPageViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/09/06.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class UserPageViewController: UIViewController {
    
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var userNameTextView: UITextView!
//    @IBOutlet weak var blockCountLabel: UILabel!
//    @IBOutlet weak var reportCountLabel: UILabel!
//    @IBOutlet weak var numberOfBlockedTextView: UITextView!
//    @IBOutlet weak var numberOfReportedTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextView: UITextView!
    @IBOutlet weak var blockCountLabel: UILabel!
    @IBOutlet weak var reportCountLabel: UILabel!
    @IBOutlet weak var chatCountLabel: UILabel!
    
    private var blockCount = 0
    var userID: String = ""
    
    let uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserInfoFromFirestore(userID: userID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBlockInfoFromFirestore(userID: userID)
        fetchReportInfoFromFirestore(userID: userID)
        fetchChatInfoFromFirestore(userID: userID)
    }
    
    private func fetchUserInfoFromFirestore(userID:String) {
        Firestore.firestore().collection("users").document(userID).getDocument  { (snapshot, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            self.userNameTextView.text = user.username
            
            if let url = URL(string: user.profileImageUrl ) {
                Nuke.loadImage(with: url, into: self.profileImageView)
            }
            
        }
    }
    
    private func fetchBlockInfoFromFirestore(userID:String) {
        Firestore.firestore().collection("blockChatRooms").whereField("blockUserId", isEqualTo: userID).getDocuments { (snapshots, err) in
            if let err = err {
                print("ブロックされた回数情報の取得に失敗しました。\(err)")
                return
            }
            self.blockCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    
    private func fetchReportInfoFromFirestore(userID:String) {
        Firestore.firestore().collection("blockChatRooms").whereField("fromUid", isEqualTo: userID).getDocuments { (snapshots, err) in
            if let err = err {
                print("ブロックした回数情報の取得に失敗しました。\(err)")
                return
            }
            self.reportCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    
    private func fetchChatInfoFromFirestore(userID:String) {
        Firestore.firestore().collection("users")
            .document(userID).getDocument { (userSnapshot, err) in
            if let err = err {
                print("チャット回数情報の取得に失敗しました。\(err)")
                return
            }
                guard let dic = userSnapshot?.data() else { return }
                let user = User(dic: dic)
                self.chatCountLabel.text = String(user.chatCount)
        }
    }
    
}
