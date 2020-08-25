//
//  ChatRoomViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/11.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatRoomViewController: UIViewController {
    
    var user: User?
    var chatroom: ChatRoom?
    var umiiikerId: String = ""
    var dNumber: Double = 1
    var messageProfileImageUrl: String = ""
    var visible: Bool = true
    
    private var messages = [Message]() {
        didSet{
        }
    }
    
    private var messageIDs = [MessageID]() {
          didSet{
          }
      }
    
    private let cellId = "cellId"
    private let accessoryHeight: CGFloat = 100
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicateInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
            self.view.safeAreaInsets.bottom
    }
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
    
    let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    
    }()

    @IBOutlet weak var chatRoomTableView: UITableView!

    @IBAction func userBlockButton(_ sender: Any) {
        
        let blockChatRoomId = self.storyboard?.instantiateViewController(withIdentifier: "BlockViewController") as! BlockViewController
        blockChatRoomId.blockChatRoomId = chatroom?.documentId ?? ""
        
        self.navigationController?.present(blockChatRoomId, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .white
        setUpNotification()
        setUpChatRoomTableView()
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visible = true;
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.visible = false;
    }
    
    private func setUpNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func setUpChatRoomTableView() {
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicateInset
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeight { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            //最下部以外の時は少しずれるので微調整
            if chatRoomTableView.contentOffset.y != -60 { moveY += 60 }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
            
        }
    }
    
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicateInset
    }
    
    override var inputAccessoryView: UIView?{
        
        get{
            return chatInputAccessoryView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool {
                return true
    }
    
    private func fetchMessages() {
        
        messages.removeAll()

        if let chatroomDocId = chatroom?.documentId {
            listenForMessages(chatroomDocId: chatroomDocId)
            
        }else { return }
    }
    
    private func listenForMessages(chatroomDocId: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots1, err) in
            if let err = err {
                print("メッセージ情報の取得に失敗しました。\(err)")
                return
            }
            snapshots1?.documentChanges.forEach({ (documentChange) in
                
                let dic = documentChange.document.data()
                let messageDocumentID = documentChange.document.documentID
                
                let message = Message(dic: dic)
                let docData = [
                      "messageID": messageDocumentID,
                      "createAt": message.createAt
                      ] as [String : Any]
                
                let messageID = MessageID(dic: docData)
                
                print("uid", uid)
                print("message.uid", message.uid)
                print("messageDocumentID", messageDocumentID)
                
                switch documentChange.type {
                case .added:
                    
                    if self.visible == true && message.uid != uid && message.uid != self.umiiikerId {
                        
                        if message.isRead == false {
                            let isReadData = [
                                "isRead": true
                            ]
                            Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageDocumentID).updateData(isReadData) { (err) in
                                if let err = err {
                                    print("既読の保存に失敗しました。\(err)")
                                    return
                                }
                                print("既読の保存に成功しました")
                            }
                        }
                        
                    }
                    
                    self.messageIDs.append(messageID)
                    self.messageIDs.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createAt.dateValue()
                        let m2Date = m2.createAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createAt.dateValue()
                        let m2Date = m2.createAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.chatRoomTableView.reloadData()
                    
                case .modified, .removed:
                    self.chatRoomTableView.reloadData()
                }
            })
        }
    }
}



extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileImageUrl = user?.profileImageUrl else { return }
        chatInputAccessoryView.removeText()
        let messageId = randomString(length: 20)
        
        let docData = [
            "name": name,
            "createAt": Timestamp(),
            "uid": uid,
            "profileImageUrl": profileImageUrl,
            "isRead": false,
            "message": text
            ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages")
            .document(messageId).setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました。\(err)")
                    return
                }
                
                let latestMessageData = [
                    "latestMessageId": messageId
                ]
                
                print("user.profileImageUrl1", self.user?.profileImageUrl ?? "")
                
                Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                    if let err = err {
                        print("最新メッセージの保存に失敗しました。\(err)")
                        return
                        
                    }
                    print("メッセージの保存に成功しました")
                    self.chatRoomTableView.reloadData()
                }
        }
    }
    
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
        for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }

}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    print("トーク回数：", messages.count)
    let number = Double(messages.count)
    if number != 0 { dNumber = number.truncatingRemainder(dividingBy: 100) }
    print("100で割ったあまり：", dNumber)
    
    if dNumber == 0 {
        let blockChatRoomId = self.storyboard?.instantiateViewController(withIdentifier: "BlockViewController") as! BlockViewController
        blockChatRoomId.blockChatRoomId = chatroom?.documentId ?? ""
        self.navigationController?.present(blockChatRoomId, animated: true)
    }
    return messages.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId,for:indexPath) as! ChatRoomTableViewCell
    cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    cell.message = messages[indexPath.row]
    cell.chatroomDocId = (chatroom?.documentId! ?? "") as String
    cell.messageID = messageIDs[indexPath.row]
    return cell
    }
}
