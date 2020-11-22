//
//  BlockViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/24.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase

class BlockViewController: UIViewController {
    
    var alertController: UIAlertController!
    
    private var blockUserId = ""
    private var reportUserId = ""
    
    var user: User?
    var chatroom: ChatRoom?
    var blockUsername = ""
    var blockChatRoomId = ""
    var reason = ""
    
    
    @IBOutlet weak var closeBlockViewButton: UIButton!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockViewText: UITextView!
    @IBOutlet weak var dislikeBlockButton: UIButton!
    @IBOutlet weak var violenceBlockButton: UIButton!
    @IBOutlet weak var spamBlockButton: UIButton!
    @IBOutlet weak var blockReasonTextField: UITextField!
    @IBOutlet weak var anotherBlockButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockView.layer.cornerRadius = 20
        closeBlockViewButton.layer.cornerRadius = 15
        
        dislikeBlockButton.layer.cornerRadius = 10
        violenceBlockButton.layer.cornerRadius = 10
        spamBlockButton.layer.cornerRadius = 10
        anotherBlockButton.layer.cornerRadius = 10
        
        blockReasonTextField.delegate = self
        anotherBlockButton.isEnabled = false
        
        dislikeBlockButton.addTarget(self, action: #selector(tappeddislikeBlockButton), for: .touchUpInside)
        violenceBlockButton.addTarget(self, action: #selector(tappedviolenceBlockButton), for: .touchUpInside)
        spamBlockButton.addTarget(self, action: #selector(tappedspamBlockButton), for: .touchUpInside)
        anotherBlockButton.addTarget(self, action: #selector(tappedanotherBlockButton), for: .touchUpInside)
        
        blockReasonTextField.delegate = self
        
        closeBlockViewButton.addTarget(self, action: #selector(tappedCloseBlockViewButton), for: .touchUpInside)
        
        getBlockUserInfoFromFirestore()
        
    }
    
    @objc private func tappeddislikeBlockButton() {
        reason = "話が合わない"
        print("reason:", reason)
        alert(title: "最終確認",
              message: "\(reason)という理由でブロックしてよろしいですか")
        //addBlockToFirestore()

    }
    @objc private func tappedviolenceBlockButton() {
        reason = "誹謗中傷・公序良俗に反する"
        print("reason:", reason)
        alert(title: "最終確認",
              message: "\(reason)という理由でブロックしてよろしいですか")

    }
    @objc private func tappedspamBlockButton() {
        reason = "スパム・営業行為"
        print("reason:", reason)
        alert(title: "最終確認",
              message: "\(reason)という理由でブロックしてよろしいですか")
    }
    @objc private func tappedanotherBlockButton() {
        reason = "その他"
        print("reason:", reason)
        alert(title: "最終確認",
              message: "\(String(blockReasonTextField.text ?? ""))という理由でブロックしてよろしいですか")
    }
    
    @objc func tappedCloseBlockViewButton() {
        print("閉じるボタンが押されました")
        dismiss(animated: true, completion: nil)
    }
    
    private func getBlockUserInfoFromFirestore() {
        
        Firestore.firestore().collection("chatRooms").document(blockChatRoomId).getDocument { (snapshot, err) in
            if let err = err {
                print("チャット情報の取得に失敗しました。\(err)")
                return
            }
            guard let dic = snapshot?.data() else { return }
            let chatroom = ChatRoom(dic:dic)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            if chatroom.members[0] == uid {
                self.blockUserId = chatroom.members[1]
                self.reportUserId = chatroom.members[0]
            } else {
                self.blockUserId = chatroom.members[0]
                self.reportUserId = chatroom.members[1]
            }
            
            Firestore.firestore().collection("users").document(self.blockUserId ).getDocument { (snapshot, err) in
                if let err = err {
                    print("user情報の取得に失敗しました。\(err)")
                    return
                }
                guard let dic = snapshot?.data() else { return }
                let blockUser = User(dic:dic)
                print("username情報:", blockUser.username)
                print("userID情報:", self.blockUserId)
                self.blockViewText.text = "下記の理由で" + blockUser.username + "さんをブロックします"
            }
            Firestore.firestore().collection("users").document(self.reportUserId ).getDocument { (snapshot, err) in
                if let err = err {
                    print("user情報の取得に失敗しました。\(err)")
                    return
                }
                guard let dic = snapshot?.data() else { return }
                let reportUser = User(dic:dic)
                print("報告者情報:", reportUser.username)
                print("報告者情報:", self.reportUserId)
            }
        }
    }
    
    
    private func addBlockToFirestore() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData = [
            "chatroomDocId": blockChatRoomId,
            "blockUserId": blockUserId,
            "createAt": Timestamp(),
            "fromUid": uid,
            "reason": reason,
            "resonText": blockReasonTextField.text ?? ""
            ] as [String : Any]

        Firestore.firestore().collection("blockChatRooms").document().setData(docData) { (err) in
                if let err = err {
                    print("ブロック情報の保存に失敗しました。\(err)")
                    return
                }
                print("ブロック情報の保存に成功しました。")
      }
        
        let chatRoomBlockStatus = [
            "blockStatus": "blocked"
        ]
        
        Firestore.firestore().collection("chatRooms").document(blockChatRoomId).updateData(chatRoomBlockStatus) { (err) in
            if let err = err {
                print("ブロックステータスの変更に失敗しました。\(err)")
                return
                
            }
            print("ブロックステータスの変更に成功しました")
                   
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }

    private func alert(title:String, message:String) {
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            self.addBlockToFirestore()
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            return
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension BlockViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let blockReasonIsEmpty = blockReasonTextField.text?.isEmpty ?? false
        
        if blockReasonIsEmpty {
            anotherBlockButton.isEnabled = false
            //anotherBlockButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            anotherBlockButton.isEnabled = true
            //anotherBlockButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
