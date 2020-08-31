//
//  UITextField-Extension.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/08/29.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

  // とりあえずpaddingを設定
  var padding: CGPoint = CGPoint(x: 30.0, y: 5.0)
  
  init() {
    super.init(frame: .zero)
  }
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
        
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
  }
    
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
  }
    
  override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: self.padding.x, dy: self.padding.y)
  }
}


