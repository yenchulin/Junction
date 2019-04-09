//
//  StringExtension.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/17.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import Foundation
import os.log

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidCode: Bool {
        let codeRegEx = "[A-Z0-9a-z]{6}"
        let codeTest = NSPredicate(format: "SELF MATCHES %@", codeRegEx)
        return codeTest.evaluate(with: self)
    }
    
    var isChinese: Bool {
        return self.range(of: "\\P{Han}", options: .regularExpression) == nil
    }
    
    var isLatin: Bool {
        return self.range(of: "\\P{Latin}", options: .regularExpression) == nil
    }
    
    func toInt() -> Int? {
        let resultInt = Int(self)
        return resultInt
    }
    
    func decodeBase64ToImage() -> UIImage? {
        guard let decodeData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        guard let resultImage = UIImage(data: decodeData) else {
            return nil
        }
        return resultImage
    }
    
    // imageURL -> Base64
    func encodeToBase64() -> String? {
        guard let imageURL = URL(string: self) else {
            return nil
        }
        do {
            let imageData = try Data(contentsOf: imageURL)
            return imageData.base64EncodedString(options: .lineLength64Characters)
        } catch  {
            return nil
        }
    }
    
    // imageURL or Base64 -> image
    func toImage() -> UIImage? {
        if let imageURL = URL(string: self) {
            // String is URL
            do {
                let imageData = try Data(contentsOf: imageURL)
                return UIImage(data: imageData)
                
            } catch  {
                return nil
            }
            
        } else if let decodeData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            // String is Base64
            return UIImage(data: decodeData)
            
        } else {
            os_log("StringExtension: toImage() has unexpected String type.")
            return nil
        }
    }
    
    
    // female -> 女性, male -> 男性
    func toChinese() -> String? {
        var genderInChinese = ""
        if self == "female" {
            genderInChinese = "女性"
        } else if self == "male" {
            genderInChinese = "男性"
        }
        return genderInChinese
    }
    
    
    // yyyy年MM月 -> yyyy-MM-ddTHH:mm:ssZ
    func toISODate() -> String? {
        let dateString = self.replacingOccurrences(of: " ", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        switch dateString.count {
        case 8: // 2017年10月
            dateFormatter.dateFormat = "yyyy年MM月"
            if let date = dateFormatter.date(from: dateString) {
                let isoFormatter = ISO8601DateFormatter()
                return isoFormatter.string(from: date)
            } else { return nil }
         
        case 7: // 2017年1月
            dateFormatter.dateFormat = "yyyy年M月"
            if let date = dateFormatter.date(from: dateString) {
                let isoFormatter = ISO8601DateFormatter()
                return isoFormatter.string(from: date)
            } else { return nil }
            
        case 5: // 2017年
            dateFormatter.dateFormat = "yyyy年"
            if let date = dateFormatter.date(from: dateString) {
                let isoFormatter = ISO8601DateFormatter()
                return isoFormatter.string(from: date)
            } else { return nil }
            
        case 2: // 至今
            if dateString == "至今" {
                return dateString
                
            } else { return nil }
        default:
            return nil
        }
    }
    
    // yyyy-MM-ddTHH:mm:ssZ -> yyyy年MM月
    func toChineseDateFromISO() -> String? {
        let dateString = self.replacingOccurrences(of: " ", with: "")
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年 M月"
            return dateFormatter.string(from: date)
            
        } else if dateString == "至今" {
            return dateString
            
        } else { return nil }
    }
    
    
    
    // yyyy年MM月 -> yyyy-MM-dd
//    func toDashDate() -> String? {
//        let dateString = self.replacingOccurrences(of: " ", with: "")
//        let date_dashFormatter = DateFormatter()
//        date_dashFormatter.dateFormat = "yyyy-MM-dd"
//
//        switch dateString.count {
//        case 8: // 2017年10月
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy年MM月"
//            if let date = dateFormatter.date(from: dateString) {
//                return date_dashFormatter.string(from: date)
//            } else { return nil }
//            
//
//        case 7: // 2017年1月
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy年M月"
//            if let date = dateFormatter.date(from: dateString) {
//                return date_dashFormatter.string(from: date)
//            } else { return nil }
//
//        case 5: // 2017年
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy年"
//            if let date = dateFormatter.date(from: dateString) {
//                return date_dashFormatter.string(from: date)
//            } else { return nil }
//
//        case 2: // 至今
//            if dateString == "至今" {
//                return date_dashFormatter.string(from: Date())
//            } else { return nil }
//        default:
//            return nil
//        }
//    }
//
//
//    // yyyy-MM-dd -> yyyy年MM月
//    func toChineseDateFromDash() -> String? {
//        let dateString = self.replacingOccurrences(of: " ", with: "")
//        let date_dashFormatter = DateFormatter()
//        date_dashFormatter.dateFormat = "yyyy-MM-dd"
//
//        if let date = date_dashFormatter.date(from: dateString) {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy年 M月"
//            return dateFormatter.string(from: date)
//        } else { return nil }
//    }
    
    
    // yyyy-MM-ddTHH:mm:ssZ -> Date
    func toDateFromISO() -> Date? {
        let dateString = self.replacingOccurrences(of: " ", with: "")
        let isoFormatter = ISO8601DateFormatter()
        
        if let date = isoFormatter.date(from: dateString) {
            return date
        } else {
            return nil
        }
    }
    
    
    // Calculate the content size of string
    func rect(withConstrainedWidth width: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        let resultRect = CGRect(x: boundingBox.origin.x, y: boundingBox.origin.y, width: boundingBox.width, height: ceil(boundingBox.height))
        
        return resultRect
    }
}
