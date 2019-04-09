//
//  LoginProvider.swift
//  Dots
//
//  Created by 林晏竹 on 2018/1/16.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FacebookCore
import FacebookLogin

protocol LoginProviderDelegate {
    func loginProvider(loginProvider: LoginProvider, didSucceed user: User)
    func loginProvider(loginProvider: LoginProvider, didError error: Error?)
}

// To make functions optional
extension LoginProviderDelegate {
    func loginProvider(didCancel loginProvider: LoginProvider) {}
}


enum LoginProvider: String {
    case LinkedIn
    case Facebook
    case None
    
    func login(delegate: LoginProviderDelegate) {
        switch self {
        case .Facebook:
            self.web_userLoginWithFacebook(delegate, on: delegate as! UIViewController)
            
        case .LinkedIn:
            self.web_userLoginWithLinkedIn(delegate)
            
        default:
            break
        }
    }
    
    
    //  MARK: - Constants
    static let linkedInProfileEndPoint = "https://api.linkedin.com/v1/people/~:(id,formatted-name,picture-urls::(original),email-address,positions)?format=json"
    static let FBPermissions: [ReadPermission] = [.publicProfile, .email]
    static let graphPath = "/me"
    static let graphPathForPic = "/me/picture"
    static var graphRequestParam: [String: Any] = ["fields": "id, name, gender"]
    static let graphRequestParamForPic: [String: Any] = ["type": "large","redirect": false, "width": 400, "height": 400]
    static let batchParam: [String: Any] = ["batch": [["method": "GET", "relative_url": "me"],
                                                      ["method": "GET", "relative_url": "me/picture?type=large"]]]
    
    
    
    // MARK: - Helper Functions
    private func loginWithFacebook(_ delegate: LoginProviderDelegate, on viewController: UIViewController) {
        
        // Login with Facebook
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: LoginProvider.FBPermissions, viewController: viewController) { (loginResult) in
            switch loginResult {
            case .success(let grantedPermissions, _, _):
            
                // Handle granted(declined) permissions
                if grantedPermissions.contains(Permission(name: "email")) {
                    LoginProvider.graphRequestParam = ["fields": "id, name, gender, email"]
                }
                
                // Fetch user Facebook profile (Graph API)
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: LoginProvider.graphPath, parameters: LoginProvider.graphRequestParam)) { _, result in
                    switch result {
                    case .success(let response):
                        
                        // Extract JSON
                        let profileJSON = JSON(response.dictionaryValue)
                        let facebook_id = profileJSON["id"].stringValue
                        let name = profileJSON["name"].stringValue
                        let gender = Gender(rawValue: profileJSON["gender"].stringValue.toChinese()!)
                        let email = profileJSON["email"].stringValue
                        let profile_pic_str = "http://graph.facebook.com/\(facebook_id)/picture?type=large".encodeToBase64()
                        
                        var user = User(id: facebook_id, id_type: LoginProvider.Facebook, profile_pic_str: profile_pic_str, chinese_name: nil, english_name: nil, gender: gender, email: email)
                        
                        if name.isChinese {
                            user.chinese_name = name
                            user.english_name = nil
                        } else if name.isLatin {
                            user.chinese_name = nil
                            user.english_name = name
                        } else {
                            user.chinese_name = nil
                            user.english_name = name
                        }
                        
                        delegate.loginProvider(loginProvider: self, didSucceed: user)
                        
                    case .failed(let error):
                        delegate.loginProvider(loginProvider: self, didError: error)
                    }
                }
                connection.start()
                
            case .failed(let error):
                delegate.loginProvider(loginProvider: self, didError: error)
            case .cancelled:
                delegate.loginProvider(didCancel: self)
            }
        }
    }
    
    private func loginWithLinkedIn(_ delegate: LoginProviderDelegate) {
        
        // Login with LinkedIn
        LISDKSessionManager.createSession(withAuth: [LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: { (success) in
            
            // Fetch user LinkedIn profile
            if LISDKSessionManager.hasValidSession() {
                LISDKAPIHelper.sharedInstance().getRequest(LoginProvider.linkedInProfileEndPoint, success: { (response) in
                    
                    // Extract JSON
                    if let profileData = response?.data.data(using: .utf8, allowLossyConversion: false) {
                        let profileJSON = JSON(data: profileData)
                        let linkedIn_id = profileJSON["id"].stringValue
                        let name = profileJSON["formattedName"].stringValue
                        let pictureUrl = profileJSON["pictureUrls"].dictionaryValue
                        let email = profileJSON["emailAddress"].stringValue
                        let positions = profileJSON["positions"].dictionaryValue
                        
                        var work_exps = [WorkExperience]()
                        if let currentPositionJSON = positions["values"]?.arrayValue.first {
                            let title = currentPositionJSON["title"].stringValue
                            let company = currentPositionJSON["company"].dictionaryValue["name"]?.stringValue
                            
                            work_exps.append(WorkExperience(company: company, job_title: title, job_type: nil, industry_type: nil, career_length: nil))
                        }

                        var profile_pic_str: String?
                        if let myPictureUrl = pictureUrl["values"]?.arrayValue.first?.stringValue {
                            profile_pic_str = myPictureUrl.encodeToBase64()
                        }
                        

                        var user = User(id: linkedIn_id, id_type: LoginProvider.LinkedIn, profile_pic_str: profile_pic_str, chinese_name: nil, english_name: nil, email: email, work_exps: work_exps)
                        
                        if name.isChinese {
                            user.chinese_name = name
                            user.english_name = nil
                        } else if name.isLatin {
                            user.chinese_name = nil
                            user.english_name = name
                        } else {
                            user.chinese_name = nil
                            user.english_name = name
                        }
                        
                        delegate.loginProvider(loginProvider: self, didSucceed: user)
                    }
                }, error: { (error) in
                    delegate.loginProvider(loginProvider: self, didError: error)
                })
            }
        }) { (error) in
            delegate.loginProvider(loginProvider: self, didError: error)
        }
    }
    
    private func web_userLoginWithFacebook(_ delegate: LoginProviderDelegate, on viewController: UIViewController) {
        
        // Login with Facebook
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: LoginProvider.FBPermissions, viewController: viewController) { (loginResult) in
            switch loginResult {
            case .success(_, _, let token):
                let user = User(id: token.userId!, id_type: .Facebook, chinese_name: nil, english_name: nil)
                delegate.loginProvider(loginProvider: self, didSucceed: user)
                
            case .failed(let error):
                delegate.loginProvider(loginProvider: self, didError: error)
                
            case .cancelled:
                delegate.loginProvider(didCancel: self)
            }
        }
    }
    
    private func web_userLoginWithLinkedIn(_ delegate: LoginProviderDelegate) {
        
        // Login with LinkedIn
        LISDKSessionManager.createSession(withAuth: [LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: { (success) in
            
            // Get user linkedIn_id
            if LISDKSessionManager.hasValidSession() {
                LISDKAPIHelper.sharedInstance().getRequest(LoginProvider.linkedInProfileEndPoint, success: { (response) in
                    
                    // Extract JSON
                    let profileData = response!.data.data(using: .utf8, allowLossyConversion: false)!
                    let linkedIn_id = JSON(data: profileData)["id"].stringValue
                    let user = User(id: linkedIn_id, id_type: .LinkedIn, chinese_name: nil, english_name: nil)
                    delegate.loginProvider(loginProvider: self, didSucceed: user)
                    
                }, error: { (error) in
                    delegate.loginProvider(loginProvider: self, didError: error)
                })
            }
        }) { (error) in
            delegate.loginProvider(loginProvider: self, didError: error)
        }
    }
}
