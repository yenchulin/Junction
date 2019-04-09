//
//  UIImageExtension.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/17.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import Foundation

extension UIImage {
    
    func encodeToBase64() -> String? {
        guard let imageData: Data = UIImagePNGRepresentation(self) else { return nil }
        let imageBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return imageBase64
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
