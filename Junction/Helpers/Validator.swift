//
//  Validator.swift
//  Junction
//
//  Created by 林晏竹 on 2018/3/4.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import Foundation

protocol ValidatorProtocol: NSObjectProtocol {
    func validate(_ textField: UITextField)
    func validate(_ textView: UITextView)
}


// Change View when text validation fail
class Validator {
    
    // MARK: - Constants
    static let errorImageViewTag = 1001
    
    // MARK: - Properties
    weak var delegate: ValidatorProtocol?

    
    
    
    // MARK: - Functions:
    func changeTextFieldView(ifError error: Bool, _ textField: UITextField) {
        if error {
            // Bordercolor -> ERROR
            textField.layer.borderColor = Junction.Color.red.cgColor
            
            // Right Image -> ERROR
            let errorImageView = UIImageView(image: UIImageViewX.textbox_errorImage)
            errorImageView.contentMode = .left
            errorImageView.frame = UIEdgeInsetsInsetRect(errorImageView.frame, UIEdgeInsetsMake(0, 0, 0, -14))
            textField.rightViewMode = .unlessEditing
            textField.rightView = errorImageView
            
        } else {
            // Bordercolor -> NORMAL
            textField.layer.borderColor = Junction.Color.black.cgColor
            
            // Right Image -> NORMAL
            textField.rightViewMode = .never
            textField.rightView = nil
        }
    }
    
    func changeTextViewView(ifError error: Bool, _ textView: UITextView) {
        if error {
            // Bordercolor -> ERROR
            textView.layer.borderColor = Junction.Color.red.cgColor
            
            // Right Image -> ERROR
            if textView.viewWithTag(Validator.errorImageViewTag) == nil {
                let errorImageView = UIImageView(image: UIImageViewX.textbox_errorImage)
                errorImageView.tag = Validator.errorImageViewTag
                errorImageView.contentMode = .center
                
                textView.addSubview(errorImageView)
                let originX = textView.frame.width - errorImageView.frame.width - textView.textContainerInset.right - 4
                errorImageView.frame.origin = CGPoint(x: originX, y: textView.textContainerInset.top)
            }
        } else {
            // Bordercolor -> NORMAL
            textView.layer.borderColor = Junction.Color.black.cgColor
            // Right Image -> NORMAL
            if let errorImageView = textView.viewWithTag(Validator.errorImageViewTag) {
                errorImageView.removeFromSuperview()
            }
        }
    }
}
