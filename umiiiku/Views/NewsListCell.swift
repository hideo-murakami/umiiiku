//
//  NewsListCell.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/14.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Nuke

class NewsListCell: UICollectionViewCell {
    
    var newsContent: Content? {
        
        didSet {
            
            if let url = URL(string: newsContent?.banner.url ?? "") {
            
            Nuke.loadImage(with: url, into: bannerImageView)
            
            }
            
            titleLabel.text = newsContent?.title
            descriptionLabel.text = newsContent?.description
            
        }
        
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.cornerRadius = 40 / 2
        
    }
    
}
