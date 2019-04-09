//
//  CardDetailViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/18.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // Mark: - Outlets
    @IBOutlet weak var profile_picImageView: UIImageViewX!
    @IBOutlet weak var english_nameLabel: UILabel!
    @IBOutlet weak var chinese_nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var satisfied_projLabel: UILabel!
    @IBOutlet weak var cop_topicLabel: UILabel!
    @IBOutlet weak var eduLabel: UILabel!
    @IBOutlet weak var company_nameLabel: UILabel!
    @IBOutlet weak var selfintroLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var skill_fieldCollectionView: UICollectionView!
    @IBOutlet weak var interested_fieldCollectionView: UICollectionView!
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    
    // MARK: - Properties
    var user_id: String?
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        self.skill_fieldCollectionView.delegate = self
        self.skill_fieldCollectionView.dataSource = self
        self.interested_fieldCollectionView.delegate = self
        self.interested_fieldCollectionView.dataSource = self
        
        // Functions
        self.loadCardDetail(for: self.user_id ?? "0")
    }
    
    deinit {
        print("CardDetailVC: deinit")
    }
    
    
    // MARK: - Actions
    @IBAction func backToTable(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: CollectionView DataSource Functions
    var skill_fieldDataSource = [String]()
    var interested_fieldDataSource = [String]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 100: // skill_fields
            return self.skill_fieldDataSource.count
        case 101: // interested_fields
            return self.interested_fieldDataSource.count
        default:
            print("CardDetailVC: Unexpected collection view")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 100: // skill_fields
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "skill_fieldTagCell", for: indexPath) as! TagCollectionViewCell
            tagCell.titleLabel.text = self.skill_fieldDataSource[indexPath.item]
            return tagCell
            
        case 101: // interested_fields
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "interested_fieldTagCell", for: indexPath) as! TagCollectionViewCell
            tagCell.titleLabel.text = self.interested_fieldDataSource[indexPath.item]
            return tagCell
            
        default:
            print("CardDetailVC: Unexpected collection view")
            
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "skill_fieldTagCell", for: indexPath) as! TagCollectionViewCell
            tagCell.titleLabel.text = self.skill_fieldDataSource[indexPath.item]
            return tagCell
        }
    }
    
    
    
    
    // MARK: - Helper Functions
    private func loadCardDetail(for user_id: String) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        UserHelper.getUser(user_id) { (error, user) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Check if fetching has error
            if error == nil {
                self.showDetail(of: user!)
            } else {
                print("CardDetailVC: load user detail fail because \(error.debugDescription)")
            }
        }
    }
    
    private func showDetail(of user: User) {
        DispatchQueue.main.async {
            self.profile_picImageView.image = user.profile_pic
            self.english_nameLabel.text = user.english_name
            self.chinese_nameLabel.text = "\(user.chinese_name ?? "")/\(user.gender?.rawValue ?? "")"
            self.titleLabel.text = user.work_exps?.first?.job_title
            self.satisfied_projLabel.text = user.satisfied_projects
            self.cop_topicLabel.text = user.interested_cop_topics
            self.eduLabel.text = user.highest_edu
            self.company_nameLabel.text = user.work_exps?.first?.company
            self.selfintroLabel.text = user.selfintro
            self.emailLabel.text = user.email
            self.phoneLabel.text = user.phone_number
            
            self.skill_fieldDataSource = user.skill_fields.ratingOver3()
            self.interested_fieldDataSource = user.interested_fields.ratingOver3()
            self.refreshCollectionViews()
        }
    }
    
    private func refreshCollectionViews() {
        self.skill_fieldCollectionView.reloadData()
        self.interested_fieldCollectionView.reloadData()
    }
}
