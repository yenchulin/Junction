//
//  ChatRoom.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/5.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import Foundation

struct ChatRoom : Decodable {
    var id: String
    var friend: User
    var unread_number: Int
    var last_messageTime: Date? // ISO
    
    enum CodingKeys: String, CodingKey {
        case id = "message_id"
        case friend_id = "user_id"
        case profile_pic_str = "photo"
        case chinese_name
        case english_name
        case job_title
        case last_messagTime = "last_message_time"
        case unread_number = "unread_message_number"
    }
}

extension ChatRoom {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.last_messageTime = try container.decode(String.self, forKey: .last_messagTime).toDateFromISO()
        self.unread_number = try container.decode(Int.self, forKey: .unread_number)
        
        
        let friend_id = try container.decode(String.self, forKey: .friend_id)
        let friend_pic_str = try container.decode(String.self, forKey: .profile_pic_str)
        let friend_chinese_name = try container.decode(String.self, forKey: .chinese_name)
        let friend_english_name = try container.decode(String.self, forKey: .english_name)
        let friend_title = try container.decode(String.self, forKey: .job_title)
        let friend = User(id: friend_id, profile_pic_str: friend_pic_str, chinese_name: friend_chinese_name, english_name: friend_english_name, job_title: friend_title)
        
        self.friend = friend
    }
}
