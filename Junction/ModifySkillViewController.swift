//
//  ModifySkillViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2018/2/9.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit

class ModifySkillViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ValidatorProtocol {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextFieldX!
    @IBOutlet weak var company_nameTextField: UITextFieldX!
    @IBOutlet weak var job_typeTextField: UITextFieldX!
    @IBOutlet weak var industry_typeTextField: UITextFieldX!
    @IBOutlet weak var career_lengthTextField: UITextFieldX!
    @IBOutlet weak var introTextView: UITextViewX!
    @IBOutlet weak var skill_fieldTagsCollectionView: UICollectionViewX!
    @IBOutlet weak var nextBttn: UIButtonX!
    @IBOutlet weak var tag_creatorView: UIView!
    @IBOutlet weak var tag_creatorTextField: UITextField!
    var job_typePickerView: UIPickerView!
    var industry_typePickerView: UIPickerView!
    
    
    // MARK: - Constants
    let pickerViewCellId = "job_typeCell"
    
    
    // MARK: - Properties
    var user: User?
    let validator = Validator()
    var selectedJob_type: Set<String> = []
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.job_typePickerView = UIPickerView()
        let pickerViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePickerTap(_:)))
        pickerViewTapGestureRecognizer.numberOfTapsRequired = 1
        self.job_typePickerView.addGestureRecognizer(pickerViewTapGestureRecognizer)
        
        self.industry_typePickerView = UIPickerView()
        self.skill_fieldTagsCollectionView.allowsMultipleSelection = true
        
        // Delegates:
        self.titleTextField.delegate = self
        self.company_nameTextField.delegate = self
        self.job_typeTextField.delegate = self
        self.industry_typeTextField.delegate = self
        self.career_lengthTextField.delegate = self
        self.introTextView.delegate = self
        self.skill_fieldTagsCollectionView.delegate = self
        self.skill_fieldTagsCollectionView.dataSource = self
        self.job_typePickerView.delegate = self
        self.job_typePickerView.dataSource = self
        self.industry_typePickerView.delegate = self
        self.industry_typePickerView.dataSource = self
        pickerViewTapGestureRecognizer.delegate = self
        
        
        // Functions:
        self.setValue(from: self.user)
        self.updateNextBttnState()
    }
    
    deinit {
        print("ModifySkillVC: deinit")
    }
    
    
    
    
    // MARK: - Actions
    @IBAction func resignFirstResponder(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToM_SkillVC(sender: UIStoryboardSegue) {
        self.setValue(from: self.user)
    }
    
    @IBAction func createTag(_ sender: UIButton) {
        
        // Check textField text
        if !self.tag_creatorTextField.text!.isEmpty {

            // Insert tag
            let insertionIndex = self.skill_fieldDataSource.count - 1
            self.skill_fieldDataSource.insert(self.tag_creatorTextField.text!, at: insertionIndex)
            let insertionIndexPath = IndexPath(item: insertionIndex, section: 0)
            self.skill_fieldTagsCollectionView.insertItems(at: [insertionIndexPath])
            
            // Select the inserted tag
            let cell = self.skill_fieldTagsCollectionView.cellForItem(at: insertionIndexPath)!
            self.skill_fieldTagsCollectionView.select(cell: cell, at: insertionIndexPath, scrollPosition: .init(rawValue: 0))
            
            // Clear textField
            self.tag_creatorTextField.text = nil
            
            self.dismiss(self.tag_creatorView, transition: .scale)
        }
    }
    
    @IBAction func cancelCreate_tag(_ sender: UIButton) {
        self.dismiss(self.tag_creatorView, transition: .scale)
    }
    
    
    // MARK: - TextField Delegate Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.nextBttn.isEnabled = false
        
        // Show picker view
        switch textField {
        case self.job_typeTextField:
            self.job_typePickerView.reloadAllComponents()
            textField.inputView = self.job_typePickerView
            
        case self.industry_typeTextField:
            self.industry_typePickerView.reloadAllComponents()
            textField.inputView = self.industry_typePickerView
            
        default:
            print("ModifySkillVC: \(#function) textField don't need pickerView")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validate(textField)
        self.updateNextBttnState()
    }
    
    
    
    // MARK: - TextView Delegate Functions
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.nextBttn.isEnabled = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.validate(textView)
        
        // Hide error_image when editing
        if let errorImageView = textView.viewWithTag(Validator.errorImageViewTag) {
            errorImageView.isHidden = !textView.text.isEmpty
        }
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        self.validate(textView)
        self.updateNextBttnState()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Dismiss keyboard when return/done key is tapped
        if (text == "\n") {
            self.view.endEditing(true)
            return false
            
        } else {
            return true
        }
    }
    
    
    
    // MARK: - Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    // MARK: - PickerView DataSource Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.job_typePickerView:
            return JobType.allCases.count
        case self.industry_typePickerView:
            return IndustryType.allCases.count
        default:
            return 0
        }
    }
    
    
    
    // MARK: - PickerView Delegate Functions
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        switch pickerView {
        case self.job_typePickerView:
            let cell = UITableViewCell(style: .default, reuseIdentifier: self.pickerViewCellId)
            cell.backgroundColor = UIColor.clear
            cell.bounds = CGRect(x: 0, y: 0, width: cell.frame.size.width - 20, height: 44)
            cell.textLabel?.font = Junction.Font.pickerViewFont
            cell.textLabel?.text = JobType.allCases[row].rawValue
            
            if self.selectedJob_type.contains(cell.textLabel!.text!) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
            
        case self.industry_typePickerView:
            let label = UILabel()
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = Junction.Font.pickerViewFont
            label.text = IndustryType.allCases[row].rawValue
            
            return label
            
        default:
            return UIView()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.job_typePickerView:
            break
            
        case self.industry_typePickerView:
            if self.industry_typeTextField.isEditing {
                self.industry_typeTextField.text = IndustryType.allCases[row].rawValue
            }
        default:
            print("ModifySkillVC: \(#function) unexpected pickerView")
        }
    }
    
    @objc private func handlePickerTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let rowHeight = self.job_typePickerView.rowSize(forComponent: 0).height
            let selectedRowFrame = self.job_typePickerView.bounds.insetBy(dx: 0, dy: (self.job_typePickerView.frame.height - rowHeight) / 2)
            let isTappedOnSelectedRow = selectedRowFrame.contains(sender.location(in: self.job_typePickerView))
            
            if isTappedOnSelectedRow {
                let selectedRowIndex = self.job_typePickerView.selectedRow(inComponent: 0)
                let cell = self.job_typePickerView.view(forRow: selectedRowIndex, forComponent: 0) as! UITableViewCell
                
                if self.selectedJob_type.contains(cell.textLabel!.text!) {
                    // should deselect
                    cell.accessoryType = .none
                    self.selectedJob_type.remove(cell.textLabel!.text!)
                    
                } else {
                    // should select
                    cell.accessoryType = .checkmark
                    self.selectedJob_type.insert(cell.textLabel!.text!)
                }
                self.job_typeTextField.text = self.selectedJob_type.joined(separator: "、")
                self.job_typePickerView.dataSource = self
            }
        }
    }
    
    
    
    
    // MARK: - Collection DataSource Functions
    var skill_fieldDataSource = ProfessionalCapability.all
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skill_fieldDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "skillTagCell", for: indexPath) as! TagCollectionViewCell
        tagCell.titleLabel.text = skill_fieldDataSource[indexPath.item]
        
        
        switch collectionView {
        case is UICollectionViewX:
            let collectionViewX = collectionView as! UICollectionViewX
            
            // Preselect the cell
            collectionViewX.preselect(items: self.user?.skill_fields.toChineseKeyDict(), at: tagCell, indexPath)
            
        default:
            print("ModifySkillVC: cellForItemAt() unexpected collectionView.")
        }
        
        return tagCell
    }
    
    
    // MARK: - CollectionView Delegate Functions
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            
            self.skill_fieldTagsCollectionView.changeUI(for: tagCell, selected: true)
            self.user?.skill_fields.updateRating(for: tagCell, isIncrease: true)
            
        default:
            print("ModifySkillVC: didSelectItemAt() unexpected cell.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        switch cell {
        case is TagCollectionViewCell:
            let tagCell = cell as! TagCollectionViewCell
            
            self.skill_fieldTagsCollectionView.changeUI(for: tagCell, selected: false)
            self.user?.skill_fields.updateRating(for: tagCell, isIncrease: false)
            
        default:
            print("ModifySkillVC: didDeselectItemAt() unexpected cell.")
        }
    }
 
    
    
    
    
    // MARK: - Validator Functions
    func validate(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            self.validator.changeTextFieldView(ifError: true, textField)
        } else {
            self.validator.changeTextFieldView(ifError: false, textField)
        }
    }
    
    func validate(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.validator.changeTextViewView(ifError: true, textView)
        } else {
            self.validator.changeTextViewView(ifError: false, textView)
        }
    }
    
    
    
    // MARK: - Navigation Delegate Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showM_InterestVC":
            guard let m_interestVC = segue.destination as? ModifyInterestViewController else {
                fatalError("\(segue.identifier!) segue's destination ERROR! Destination: \(segue.destination)")
            }
            m_interestVC.user = self.update(user: self.user)

        case "unwindToM_BasicInfoVC":
            guard let m_basicInfoVC = segue.destination as? ModifyBasicInfoViewController else {
                fatalError("\(segue.identifier!) segue's destination ERROR! Destination: \(segue.destination)")
            }
            m_basicInfoVC.user = self.update(user: self.user)
            
        default:
            print("ModifySkillVC: Unexpected segue identifier!")
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func setValue(from user: User?) {
        guard let user = user else {
            print("ModifySkillVC: \(#function) has nil user")
            return
        }
        
        DispatchQueue.main.async {
            let currentPosition = user.work_exps?.first
            self.titleTextField.text = currentPosition?.job_title
            self.company_nameTextField.text = currentPosition?.company
            self.job_typeTextField.text = currentPosition?.job_type?.joined(separator: "、")
            self.industry_typeTextField.text = currentPosition?.industry_type
            self.career_lengthTextField.text = "\(currentPosition?.career_length ?? 0)"
            self.introTextView.text = self.user?.selfintro
            
            // preselect job_typePickerView items
            self.selectedJob_type = currentPosition?.job_type ?? []
            
            self.updateNextBttnState()
        }
    }
    
    private func update(user: User?) -> User? {
        var user = user
        let work_exps = [WorkExperience(
            company: self.company_nameTextField.text,
            job_title: self.titleTextField.text,
            job_type: self.selectedJob_type,
            industry_type: self.industry_typeTextField.text,
            career_length: Int(self.career_lengthTextField.text!))]
        
        user?.work_exps = work_exps
        user?.selfintro = self.introTextView.text
        // skill_fields are updated when select/deselect
        
        return user
    }
    
    // Disable the Next button if text field is empty.
    private func updateNextBttnState() {
        let titleText = self.titleTextField.text!
        let company_nameText = self.company_nameTextField.text!
        let job_typeText = self.job_typeTextField.text!
        let industry_typeText = self.industry_typeTextField.text!
        let career_lengthText = self.career_lengthTextField.text!
        let introText = self.introTextView.text!
        
        self.nextBttn.isEnabled =
            !titleText.isEmpty &&
            !company_nameText.isEmpty &&
            !job_typeText.isEmpty &&
            !industry_typeText.isEmpty &&
            !career_lengthText.isEmpty &&
            !introText.isEmpty
    }
}
