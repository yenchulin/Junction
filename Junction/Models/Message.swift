//
//  Message.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/4.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import Foundation

struct Message {
    var id: Int?
    var text: String
    var send_date: Date
    var sender_id: String
    var isRead: Bool
    var isSender: Bool {
        if sender_id == UserDefaults.standard.string(forKey: "user_id") {
            return true
        } else {
            return false
        }
    }
    
    // Message recieved
    init(id: Int, text: String, send_date: Date, sender_id: String, isRead: Bool) {
        self.id = id
        self.text = text
        self.send_date = send_date
        self.sender_id = sender_id
        self.isRead = isRead
    }
    
    // Message sent
    init(text: String, send_date: Date, sender_id: String) {
        self.text = text
        self.send_date = send_date
        self.sender_id = sender_id
        
        self.id = nil
        self.isRead = true
    }
}
