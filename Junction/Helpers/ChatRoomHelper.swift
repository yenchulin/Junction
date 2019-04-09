//
//  ChatRoomHelper.swift
//  Junction
//
//  Created by 林晏竹 on 2018/5/5.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ChatRoomHelper {
    // Check if the function is currently running
    private static var isRunning = false
    
    static func getChatRooms(_ user_id: String, completion: @escaping((Error?, [ChatRoom]?) -> Void)) {
        if !isRunning {
            self.isRunning = true
            
            let url = Junction.API.getChatRoomsURL.replacingOccurrences(of: "<user_id>", with: user_id)
            Alamofire.request(url).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let chatRoomListJSON = JSON(value).arrayValue
                    let chatRooms = self.extratChatRoomsJSON(chatRoomListJSON)
                    completion(nil, chatRooms)
                    
                case .failure(let error):
                    completion(error, nil)
                }
                
                self.isRunning = false
            }
        } else { return }
    }
    
    private static func extratChatRoomsJSON(_ chatRoomsJSON: [JSON]) -> [ChatRoom] {
        let chatRooms = chatRoomsJSON.map { (chatRoomJSON) -> ChatRoom in
            let chatRoom_id = chatRoomJSON["message_id"].stringValue
            let friend_id = chatRoomJSON["user_id"].stringValue
            let friend_pic_str = chatRoomJSON["photo"].stringValue
            let friend_chinese_name = chatRoomJSON["chinese_name"].stringValue
            let friend_english_name = chatRoomJSON["english_name"].stringValue
            let friend_title = chatRoomJSON["job_title"].stringValue
            let last_messageTime = chatRoomJSON["last_message_time"].stringValue
            let unread_number = chatRoomJSON["unread_message_number"].intValue
            
            let friend = User(id: friend_id, profile_pic_str: friend_pic_str, chinese_name: friend_chinese_name, english_name: friend_english_name, job_title: friend_title)
            let chatRoom = ChatRoom(id: chatRoom_id, friend: friend, unread_number: unread_number, last_messageTime: last_messageTime.toDateFromISO())
            return chatRoom
        }
        
        return chatRooms
    }
}
