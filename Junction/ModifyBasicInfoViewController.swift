//
//  ModifyBasicInfoViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/8.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit

class ModifyBasicInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidatorProtocol {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageViewX!
    @IBOutlet weak var chinese_nameTextField: UITextFieldX!
    @IBOutlet weak var english_nameTextField: UITextFieldX!
    @IBOutlet weak var genderTextField: UITextFieldX!
    @IBOutlet weak var bachelorTextField: UITextFieldX!
    @IBOutlet weak var masterTextField: UITextFieldX!
    @IBOutlet weak var phone_numberTextField: UITextFieldX!
    @IBOutlet weak var emailTextField: UITextFieldX!
    @IBOutlet weak var nextBttn: UIButtonX!
    @IBOutlet weak var scrollview: UIScrollView!
    var genderPickerView: UIPickerView!
    var activeTextField: UITextField?
    

    
    
    // MARK: - Properties
    var user: User?
    var photoHasSelected = false
    let imagePicker = UIImagePickerController()
    let validator = Validator()
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genderPickerView = UIPickerView()
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        
        // Delegates
        self.imagePicker.delegate = self
        self.chinese_nameTextField.delegate = self
        self.english_nameTextField.delegate = self
        self.genderTextField.delegate = self
        self.bachelorTextField.delegate = self
        self.masterTextField.delegate = self
        self.phone_numberTextField.delegate = self
        self.emailTextField.delegate = self
        self.genderPickerView.dataSource = self
        self.genderPickerView.delegate = self
        
        
        // Functions
        UserHelper.getUser(user_id) { (error, user) in
            if error == nil {
                self.user = user
                self.setValue(from: user)
            }
        }
        self.updateNextBttnState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterKeyboardNotifications()
    }
    
    deinit {
        print("ModifyBasicInfoVC: deinit")
    }
    
    
    
    // MARK: - Actions
    @IBAction func resignFirstResponder(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func showImagePickerController(_ sender: UITapGestureRecognizer) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelModify(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func unwindToM_BasicInfoVC(sender: UIStoryboardSegue) {
        self.setValue(from: self.user)
    }
    
    
    
    // MARK: - PickerView Delegate Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.genderPickerView:
            return Gender.allCases.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.genderPickerView:
            return Gender.allCases[row].rawValue
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.genderPickerView:
            if self.genderTextField.isEditing {
                self.genderTextField.text = Gender.allCases[row].rawValue
            }
        default:
            print("ModifyBasicInfoVC ERROR: Unexpected pickerView")
        }
    }
    
    
    
    // MARK: - TextField Delegate Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        self.nextBttn.isEnabled = false
        
        // Show picker view
        switch textField.tag {
        case 999: // 性別
            self.genderPickerView.reloadAllComponents()
            textField.inputView = self.genderPickerView

        default:
            print("ModifyBasicInfoVC: textField don't need pickerView")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
        self.validate(textField)
        self.updateNextBttnState()
    }
    
    
    
    
    // MARK: - Keyboard vs Scrollview Functions
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTextField(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollBack(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func scrollToTextField(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.size {
            
            // Adjust the place to scroll when keyboard appears
            let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.scrollview.contentInset = contentInsets
            self.scrollview.scrollIndicatorInsets = contentInsets
            
            // Scroll to textfield
            var viewAfterKBShown: CGRect = self.view.frame
            viewAfterKBShown.size.height -= keyboardSize.height
            if let myActiveTextField = self.activeTextField {
                let right_bottomPoint = CGPoint(x: myActiveTextField.frame.maxX, y: myActiveTextField.frame.maxY)
                if (!viewAfterKBShown.contains(right_bottomPoint)){
                    self.scrollview.scrollRectToVisible(myActiveTextField.frame, animated: true)
                }
            }
        } else {
            print("ERROR: ModifyBasicInfoVC cannot get keyboard size")
        }
    }
    
    @objc private func scrollBack(_ notification: NSNotification) {
        
        // Adjust the place to scroll when keyboard hides
        let contentInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
        
        // Scroll to top
        self.scrollview.setContentOffset(.zero, animated: true)
    }
    
    
    
    
    // MARK: - ImagePickerController Delegate Functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = pickedImage
            self.photoHasSelected = true
        } else {
            print("ModifyBasicInfoVC: PickedImage is nil")
            self.photoHasSelected = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        self.photoHasSelected = false
    }
    
    
    
    
    // MARK: - Validation Functions
    func validate(_ textField: UITextField) {
        
        // Phone_number, master textField don't need validation
        if textField === self.phone_numberTextField { return }
        if textField === self.masterTextField { return }
        
        if textField.text?.isEmpty ?? true {
            
            // TextField text is empty:
            self.validator.changeTextFieldView(ifError: true, textField)
            
        } else if textField === self.emailTextField {
            
            // If email text isn't empty:
            // Check if email text has "@" and are all alphabets/numbers
            if !(textField.text!.isValidEmail) {
                self.validator.changeTextFieldView(ifError: true, textField)
            } else {
                self.validator.changeTextFieldView(ifError: false, textField)
            }
        } else {
            
            // TextField text isn't empty, isn't an email textField
            self.validator.changeTextFieldView(ifError: false, textField)
        }
    }
    
    func validate(_ textView: UITextView) {}
    
    
    
    
    // MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showM_SkillVC":
            guard let m_skillVC = segue.destination as? ModifySkillViewController else {
                fatalError("\(segue.identifier!) segue's destination ERROR! Destination: \(segue.destination)")
            }
            m_skillVC.user = self.update(user: self.user)
            
        default:
            print("ModifyBasicInfoVC: Unexpected segue identifier!")
        }
    }
    
    
    
    
    // MARK: - Helper Functions
    private func setValue(from user: User?) {
        guard let user = user else {
            print("ModifyBasicInfoVC: setValue(from:) has nil user")
            return
        }
        DispatchQueue.main.async {
            self.profileImageView.image = user.profile_pic
            self.chinese_nameTextField.text = user.chinese_name
            self.english_nameTextField.text = user.english_name
            self.genderTextField.text = user.gender?.rawValue
            self.bachelorTextField.text = "\(user.bachelor_school ?? "") \(user.bachelor_major ?? "")"
            self.masterTextField.text = "\(user.master_school ?? "") \(user.master_major ?? "")"
            self.emailTextField.text = user.email
            self.phone_numberTextField.text = user.phone_number
            
            self.updateNextBttnState()
        }
    }
    
    private func update(user: User?) -> User? {
        var user = user
        
        user?.chinese_name = self.chinese_nameTextField.text
        user?.english_name = self.english_nameTextField.text
        user?.gender = Gender(rawValue: self.genderTextField.text!)
        user?.phone_number = self.phone_numberTextField.text
        user?.email = self.emailTextField.text
        // No update for bachelor master field
        
        
        /* Check if user selected a photo or not
         1. yes: set profile_pic to base64
         2. no: remain unchanged
         */
        if photoHasSelected {
            user?.profile_pic_str = self.profileImageView.image?.resized(toWidth: 300)?.encodeToBase64()
        }
        
        return user
    }
    
    // Disable the Next button if text field is empty.
    private func updateNextBttnState() {
        let chinese_nameText = self.chinese_nameTextField.text!
        let english_nameText = self.english_nameTextField.text!
        let genderText = self.genderTextField.text!
        let bachelorText = self.bachelorTextField.text!
        let emailText = self.emailTextField.text!
        
        self.nextBttn.isEnabled =
            !chinese_nameText.isEmpty &&
            !english_nameText.isEmpty &&
            !bachelorText.isEmpty &&
            !genderText.isEmpty &&
            emailText.isValidEmail
    }
}
