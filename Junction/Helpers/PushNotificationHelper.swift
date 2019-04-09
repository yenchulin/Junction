//
//  PushNotificationHelper.swift
//  Junction
//
//  Created by 林晏竹 on 2018/4/20.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications

enum PushNotificationHelper {
    
    // Request user's permission for push notification
    static func registerPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            if granted {
                self.getNotificationSettings()
            } else {
                return
            }
        }
    }
    
    // Get the notification settings the user has granted
    static private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                return
            }
        }
    }
    
    // Forward device_id to server
    static func sendDeviceIDToServer(_ device_id: String, user_id: String) {
        let parameter: Parameters = ["ios": device_id]
        let url = Junction.API.putDeviceIDAPI.replacingOccurrences(of: "<user_id>", with: user_id)
        
        Alamofire.request(url, method: .put, parameters: parameter, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let message = JSON(value)["message"].stringValue
                print("PushNotificationHelper: \(#function) \(message)")
                
            case .failure(let error):
                print("PushNotificationHelper: \(#function) error because \(error.localizedDescription)")
            }
        }
    }
    
    // Update notification on/off in chatroom
    static func putChatRoomNotification(_ chatRoom_id: String, user_id: String, isOn: Bool, completion: @escaping (Error?) -> Void) {
        let url = Junction.API.putChatRoomNotificationURL.replacingOccurrences(of: "<chatRoom_id>", with: chatRoom_id)
        let parameters: Parameters = ["user_id": user_id, "notification": isOn]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // Extract notification and handle the correct action
    static func notificationHandler(_ notification: [AnyHashable : Any], window: UIWindow?, storyboard: UIStoryboard) {
        let notificationJSON = JSON(notification)
        let notification_type = notificationJSON["type"].stringValue
        
        switch notification_type {
        case "message":
            let chatRoom_id = notificationJSON["message_id"].stringValue
            let friend_id = notificationJSON["user_id"].stringValue
            let friend_pic_str = notificationJSON["photo"].stringValue
            let friend_chinese_name = notificationJSON["chinese_name"].stringValue
            let friend_english_name = notificationJSON["english_name"].stringValue
            
            let friend = User(id: friend_id, profile_pic_str: friend_pic_str, chinese_name: friend_chinese_name, english_name: friend_english_name)
            let chatRoom = ChatRoom(id: chatRoom_id, friend: friend, unread_number: 0, last_messageTime: nil)
            
            self.navigateToChatRoom(chatRoom, window: window, storyboard: storyboard)
            
        case "card":
            self.navigateToDrawCard(window: window, storyboard: storyboard)
        case "friend":
            self.navigateToCardTable(window: window, storyboard: storyboard)
            
        default:
            print("PushNotificationHelper: \(#function) has unexpected notification type.")
        }
    }
    
    // Navigate to ChatRoomVC when notification is opened
    static private func navigateToChatRoom(_ chatRoom: ChatRoom, window: UIWindow?, storyboard: UIStoryboard) {
        let mainTabVC = window?.rootViewController as! MainTabBarController
        mainTabVC.selectedIndex = 1
        let navigationVC = mainTabVC.selectedViewController as! UINavigationController
        let chatRoomVC = storyboard.instantiateViewController(withIdentifier: "chatRoomVC") as! ChatRoomViewController
        chatRoomVC.chatRoom = chatRoom
        navigationVC.pushViewController(chatRoomVC, animated: true)
        window?.makeKeyAndVisible()
    }
    
    // Navigate to DrawCardVC when notification is opened
    static private func navigateToDrawCard(window: UIWindow?, storyboard: UIStoryboard) {
        let mainTabVC = window?.rootViewController as! MainTabBarController
        mainTabVC.selectedIndex = 0
        window?.makeKeyAndVisible()
    }
    
    // Navigate to CardTableVC when notification is opened
    static private func navigateToCardTable(window: UIWindow?, storyboard: UIStoryboard) {
        let mainTabVC = window?.rootViewController as! MainTabBarController
        mainTabVC.selectedIndex = 1
        window?.makeKeyAndVisible()
    }
}
