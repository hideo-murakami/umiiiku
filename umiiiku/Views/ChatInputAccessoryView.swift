//
//  ChatInputAccessoryView.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/12.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit

protocol ChatInputAccessoryViewDelegate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else {return}
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate: ChatInputAccessoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    private func setupViews() {
        
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 60, green: 60, blue: 60).cgColor
        chatTextView.layer.borderWidth = 1
        
        //chatTextView.textContainer.lineFragmentPadding = 15
        chatTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        sendButton.layer.cornerRadius = 155
        sendButton.inputView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
        
    }
    
    func removeText(){
        chatTextView.text = ""
        sendButton.isEnabled = false
    }

    override var intrinsicContentSize: CGSize {
        
        return .zero
        
    }
    
    private func nibInit() {
    
    let nib = UINib(nibName: "ChatInputAccessoryView", bundle: nil)
        
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
    
}
