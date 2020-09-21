//
//  ChatListViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/11.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

class ChatListViewController: UIViewController{
    
    var umiiikerId: String = ""
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var chatRoomListener: ListenerRegistration?
    private var messages = [Message]()
    
    private var user: User? {
        didSet{
            navigationItem.title = "ルームリスト"
        }
    }
    
    @IBOutlet weak var chatListEmptyButton: UIButton!
    @IBOutlet weak var chatListTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        handelEmptyView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.chatListTableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        badgeManage()
        confirmLoggedInUser()
        fetchLoginUserInfo()
        fetchChatroomsInfoFromFirestore()
    }
    
    func badgeManage(){
        DispatchQueue.main.async {
            // 0 を代入するとバッジが消える
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    func handelEmptyView(){
        print("chatrooms.count",chatrooms.count)
        if (chatrooms.count == 0) {
            chatListTableView.backgroundView = emptyView
        } else {
            chatListTableView.backgroundView = nil
        }
        
        
    }
    
    func fetchChatroomsInfoFromFirestore(){
        
        guard (Auth.auth().currentUser?.uid) != nil else { return }

        chatRoomListener?.remove()
        chatrooms.removeAll()
        Firestore.firestore().collection("umiiikers").getDocuments { (umiiikerSnapshots, err) in
            if let err = err {
                print("umiiiker情報の取得に失敗しました。\(err)")
                return
            }
            umiiikerSnapshots?.documents.forEach ({ (umiiikerSnapshot) in
                let dic = umiiikerSnapshot.data()
                let umiiiker = Umiiiker.init(dic: dic)
                self.umiiikerId = umiiiker.umiiikerId
                
                self.chatRoomListener = Firestore.firestore().collection("chatRooms")
                    .addSnapshotListener{ (snapshots, err) in
                        if let err = err {
                            print("Chatrooms情報の取得に失敗しました。\(err)")
                            return
                        }
                        snapshots?.documentChanges.forEach({ (documentChange) in
                            switch documentChange.type {
                            case .added:
                                self.handleAddedDocumentChange(documentChange: documentChange)
                            case .modified, .removed:
                                print("nothing to do2")
                            }
                        })
                }
                
            })
        }
    }

    private func handleAddedDocumentChange(documentChange: DocumentChange){
        
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = chatroom.members.contains(uid)
        if !isContain { return }
        let umiiikuIndex:Int = chatroom.members.firstIndex(of: self.umiiikerId) ?? 0
        var u1:Int = 0
        var u2:Int = 0
        switch umiiikuIndex {
        case 0:
            u1 = 1
            u2 = 2
        case 1:
            u1 = 0
            u2 = 2
        case 2:
            u1 = 0
            u2 = 1
        default:
            u1 = 0
            u2 = 1
        }
        if uid == self.umiiikerId {
            
            Firestore.firestore().collection("users").document(chatroom.members[u1]).getDocument {(userSnapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                guard let dic = userSnapshot?.data() else { return }
                let user = User(dic: dic)
                chatroom.partnerUser = user
            }
            
            Firestore.firestore().collection("users").document(chatroom.members[u2]).getDocument {(userSnapshot, err) in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                guard let dic = userSnapshot?.data() else { return }
                let user = User(dic: dic)
                chatroom.partnerUser1 = user
            }
        self.getLatestMessage(chatroom: chatroom)
        }
        else {
            chatroom.members.forEach({ (memberUid) in
                if memberUid != uid && memberUid != self.umiiikerId {
                    
                    Firestore.firestore().collection("users").document(memberUid).getDocument {(userSnapshot, err) in
                        if let err = err {
                            print("ユーザー情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let dic = userSnapshot?.data() else { return }
                        let user = User(dic: dic)
                        chatroom.partnerUser = user
                        self.getUnReadCount(chatroom: chatroom,membersID: memberUid)
                    }
                    Firestore.firestore().collection("users").document(chatroom.members[umiiikuIndex]).getDocument {(userSnapshot, err) in
                        if let err = err {
                            print("umiiiker情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let dic = userSnapshot?.data() else { return }
                        let user = User(dic: dic)
                        chatroom.partnerUser1 = user
                    }
                    
                    
                }
            })
        self.getLatestMessage(chatroom: chatroom)
        }
        
    }
    
    private func getLatestMessage(chatroom: ChatRoom) {
        guard let chatroomId = chatroom.documentId else { return }
        let latestMessageId = chatroom.latestMessageId

        if latestMessageId == "" {
            self.chatrooms.append(chatroom)
            handelEmptyView()
            self.chatListTableView.reloadData()
            return
        }
        Firestore.firestore()
            .collection("chatRooms")
            .document(chatroomId)
            .collection("messages")
            .document(latestMessageId)
            .getDocument { (messageSnapshot, err) in
            if let err = err {
                print("最新情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let dic = messageSnapshot?.data() else { return }
            let message = Message(dic: dic)
            chatroom.latestMessage = message
                
            if chatroom.blockStatus != "blocked" {
                self.chatrooms.append(chatroom)
                self.handelEmptyView()
                }
            self.chatrooms.sort { (m1, m2) -> Bool in
                let m1Date = self.dataFormatterForDateLable(date: m1.latestMessage?.createAt.dateValue() ?? Date())
                let m2Date = self.dataFormatterForDateLable(date: m2.latestMessage?.createAt.dateValue() ?? Date())
                return m1Date > m2Date
            }
            self.chatListTableView.reloadData()
        }
    }
    
    private func getUnReadCount(chatroom: ChatRoom,membersID: String) {
        guard let chatroomId = chatroom.documentId else { return }
        
        Firestore.firestore()
            .collection("chatRooms")
            .document(chatroomId)
            .collection("messages")
            .whereField("isRead", isEqualTo: false)
            .whereField("uid", isEqualTo: membersID)
            .addSnapshotListener
            { (snapshots, err) in
                if let err = err {
                    print("未読情報の取得に失敗しました。\(err)")
                    return
                }
                chatroom.unReadCount = snapshots?.count ?? 9
                self.chatListTableView.reloadData()
        }
    }
    
    private func dataFormatterForDateLable(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor: UIColor.white ]
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        let logoutBarButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem = logoutBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        chatListEmptyButton.titleLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
        chatListEmptyButton.titleLabel!.numberOfLines = 2
        chatListEmptyButton.titleLabel!.textAlignment = NSTextAlignment.center
        
        chatListEmptyButton.addTarget(self, action: #selector(tappedNavRightBarButton), for: .touchUpInside)
    }
    
    @objc private func tappedLogoutBarButton(){
        do {
            try Auth.auth().signOut()
            print("ログアウトに成功しました。")
            pushLoginViewController()
        } catch {
            print("ログアウトに失敗しました。\(error)")
        }
    }
    
    private func pushLoginViewController() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc private func tappedNavRightBarButton(){
        let storyboard = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyboard.instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
        let nav = UINavigationController(rootViewController: userListViewController)
        userListViewController.umiiikerId = self.umiiikerId
        self.present(nav, animated: true, completion: nil)
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
}

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
    
// MARK: UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[safe: indexPath.row]
        cell.umiiikerId = self.umiiikerId
        return cell
    }
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath){
        print("tapped table view")

        guard let topic = chatrooms[safe: indexPath.row]?.documentId else { return }
        Messaging.messaging().subscribe(toTopic: "/topics/" + topic)

        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatCount = (user?.chatCount ?? 0) as Int
        chatRoomViewController.chatroom = chatrooms[safe: indexPath.row]
        chatRoomViewController.umiiikerId = self.umiiikerId
        navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
}

class ChatListTableViewCell: UITableViewCell {
    
    var umiiikerId: String = ""
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var user2ImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unReadCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
        user2ImageView.layer.cornerRadius = 15
        unReadCountLabel.layer.cornerRadius = 10
        unReadCountLabel.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
        var chatroom: ChatRoom? {
            didSet {
                if let chatroom = chatroom {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    for PartnerID in chatroom.members {
                        if PartnerID != uid && PartnerID != umiiikerId {
                            self.getUnReadCount(chatroom: chatroom,membersID: PartnerID)
                        }
                    }
                    
                    latestMessageLabel.text = chatroom.latestMessage?.message
                    partnerLabel.text = chatroom.partnerUser?.username
                    getProfileImageUrl(uid:uid, chatroom:chatroom)
                    
                    dateLabel.text = dataFormatterForDateLable(date: chatroom.latestMessage?.createAt.dateValue() ?? Date())
                }
            }
        }
    
    private func getProfileImageUrl(uid: String,chatroom: ChatRoom){
        
            guard let url1 = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
            Nuke.loadImage(with: url1, into: userImageView)
            
            guard let url2 = URL(string: chatroom.partnerUser1?.profileImageUrl ?? "") else { return }
            Nuke.loadImage(with: url2, into: user2ImageView)
    }
    
    private func getUnReadCount(chatroom: ChatRoom,membersID: String) {
        guard let chatroomId = chatroom.documentId else { return }
        
        Firestore.firestore()
            .collection("chatRooms")
            .document(chatroomId)
            .collection("messages")
            .whereField("isRead", isEqualTo: false)
            .whereField("uid", isEqualTo: membersID)
            .getDocuments
            { (snapshots, err) in
                if let err = err {
                    print("未読情報の取得に失敗しました。\(err)")
                    return
                }
                chatroom.unReadCount = snapshots?.count ?? 0
                if chatroom.unReadCount == 0 { self.unReadCountLabel.isHidden = true} else { self.unReadCountLabel.isHidden = false }
                self.unReadCountLabel.text = String(chatroom.unReadCount)
        }
    }

    
    private func dataFormatterForDateLable(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
