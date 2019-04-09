//
//  DateExtension.swift
//  Junction
//
//  Created by 林晏竹 on 2018/3/10.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import Foundation

extension Date {
    
    func toStringFromISO() -> String {
        let isoFormatter = ISO8601DateFormatter()
        return isoFormatter.string(from: self)
    }
}
