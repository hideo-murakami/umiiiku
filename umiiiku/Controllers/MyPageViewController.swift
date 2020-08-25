//
//  MyPageViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/25.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextView: UITextView!
    @IBOutlet weak var blockCountLabel: UILabel!
    @IBOutlet weak var reportCountLabel: UILabel!
    @IBOutlet weak var numberOfBlockedTextView: UITextView!
    @IBOutlet weak var numberOfReportedTextView: UITextView!
    
    private var blockCount = 0
    let uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchUserInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBlockInfoFromFirestore()
        fetchReportInfoFromFirestore()
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").document(self.uid ?? "").getDocument  { (snapshot, err) in
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
    
    private func fetchBlockInfoFromFirestore() {
        Firestore.firestore().collection("blockChatRooms").whereField("blockUserId", isEqualTo: self.uid ?? "").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            self.blockCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    private func fetchReportInfoFromFirestore() {
        Firestore.firestore().collection("blockChatRooms").whereField("fromUid", isEqualTo: self.uid ?? "").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            self.reportCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    
    
}


