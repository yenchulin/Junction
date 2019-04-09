//
//  DesignableButton.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/6.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

@IBDesignable class UIButtonX: UIButton {
    
    var originalAlpha: CGFloat = 1

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
    @IBInspectable var normalColor: UIColor = UIColor.clear {
        didSet {
            self.backgroundColor = normalColor
        }
    }
    @IBInspectable var disabledColor: UIColor = UIColor.darkGray
    
    
    override var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.backgroundColor = normalColor
                self.layer.shadowColor = shadowColor.cgColor
            } else {
                self.backgroundColor = disabledColor
                self.layer.shadowColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.originalAlpha = self.alpha
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.4
        }
        
        return true
    }
    
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.35) {
            self.alpha = self.originalAlpha
        }
    }
}
