//
//  SignInViewController.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/10/25.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignInViewController: UIViewController, LoginProviderDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var invited_codeView: UIView!
    @IBOutlet weak var invited_codeTextField: UITextField!
    @IBOutlet weak var error_msgLabel: UILabel!
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    
    // MARK: - Properties
    var loginProvider = LoginProvider.None
    var user: User?
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Functions:
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.present(self.invited_codeView, transition: .scale)
        }
    }
    
    deinit {
        print("SignInVC: deinit")
    }
    
    
    
    
    // MARK: - Actions
    @IBAction func resignFirstResponder(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func signInLinkedIn(_ sender: UIButton) {
        loginProvider = .LinkedIn
        loginProvider.login(delegate: self)
    }
    
    @IBAction func signInFacebook(_ sender: UIButton) {
        loginProvider = .Facebook
        loginProvider.login(delegate: self)
    }
    
    @IBAction func checkInviation_code(_ sender: UIButton) {
        self.checkInvited_code(on: self.invited_codeTextField.text ?? "0")
    }
    
    @IBAction func skipCode_checking(_ sender: UIButton) {
        self.dismiss(self.invited_codeView, transition: .scale)
    }
    
    
    
    
    // MARK: - LoginProvider Delegate Functions
    
    /* Facebook or LinkedIn login success
       1. Save user.id to UserDefaults
       2. Check if this user.id exists
        - If yes, dismiss SignInVC(go to MainTabVC) then register push notification
        - If no, fetch getWebUserAPI: success -> send info to next page, present RegistrationNC to review profile
                                      fail -> stay at SingInVC present invited_codeView
     - param user: id, id_type is provided
    */
    func loginProvider(loginProvider: LoginProvider, didSucceed user: User) {
        // 1.
        UserDefaults.standard.set(user.id, forKey: "user_id")
        
        // 2.
        let user_id = UserDefaults.standard.string(forKey: "user_id")!
        RegistrationHelper.checkUserExist(user_id) { (error, user_exist) in
            if error == nil {
                if user_exist! {
                    self.dismiss(animated: true, completion: {
                        PushNotificationHelper.registerPushNotifications()
                    })
                } else {
                    // Show activity indicator
                    self.startAnimating(activityIndicatorView: self.activityIndicatorView)
                    
                    // Fetch getWebUserAPI
                    let invited_code = UserDefaults.standard.string(forKey: "invited_code") ?? "0"
                    RegistrationHelper.getWebUser(invited_code, user_id: user.id, id_type: user.id_type!, completion: { (error, user) in
                        
                        // Dismiss activity indicator
                        self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
                        
                        // Deal with response
                        if error == nil {
                            self.user = user
                            self.performSegue(withIdentifier: "presentRegistrationNC", sender: self)
                        } else {
                            self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "請輸入邀請碼！")
                            self.present(self.invited_codeView, transition: .scale)
                        }
                    })
                }
            } else {
                print("SignInVC: \(#function) fail because \(error.debugDescription)")
            }
        }
    }
    
    func loginProvider(loginProvider: LoginProvider, didError error: Error?) {
        print("SignInVC: log in \(loginProvider.rawValue) failed because \(error.debugDescription)")
    }
    
    func loginProvider(didCancel loginProvider: LoginProvider) {
        print("SignInVC: log in \(loginProvider.rawValue) canceled")
    }
    
    
    
    // MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "presentRegistrationNC":
            guard let registrationNC = segue.destination as? UINavigationController else {
                fatalError("\(segue.identifier!) segue's destination ERROR! Destination: \(segue.destination)")
            }
            let basicInfoVC = registrationNC.viewControllers.first as! BasicInfoViewController
            basicInfoVC.user = self.user
            
        default:
            print("SignInVC: Unexpected segue identifier!")
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func checkInvited_code(on invited_code: String) {
        
        // Clear error_label
        self.updateErrorMsgLabel(self.error_msgLabel, error: false)
        
        // Local check
        if invited_code.isEmpty {
            self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "邀請碼有誤！")
            return
        }
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        RegistrationHelper.checkInvitedCodeExist(invited_code) { (error, invited_codeStatus) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Deal with response
            if error == nil {
                self.handleInvited_CodeStatus(invited_codeStatus!, invited_code: invited_code)
            } else {
                self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "網路錯誤！")
                print("SignInVC ERROR: check invited_code fail because \(error.debugDescription)")
            }
        }
    }
    
    /* Handle invited code status:
          applicant | user
         1.   v     |  v   (registered) -> user should not enter the code, should press skip -> don't dismiss popup and show error message
         2.   v     |  x   (unregistered) -> first-time user -> save invited code into UserDefaults, dismiss invited_code view
         3.   x     |  x   (not_exist) -> don't dismiss and show error message
         4.   x     |  v   (error) -> don't dismiss and show error message
    */
    private func handleInvited_CodeStatus(_ invited_codeStatus: RegistrationHelper.InvitedCodeStatus, invited_code: String) {
        switch invited_codeStatus {
        case .registered:
            self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "已經是使用者，請跳過輸入!")
            
        case .unregistered:
            self.updateErrorMsgLabel(self.error_msgLabel, error: false)
            UserDefaults.standard.set(self.invited_codeTextField.text, forKey: "invited_code")
            self.dismiss(self.invited_codeView, transition: .scale)
            
        case .not_exist:
            self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "邀請碼有誤！")
            
        case .error:
            self.updateErrorMsgLabel(self.error_msgLabel, error: true, message: "發生不明的錯誤！")
        }
    }
    
    private func updateErrorMsgLabel(_ error_label: UILabel, error: Bool, message: String = "") {
        DispatchQueue.main.async {
            if error {
                // Show error_label
                error_label.isHidden = false
                error_label.text = message
            } else {
                // Hide error_label
                error_label.isHidden = true
                error_label.text = ""
            }
        }
    }
}

