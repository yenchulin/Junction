//
//  SettingsTableViewController.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/11/25.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDCAlertView

class SettingsTableViewController: UITableViewController {

    // MARK: - Properties
    var pasteboard = UIPasteboard.general
    
    
    // MARK: - View Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Hide Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    
    // MARK: - TableView Delegate Functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        switch cell?.tag {
        case 999: // 邀請碼
            
            // Copy text
            self.pasteboard.string = cell?.textLabel?.text
            
            // Popup alert to inform text copied
            let alert = AlertController(title: "已複製", message: nil)
            alert.present(animated: true, completion: {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
                    alert.dismiss()
                })
            })
//        case 888: // 是否參與每日卡片抽取
        case 777: // 關於我們
            UIApplication.shared.open(URL(string: Junction.about_usURL)!)
            
        case 666: // Facebook粉專
            UIApplication.shared.open(URL(string: Junction.FBFanPageURL)!)
            
        case 555: // 登出
            
            // Deregister push notification
            let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
            PushNotificationHelper.sendDeviceIDToServer("", user_id: user_id)
            
            // Remove all userDefaults
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            
            // Present SignInVC and switch to main page (draw-card page)
            self.navigationController?.tabBarController?.performSegue(withIdentifier: "presentSignInVC", sender: self)
            self.navigationController?.tabBarController?.selectedIndex = 0
            
        default:
            print("SettingVC: Unexpected TableViewCell")
        }
    }
    
    
    
    // MARK: Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "settingsShowUserCard":
            let cardDetailVC = segue.destination as! CardDetailViewController
            cardDetailVC.user_id = UserDefaults.standard.string(forKey: "user_id")
        default:
            print("SettingsVC: \(#function) unexpected segue")
        }
    }
}
