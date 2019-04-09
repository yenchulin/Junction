//
//  AppDelegate.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/10/25.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import FacebookCore
import SDCAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var activeTimer = Timer()
    var timerIsRunning = false

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Connect AppDelegate to FB's SDKApplicationDelegate object
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    // MARK: - Deeplinking
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if LISDKCallbackHandler.shouldHandle(url) {
            return LISDKCallbackHandler.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: nil)
        } else {
            return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        }
    }
    
    // MARK: - Push Notification Functions
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let device_id = tokenParts.joined()
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        PushNotificationHelper.sendDeviceIDToServer(device_id, user_id: user_id)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("AppDelegate: failed to register remote notification because \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        switch application.applicationState {
        case .background, .inactive:
            PushNotificationHelper.notificationHandler(userInfo, window: self.window, storyboard: self.storyboard)
            
        default:
            print("AppDelegate: \(#function) app is in active state, no need to navigate to ChatRoomVC")
        }
    }
    
    // MARK: - App In/Out Foreground State
    // Transitioning to the foreground state
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Elimenate the badge number once the app is active
        application.applicationIconBadgeNumber = 0
        
        // To see how many people are using the application(Logging in FB Dashboard)
        AppEventsLogger.activate(application)
        
        // Start counting user using time
        self.startActiveTimer()
    }
    
    // Called when leaving the foreground state
    func applicationWillResignActive(_ application: UIApplication) {
        
        // Stop counting user using time
        self.stopCountDownTimer()
    }
    
    
    
    // MARK: - Helper Functions
    // Timer Functions:
    private func startActiveTimer() {
        var using_time = UserDefaults.standard.integer(forKey: "using_time")
        if !self.timerIsRunning {
            self.activeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                using_time += 1
                UserDefaults.standard.set(using_time, forKey: "using_time")
                // print(using_time)
                
                if using_time == 300 {
                    self.presentAppReviewAlert()
                }
            })
            
            self.timerIsRunning = true
        }
    }
    
    private func stopCountDownTimer() {
        if self.timerIsRunning {
            self.activeTimer.invalidate()
            
            self.timerIsRunning = false
        }
    }
    
    private func presentAppReviewAlert() {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        let appReviewAlert = AlertController(title: "提供回饋", message: "您目前的使用體驗如何？")
        let yesAction = AlertAction(title: "非常良好", style: .preferred, handler: { (action) in
            self.giveFeedback(user_id, score: 5)
        })
        let confusedAction = AlertAction(title: "尚可", style: .normal, handler: { (action) in
            self.giveFeedback(user_id, score: 3)
        })
        let noAction = AlertAction(title: "急需改進", style: .normal, handler: { (action) in
            self.giveFeedback(user_id, score: 1)
        })
        
        appReviewAlert.addAction(yesAction)
        appReviewAlert.addAction(confusedAction)
        appReviewAlert.addAction(noAction)
        
        appReviewAlert.present()
    }
    
    // Fetch api to give feedback
    private func giveFeedback(_ user_id: String, score: Int) {
        let url = Junction.API.postBetaFeedbackAPI
        let parameters: Parameters = ["user_id": user_id,
            "score": score]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                 AlertController.alert(withTitle: "感謝您的回饋", message: "我們會繼續努力提供更好的產品！", actionTitle: "好")
            case .failure(let error):
                print("AppDelegate: \(#function) fail because \(error.localizedDescription)")
            }
        }
    }
}

