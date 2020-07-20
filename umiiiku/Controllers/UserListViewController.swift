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
import FirebaseFirestore

class UserListViewController: UIViewController {
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
    }
    
    @objc func tappedStartChatButton() {
        print("tappedStartChatButton")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid, partnerUid]
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
            print("ChatRooms情報の保存に成功しました。")
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
                        self.chatroomvacant = true
                        let dic = snapshot.data()
                        let user = User.init(dic: dic)
                        user.uid = snapshot.documentID
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        if uid == snapshot.documentID {
                            return
                        }
                        snapshots2?.documents.forEach ( { (snapshot2) in
                            let dic2 = snapshot2.data()
                            let chatroom = ChatRoom(dic: dic2)
                            if (user.uid == chatroom.members[0] || user.uid == chatroom.members[1]) &&
                               (uid == chatroom.members[0] || uid == chatroom.members[1])  {
                                print("既にチャットルームがあります")
                                self.chatroomvacant = false
                            }
                        })
                        if self.chatroomvacant { self.users.append(user) }
                        self.userListTableView.reloadData()
                    })
            }
        }
    }
    
    func fetchChatroomsInfoFromFirestore(uid: String){
    }
    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
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
        let user = users[indexPath.row]
        self.selectedUser = user
    }
}

class UserListTableViewCell: UITableViewCell {
    var user: User? {
        didSet{
            usernameLabel.text = user?.username
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 32.5
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
