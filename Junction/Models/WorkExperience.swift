//
//  WorkExperience.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/16.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

enum JobType: String {
    case 產品管理
    case 使用者體驗
    case 數據分析
    case 行銷
    case 銷售
    case 工程
    case 資訊科技
    case 金融
    case 策略
    case 其他
    case None = ""
    
    static let allCases = [產品管理, 使用者體驗, 數據分析, 行銷, 銷售, 工程, 資訊科技, 金融, 策略, 其他]
}

enum IndustryType: String {
    case 軟體網路
    case 半導體及電子
    case 消費性產品
    case 傳產製造
    case 金融服務
    case 法律及會計
    case 文教傳播
    case 旅遊休閒
    case 其他
    case None = ""

    static let allCases = [軟體網路, 半導體及電子, 消費性產品, 傳產製造, 金融服務, 法律及會計, 文教傳播, 旅遊休閒, 其他]
}

struct WorkExperience {
    var company: String?
    var job_title: String?
    var job_type: Set<String>?
    var industry_type: String?
    var career_length: Int?
}
