//
//  DesignableImageView.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/6.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

@IBDesignable class UIImageViewX: UIImageView {
    
    static let textbox_errorImage = UIImage(named: "error_alert")
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var placeholder: UIImage? {
        didSet {
            self.image = placeholder
        }
    }
    
    
    override var image: UIImage? {
        didSet {
            guard let placeholder = placeholder else { return }
            if self.image == nil {
                self.image = placeholder
            }
        }
    }
}
