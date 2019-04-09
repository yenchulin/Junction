//
//  MainTabBarController.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/11/25.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDCAlertView

class MainTabBarController: UITabBarController {
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // id for test
//        UserDefaults.standard.set("testuser01", forKey: "user_id")
        
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        
        // Fuctions
        self.checkRequireRegister(on: user_id)
    }
    
    
    
    
    
    // MARK: - Helper Functions
    /* 1. Check if the user is registered
       2. If yes, show main tab bar, register push notification
       3. If no, present signInVC
     */
    private func checkRequireRegister(on user_id: String) {
        RegistrationHelper.checkUserExist(user_id) { (error, user_exist) in
            if error == nil {
                if user_exist! {
                    PushNotificationHelper.registerPushNotifications()
                } else {
                    self.performSegue(withIdentifier: "presentSignInVC", sender: self)
                }
            } else {
                let errorAlert = AlertController(title: "哎呀！", message: "網路發生錯誤請稍後再試")
                let reloadAction = AlertAction(title: "重新整理", style: .normal, handler: { (action) in
                    self.checkRequireRegister(on: user_id)
                })
                let cancelAction = AlertAction(title: "取消", style: .destructive)
                errorAlert.addAction(reloadAction)
                errorAlert.addAction(cancelAction)
                errorAlert.present()
                
                print("MainTabBarVC: \(#function) fail because \(error.debugDescription)")
            }
        }
    }
}
