//
//  UserListViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/14.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class UserListViewController: UIViewController {
    
    var umiiikerId: String = ""
    var myLevel: Int = 0
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    private var chatroomvacant: Bool = true
    
    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var startChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 15
        startChatButton.isEnabled = false
        startChatButton.addTarget(self, action: #selector(tappedStartChatButton), for: .touchUpInside)
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        fetchUserInfoFromFirestore()
        
//        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
//            target: self,
//            action: #selector(UserListViewController.tappedUserImage(_:)))
//
//        // デリゲートをセット
//        tapGesture.delegate = self
//
//        self.view.addGestureRecognizer(tapGesture)
    }
   
    @objc func tappedUserImage(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            print("タップ")
        }
    }
    
    @objc func tappedStartChatButton() {
        print("tappedStartChatButton")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        var members = [uid, partnerUid]
        members.append(self.umiiikerId)
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "createdAt": Timestamp()
            ] as [String : Any]
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("ChatRooms情報の保存に失敗しました。\(err)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("ChatRooms情報の保存に成功しました。", docData)
            
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                guard let snapshot = snapshot, let dic = snapshot.data() else { return }
                let user = User(dic: dic)
                print("token",user.token)
            }
        }
    }
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
            if let err = err {
                print("user情報の取得に失敗しました。\(err)")
                return
            }
            Firestore.firestore().collection("chatRooms")
                .getDocuments { (snapshots2, err) in
                    if let err = err {
                        print("Chatrooms情報の取得に失敗しました。\(err)")
                        return
                    }
                    snapshots?.documents.forEach ({ (snapshot) in
                        let dic = snapshot.data()
                        let user = User.init(dic: dic)
                        user.uid = snapshot.documentID
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        print("myLevel",self.myLevel)
                        print("user.userLevel",user.userLevel)
                        if uid == snapshot.documentID || self.umiiikerId == snapshot.documentID || user.userLevel > self.myLevel + 1 {
                            return
                        }
                        snapshots2?.documents.forEach ( { (snapshot2) in
                            let dic2 = snapshot2.data()
                            let chatroom = ChatRoom(dic: dic2)
                            let isMeContain = chatroom.members.contains(uid)
                            let isPartnerContain = chatroom.members.contains(user.uid ?? "")
                            if isMeContain && isPartnerContain { self.chatroomvacant = false }
                            
                        })
                        if self.chatroomvacant { self.users.append(user) }
                        self.chatroomvacant = true
                        self.userListTableView.reloadData()
                    })
            }
        }
    }
    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        print("username",users[indexPath.row].username)
        
        let storyboard = UIStoryboard.init(name: "UserPage", bundle: nil)
        let userPageViewController = storyboard.instantiateViewController(withIdentifier: "UserPageViewController") as! UserPageViewController
        let nav = UINavigationController(rootViewController: userPageViewController)
        userPageViewController.userID = users[indexPath.row].uid ?? ""
        self.present(nav, animated: true, completion: nil)
        
        let user = users[indexPath.row]
        self.selectedUser = user
    }
}

class UserListTableViewCell: UITableViewCell {
    var user: User? {
        didSet{
            usernameLabel.text = user?.username
            userLevelLabel.text = "L" + String(user?.userLevel ?? 0)
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLevelLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5
        userLevelLabel.layer.cornerRadius = 10
        userLevelLabel.clipsToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
