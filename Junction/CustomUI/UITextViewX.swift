//
//  DesignableTextView.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/14.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewX: UITextView {
    
    var placeholderLabel = UILabel()
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var horizontalPadding: CGFloat = 0 {
        didSet {
            self.textContainerInset.left = horizontalPadding
            self.textContainerInset.right = horizontalPadding
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
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.placeholderLabel.text = placeholder
        }
    }
    @IBInspectable var tint: UIColor = UIColor.lightGray {
        didSet {
            self.placeholderLabel.textColor = tint
        }
    }
    
    
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            self.placeholderLabel.textAlignment = textAlignment
        }
    }

    override open var text: String! {
        didSet {
            self.textDidChange()
        }
    }
    
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UITextViewTextDidChange, object: nil)
    }
    
    // Called by 'setNeedsDisplay()'
    override func draw(_ rect: CGRect) {
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.frame.origin = CGPoint(x: self.textContainerInset.left + 4, y: self.textContainerInset.top)
        self.placeholderLabel.frame.size = self.placeholderLabel.intrinsicContentSize
    }

    private func commonInit() {
        
        // Configure placeholder label
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: .UITextViewTextDidChange, object: nil)

        // didSet won't work when first initialization, so added manually
        self.placeholderLabel.text = self.placeholder
        self.placeholderLabel.textColor = self.tint
        self.placeholderLabel.font = self.font
        self.placeholderLabel.backgroundColor = UIColor.clear
        self.placeholderLabel.sizeToFit()
        
        self.setNeedsDisplay()
    }

    @objc private func textDidChange() {
        self.layoutIfNeeded()
        self.placeholderLabel.isHidden = !text.isEmpty
        self.layoutIfNeeded()
    }
}

