//
//  ProfessionalCapability.swift
//  Junction
//
//  Created by 林晏竹 on 2018/4/10.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import SwiftyJSON

struct ProfessionalCapability {
    static let all = ["產品管理", "行銷", "數據分析", "用戶體驗", "創業", "銷售", "金融", "資訊科技", "國際商務", "其他"]
    
    var pm: Int
    var marketing: Int
    var data_analysis: Int
    var uiux: Int
    var startup: Int
    var sales: Int
    var finance: Int
    var information_technology: Int
    var business: Int
    var other: String
    
    
    init(pm: Int = 0,
         marketing: Int = 0,
         data_analysis: Int = 0,
         uiux: Int = 0,
         startup: Int = 0,
         sales: Int = 0,
         finance: Int = 0,
         information_technology: Int = 0,
         business: Int = 0,
         other: String = "") {
        
        self.pm = pm
        self.marketing = marketing
        self.data_analysis = data_analysis
        self.uiux = uiux
        self.startup = startup
        self.sales = sales
        self.finance = finance
        self.information_technology = information_technology
        self.business = business
        self.other = other
    }
    
    init(_ json: [String: JSON]) {
        self.pm = json["pm"]?.intValue ?? 0
        self.marketing = json["marketing"]?.intValue ?? 0
        self.data_analysis = json["data_analysis"]?.intValue ?? 0
        self.uiux = json["uiux"]?.intValue ?? 0
        self.startup = json["startup"]?.intValue ?? 0
        self.sales = json["sales"]?.intValue ?? 0
        self.finance = json["finance"]?.intValue ?? 0
        self.information_technology = json["information_technology"]?.intValue ?? 0
        self.business = json["business"]?.intValue ?? 0
        self.other = json["other"]?.stringValue ?? ""
    }
    
    func toChineseKeyDict() -> [String: Any] {
        return ["產品管理": self.pm,
                "行銷": self.marketing,
                "數據分析": self.data_analysis,
                "用戶體驗": self.uiux,
                "創業": self.startup,
                "銷售": self.sales,
                "金融": self.finance,
                "資訊科技": self.information_technology,
                "國際商務": self.business,
                "其他": self.other]
    }
    
    mutating func updateRating(for tag: TagCollectionViewCell, isIncrease: Bool ) {
        switch tag.titleLabel.text {
        case "產品管理":
            self.pm = isIncrease ? 4 : 2
        case "行銷":
            self.marketing = isIncrease ? 4 : 2
        case "數據分析":
            self.data_analysis = isIncrease ? 4 : 2
        case "用戶體驗":
            self.uiux = isIncrease ? 4 : 2
        case "創業":
            self.startup = isIncrease ? 4 : 2
        case "銷售":
            self.sales = isIncrease ? 4 : 2
        case "金融":
            self.finance = isIncrease ? 4 : 2
        case "資訊科技":
            self.information_technology = isIncrease ? 4 : 2
        case "國際商務":
            self.business = isIncrease ? 4 : 2
        case "其他":
            self.other = isIncrease ? "其他" : ""
        default:
            print("ProfessionalCapability: \(#function) unexpected tag title label.")
        }
    }
    
    func ratingOver3() -> [String] {
        var result = [String]()
        if self.pm >= 3 { result.append("產品管理") }
        if self.marketing >= 3 { result.append("行銷") }
        if self.data_analysis >= 3 { result.append("數據分析") }
        if self.uiux >= 3 { result.append("用戶體驗") }
        if self.startup >= 3 { result.append("創業") }
        if self.sales >= 3 { result.append("銷售") }
        if self.finance >= 3 { result.append("金融") }
        if self.information_technology >= 3 { result.append("資訊科技") }
        if self.business >= 3 { result.append("國際商務") }
        if !self.other.isEmpty { result.append("其他") }
        
        return result
    }
}
