//
//  DotsView.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/6.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

@IBDesignable class UITextFieldX: UITextField {

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
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: frame.size.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always
        }
    }
    @IBInspectable var rightImage: UIImage? {
        didSet {
            self.changeRightViewImage()
        }
    }
    @IBInspectable var tint: UIColor = UIColor.darkGray {
        didSet {
            self.changeRightViewImage()
            self.changePlaceholderColor()
        }
    }
    
    
    // MARK : - Helper Functions
    func changeRightViewImage() {
        if let myRightImage = rightImage {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            imageView.image = myRightImage
            imageView.tintColor = tint
            
            self.rightViewMode = .always
            self.rightView = imageView
        } else {
            self.rightViewMode = .never
            self.rightView = nil
        }
    }
    
    func changePlaceholderColor() {
        attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ?  self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: tint, .font: self.font!])
    }
}
