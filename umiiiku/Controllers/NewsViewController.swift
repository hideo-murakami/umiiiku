//
//  NewsViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/15.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Nuke

class NewsViewController: UIViewController {
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var selectedNews: Content?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.addTarget(self, action: #selector(tappedcloseButton), for: .touchUpInside)
        
        if let url = URL(string: selectedNews?.banner.url ?? "") {
        
        Nuke.loadImage(with: url, into: bannerImageView)
        
        }
        
        titleLabel.text = selectedNews?.title
        detailLabel.text = selectedNews?.detail
        
        
        
        
        
    }
    
    @objc func tappedcloseButton() {
        print("閉じるボタンが押されました")
        dismiss(animated: true, completion: nil)
    }
}
