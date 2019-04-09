//
//  ModifyInterestViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/14.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import SDCAlertView

class ModifyInterestViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var satisfied_projectTextView: UITextView!
    @IBOutlet weak var cop_topicTextView: UITextView!
    @IBOutlet weak var interested_fieldTagsCollectionView: UICollectionViewX!
    @IBOutlet weak var finishBttn: UIButton!
    @IBOutlet weak var tag_creatorView: UIView!
    @IBOutlet weak var tag_creatorTextField: UITextField!
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    // MARK: - Properties
    var user: User?
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interested_fieldTagsCollectionView.allowsMultipleSelection = true
        
        // Delegates:
        self.satisfied_projectTextView.delegate = self
        self.cop_topicTextView.delegate = self
        self.interested_fieldTagsCollectionView.delegate = self
        self.interested_fieldTagsCollectionView.dataSource = self
        
        
        // Functions:
        self.setValue(from: self.user)
    }
    
    deinit {
        print("ModifyInterestVC: deinit")
    }
    
    
    
    
    // MARK: - Actions
    @IBAction func finishBttnPressed(_ sender: UIButton) {
        self.sendToServer(self.update(user: self.user))
    }
    
    @IBAction func resignFirstResponder(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func createTag(_ sender: UIButton) {
        
        // Check textField text
        if !self.tag_creatorTextField.text!.isEmpty {
            
            // Insert tag
            let insertionIndex = self.interested_fieldDataSource.count - 1
            self.interested_fieldDataSource.insert(self.tag_creatorTextField.text!, at: insertionIndex)
            let insertionIndexPath = IndexPath(item: insertionIndex, section: 0)
            self.interested_fieldTagsCollectionView.insertItems(at: [insertionIndexPath])
            
            // Select the inserted tag
            let cell = self.interested_fieldTagsCollectionView.cellForItem(at: insertionIndexPath)!
            self.interested_fieldTagsCollectionView.select(cell: cell, at: insertionIndexPath, scrollPosition: .init(rawValue: 0))
            
            // Clear textField
            self.tag_creatorTextField.text = nil
            
            self.dismiss(self.tag_creatorView, transition: .scale)
        }
    }
    
    @IBAction func cancelCreate_tag(_ sender: UIButton) {
        self.dismiss(self.tag_creatorView, transition: .scale)
    }
    
    
    
    // MARK: - TextField Delegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    // MARK: - TextView Delegate Functions
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Dismiss keyboard when return/done key is tapped
        if (text == "\n") {
            self.view.endEditing(true)
            return false
            
        } else {
            return true
        }
    }
    
    
    // MARK: - CollectionView DataSource Functions
    var interested_fieldDataSource = ProfessionalCapability.all
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interested_fieldDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "fieldTagCell", for: indexPath) as! TagCollectionViewCell
        tagCell.titleLabel.text = interested_fieldDataSource[indexPath.item]
        
        switch collectionView {
        case is UICollectionViewX:
            let collectionViewX = collectionView as! UICollectionViewX
            
            // Preselect the cell
            collectionViewX.preselect(items: self.user?.interested_fields.toChineseKeyDict(), at: tagCell, indexPath)
            
        default:
            print("ModifyInterestVC: cellForItemAt() unexpected collectionView.")
        }
        
        return tagCell
    }
    
    
    
    // MARK: - CollectionView Delegate Functions
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            
            self.interested_fieldTagsCollectionView.changeUI(for: tagCell, selected: true)
            self.user?.interested_fields.updateRating(for: tagCell, isIncrease: true)
            
        default:
            print("ModifyInterestVC: didselectItemAt() unexpected cell.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            
            self.interested_fieldTagsCollectionView.changeUI(for: tagCell, selected: false)
            self.user?.interested_fields.updateRating(for: tagCell, isIncrease: false)
            
        default:
            print("ModifyInterestVC: didDeselectItemAt() unexpected cell.")
        }
    }
    
    

    // MARK: - Navigation Delegate Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "unwindToM_SkillVC":
            guard let m_skillVC = segue.destination as? ModifySkillViewController else {
                fatalError("\(segue.identifier!) segue's destination ERROR! Destination: \(segue.destination)")
            }
            m_skillVC.user = self.update(user: self.user)
            
        default:
            print("ModifyInterestVC: Unexpected segue identifier!")
        }
    }
    
    
    
    
    
    // MARK: - Helper Functions
    private func setValue(from user: User?) {
        guard let user = user else {
            print("ModifyInterestVC: setValue(from:) has nil user")
            return
        }
        
        DispatchQueue.main.async {
            self.satisfied_projectTextView.text = user.satisfied_projects
            self.cop_topicTextView.text = user.interested_cop_topics
        }
    }
    
    private func update(user: User?) -> User? {
        var user = user
        user?.satisfied_projects = self.satisfied_projectTextView.text
        user?.interested_cop_topics = self.cop_topicTextView.text
        // interested_fields are updated when select/deselect
        
        return user
    }
    
    // Send user data to server
    private func sendToServer(_ user: User?) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        guard let myuser = user else {
            print("ModifyInterestVC ERROR: user is nil")
            return
        }
        UserHelper.putUser(myuser, user_id: user_id) { (error) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Check if fetching has error
            if error == nil {
                // Dismiss registration pages
                self.navigationController?.popToRootViewController(animated: true)
                
            } else {
                // Pop up alert
                AlertController.alert(withTitle: "哎呀！", message: "發生不明的錯誤。", actionTitle: "確定")
                print("ModifyInterestVC ERROR: \(error.debugDescription)")
            }
        }
    }
}
