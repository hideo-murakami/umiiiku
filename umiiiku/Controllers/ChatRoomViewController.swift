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
    
    var alertController: UIAlertController!
    var assistantMessageText: String = ""
    
    var user: User?
    var chatroom: ChatRoom?
    var chatRoomName: String = "chatRooms"
    var umiiikerId: String = ""
    var assistantId: String = ""
    var assistantUsername: String = ""
    var assistantProfileImageUrl: String = ""
    var dNumber: Double = 1
    var messageProfileImageUrl: String = ""
    var visible: Bool = true
    var chatCount: Int = 0
    var lastMessage: String = ""
    
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
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            /* ダークモード時の処理 */
            chatRoomTableView.backgroundColor = .rgb(red: 35, green: 35, blue: 35)
        } else {
            /* ライトモード時の処理 */
            chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        }
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
        messageIDs.removeAll()
        self.chatroom?.lastSpeakerCount = 0

        if let chatroomDocId = chatroom?.documentId {
            listenForMessages(chatroomDocId: chatroomDocId)
            fetchChatCountFromFirestore(chatroomDocId: chatroomDocId)
        }else { return }
    }
    
    private func fetchChatCountFromFirestore(chatroomDocId: String) {
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").getDocuments { (snapshots, err) in
            if let err = err {
                print("チャットカウント情報の取得に失敗しました。\(err)")
                return
            }
            
            let umiiikerBotChatCount = snapshots?.documents.count
            
            Firestore.firestore().collection("umiiikerBots").getDocuments { (snapshots, err) in
                if let err = err {
                    print("umiiikerBot情報の取得に失敗しました。\(err)")
                    return
                }
                
                snapshots?.documents.forEach ({ (snapshot) in
                    let dic = snapshot.data()
                    let bot = UmiiikerBot(dic: dic)
                    
                    if umiiikerBotChatCount == bot.chatCount {
                        let messageId = self.randomString(length: 20)
                            
                            guard let name = self.chatroom?.partnerUser1?.username else { return }
                            guard let profileImageUrl = self.chatroom?.partnerUser1?.profileImageUrl else { return }
                            guard let chatUsername = self.user?.username else { return }
                            guard let chatUsername1 = self.chatroom?.partnerUser?.username else { return }
                            
                        let  messageText = "\(chatUsername)さん、\(chatUsername1)さん、" + bot.chatText
                        
                            let docData = [
                                "name": name,
                                "createAt": Timestamp(),
                                "uid": self.umiiikerId,
                                "profileImageUrl": profileImageUrl,
                                "isRead": false,
                                "message": messageText
                                ] as [String : Any]
                            
                            Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages")
                                .document(messageId).setData(docData) { (err) in
                                    if let err = err {
                                        print("メッセージ情報の保存に失敗しました。\(err)")
                                        return
                                    }
                                print("botメッセージの保存に成功しました。")
                                self.chatRoomTableView.reloadData()
                            }
                            
                        }
                    
                })
            
            }
        }
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
                
//                print("uid", uid)
//                print("message.uid", message.uid)
//                print("messageDocumentID", messageDocumentID)
                
                switch documentChange.type {
                case .added:
                    
                    if self.visible == true && message.uid != uid && message.uid != self.umiiikerId && uid != self.umiiikerId {
                        
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
                    print("none action")
                }
            })
            
            if self.messages.isEmpty { return }
            let lastMessage = self.messages[0]
            self.chatroom?.lastSpeakerUid = lastMessage.uid
            self.chatroom?.lastSpeakerCount = 0
            
            if self.messages.count > 1 {
                
                for (index, message) in self.messages.enumerated() {
                    print(index, message.uid, message.message)
                    let lastMessage = self.messages[index]
                    if index > 0 { let lastPreviousMessage = self.messages[index - 1]
                        if lastMessage.uid == lastPreviousMessage.uid {
                            self.chatroom?.lastSpeakerCount += 1
                        } else {
                            print("self.chatroom?.lastSpeakerCount",self.chatroom?.lastSpeakerCount ?? 9999)
                            return
                        }
                        
                    }
                }
                    
                }
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
        guard let level = user?.userLevel else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let profileImageUrl = user?.profileImageUrl else { return }
        chatInputAccessoryView.removeText()
        guard let chatLimitCount = self.chatroom?.lastSpeakerCount else { return }
        let speakerLevel = level - 1
        print("speakerLevel",speakerLevel)
        
        if self.chatroom?.lastSpeakerUid == uid && chatLimitCount >= speakerLevel {
            alert(title: "連続で投稿できません",
                  message: "レベル数までしか連続で投稿できませんので、お相手の発言があるまでお待ちください")
            return
        }
        
        let messageId = randomString(length: 20)
        self.chatCount += 1
        self.chatroom?.lastSpeakerUid = uid
        
        print("self.chatroom?.lastSpeakerUid", self.chatroom?.lastSpeakerUid ?? "err")
        print("chatLimitCount", chatLimitCount)
        print("speakerLevel", speakerLevel)
        
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
                }
                
                let docData2 = [
                    "chatCount": self.chatCount
                    ] as [String : Any]
                
                Firestore.firestore().collection("users").document(uid).updateData(docData2) { (err) in
                        if let err = err {
                            print("メッセージ情報の保存に失敗しました。\(err)")
                            return
                        }
                    print("チャットカウントの保存に成功しました", self.chatCount)
                    
                    let userLevel = floor(Double(self.chatCount / 360)) + 1
                    
                    let docData3 = [
                        "userLevel": userLevel
                        ] as [String : Any]
                    
                    Firestore.firestore().collection("users").document(uid).updateData(docData3) { (err) in
                            if let err = err {
                                print("レベル情報の保存に失敗しました。\(err)")
                                return
                            }
                    
                    print("レベル情報の保存に成功しました", userLevel)
                    }
                        
                    self.chatRoomTableView.reloadData()
                }
                
                guard let isContainAssistant = self.chatroom?.members.contains(self.assistantId) else { return }
                if !isContainAssistant { return }
                    
                let assistantDefaultMessageText = [
                    "ごめんなさい「アプリについて」「チャットについて」「レベルについて」の質問なら答えられるわよ！",
                    "カナとのチャットに飽きたら、右上の新規チャットからお相手を選んでチャットを楽しんでね",
                    "このアプリについては知ってる？",
                    "大丈夫？会話噛み合ってるか心配ですぅ",
                    "レベルって何のことだかわかる？"]
                self.assistantMessageText = assistantDefaultMessageText.randomItem() ?? "ん？？ごめんね、ちょっとよくわからない" // Note: myItem is an Optional<Int>
                let greetingWordList = ["どうも", "ども", "よろしく", "こんにち", "おはよ", "こんばん", "名前","なまえ", "はじめまして"]
                let greetingSuccess = greetingWordList.contains(where: { text.contains($0) })
                if greetingSuccess {self.assistantMessageText = "カナです！よろしくお願いします。"}
                
                let jobWordList = ["仕事", "しごと", "何して", "なにして", "やくわり", "役割", "ミッション","やること", "やってる"]
                let jobSuccess = jobWordList.contains(where: { text.contains($0) })
                if jobSuccess {self.assistantMessageText = "カナはこのアプリのアシスタントをしています、よろしくね！"}
                
                let yesWordList = ["はい", "知って", "知って", "しってる", "もちろん", "yes", "イエス","YES", "うん"]
                let yesSuccess = yesWordList.contains(where: { text.contains($0) })
                if yesSuccess {self.assistantMessageText = "いいね、他にチャットしたいことありますかー"}
                
                let noWordList = ["いいえ", "知ら", "分からない", "しらない", "いや", "no", "ノー","NO", "ううん"]
                let noSuccess = noWordList.contains(where: { text.contains($0) })
                if noSuccess {self.assistantMessageText = "そうなんだ、アプリについてならお話しできますっ！"}
                
                let appWordList = ["アプリ", "umiiiku"]
                let appSuccess = appWordList.contains(where: { text.contains($0) })
                if appSuccess {self.assistantMessageText = "チャットをしてレベルを上げるゲームみたい、レベルが上がるといろんなイベントに参加できるみたいだよ！"}
                
                let chatWordList = ["チャット", "chat", "会話", "やりとり"]
                let chatSuccess = chatWordList.contains(where: { text.contains($0) })
                if chatSuccess {self.assistantMessageText = "このアプリでは同じレベルか一つ上のレベルのチャット相手を選んで、チャット力を鍛えていろんな会話をして楽しめるみたいだよ"}
                
                let levelWordList = ["レベル", "LEVEL", "level"]
                let levelSuccess = levelWordList.contains(where: { text.contains($0) })
                if levelSuccess {self.assistantMessageText = "チャットをたくさんするとレベルアップするらしいよ、レベル数だけ連続投稿ができるみたい！"}
                
                
                let messageId = self.randomString(length: 20)
                    
                    let docData = [
                        "name": self.assistantUsername,
                        "createAt": Timestamp(),
                        "uid": self.assistantId,
                        "profileImageUrl": self.assistantProfileImageUrl,
                        "isRead": false,
                        "message": self.assistantMessageText
                        ] as [String : Any]
                    
                    Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages")
                        .document(messageId).setData(docData) { (err) in
                            if let err = err {
                                print("メッセージ情報の保存に失敗しました。\(err)")
                                return
                            }
                        print("botメッセージの保存に成功しました。")
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
    
    private func alert(title:String, message:String) {
        alertController = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 5
        return UITableView.automaticDimension
    }
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
//    print("トーク回数：", messages.count)
//    let number = Double(messages.count)
//    if number != 0 { dNumber = number.truncatingRemainder(dividingBy: 100) }
//    print("100で割ったあまり：", dNumber)
    
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

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
