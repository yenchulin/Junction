//
//  TagCollectionViewCell.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/13.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

@IBDesignable class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    func style_inCreator() {
        self.borderColor = Junction.Color.light_blue
        self.titleLabel.textColor = Junction.Color.light_blue
    }
}
