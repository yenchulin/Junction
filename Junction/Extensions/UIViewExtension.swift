//
//  UIViewExtension.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/4.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraint(with format: String, views: UIView...) {
        var viewsDict = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDict[key] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDict))
    }
}
