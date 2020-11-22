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
    @IBOutlet weak var userLevelLabel: UILabel!
    
    private var user: User?
    
    private var blockCount = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "マイページ"
        fetchLoginUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmLoggedInUser()
        fetchUserInfoFromFirestore(myUid: Auth.auth().currentUser?.uid ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBlockInfoFromFirestore(myUid: Auth.auth().currentUser?.uid ?? "")
        fetchReportInfoFromFirestore(myUid: Auth.auth().currentUser?.uid ?? "")
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushLoginViewController()
        }
    }
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            let user = User(dic: dic)
            self.user = user
        }
    }
    
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    private func fetchUserInfoFromFirestore(myUid:String) {
        Firestore.firestore().collection("users").document(myUid).getDocument  { (snapshot, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            let user = User.init(dic: dic!)
            self.userNameTextView.text = user.username
            self.userLevelLabel.text = String(user.userLevel)
            
            if let url = URL(string: user.profileImageUrl ) {
                Nuke.loadImage(with: url, into: self.profileImageView)
            }
            
        }
    }
    
    private func fetchBlockInfoFromFirestore(myUid:String) {
        Firestore.firestore().collection("blockChatRooms").whereField("blockUserId", isEqualTo: myUid).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            self.blockCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    private func fetchReportInfoFromFirestore(myUid:String) {
        Firestore.firestore().collection("blockChatRooms").whereField("fromUid", isEqualTo: myUid).getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            self.reportCountLabel.text = String(snapshots?.documents.count ?? 0)
        }
    }
    
    
}


