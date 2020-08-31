//
//  ChatRoomTableViewCell.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/11.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell{
    
    var chatroomDocId : String = ""
    var reload: Bool = false
    
    var message: Message? {
        didSet {
            self.reload = true;
        }
    }
    
    var messageID: MessageID? {
        didSet {

        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var partnerDateLabel: UILabel!
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var myIsReadLabel: UILabel!
    @IBOutlet weak var myMessageTextViewWithConstraint: NSLayoutConstraint!
    @IBOutlet weak var partnerMessageTextViewWithConstraint: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        partnerMessageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        myMessageTextView.textColor = UIColor.black
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if self.reload {checkWhichUserMessage()}
        self.reload = false;
    }
    
    private func checkWhichUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("メッセージget2")
        
        if uid == message?.uid {
            partnerMessageTextView.isHidden = true
            partnerDateLabel.isHidden = true
            userImageView.isHidden = true
            
            myMessageTextView.isHidden = false
            myDateLabel.isHidden = false
            myIsReadLabel.isHidden = false
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageID?.messageID ?? "").getDocument { (messageSnapshot, err)  in
                if let err = err {
                    print("既読情報取得に失敗しました。\(err)")
                    return
                }
                guard let dic = messageSnapshot?.data() else { return }
                let message = Message(dic: dic)
                if message.isRead == true { self.myIsReadLabel.text = "既読" } else {
                    self.myIsReadLabel.text = "未読"
                }
            }
            
            if let message = message{
                myMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                myMessageTextViewWithConstraint.constant = CGFloat(width)
                myDateLabel.text = dataFormatterForDateLable(date: message.createAt.dateValue())
            }
            
        } else {
            partnerMessageTextView.isHidden = false
            partnerDateLabel.isHidden = false
            userImageView.isHidden = false
            
            myMessageTextView.isHidden = true
            myDateLabel.isHidden = true
            myIsReadLabel.isHidden = true
            
            if let urlString = message?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
                
            if let message = message{
                partnerMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                partnerMessageTextViewWithConstraint.constant = CGFloat(width)
                partnerDateLabel.text = dataFormatterForDateLable(date: message.createAt.dateValue())
            }
        }
        
        
    }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes:
            [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W3", size: 14) ?? 0], context: nil)    }
//            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)    }
    
    
    private func dataFormatterForDateLable(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
