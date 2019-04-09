//
//  CardPopUpViewController.swift
//  Alamofire
//
//  Created by 林晏竹 on 2018/1/31.
//

import UIKit

class CardPopUpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var profile_picImageView: UIImageViewX!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var satisfied_projLabel: UILabel!
    @IBOutlet weak var cop_topicLabel: UILabel!
    @IBOutlet weak var skill_fieldCollectionView: UICollectionView!
    @IBOutlet weak var interested_fieldCollectionView: UICollectionView!

    var activityIndicatorView = UIActivityIndicatorView()
    
    
    
    // MARK: - Properties
    var friend_id: String?
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        self.skill_fieldCollectionView.delegate = self
        self.skill_fieldCollectionView.dataSource = self
        self.interested_fieldCollectionView.delegate = self
        self.interested_fieldCollectionView.dataSource = self
        
        // Functions
        self.loadCardDetail(for: self.friend_id ?? "0")
    }
    
    
    
    
    
    // MARK: - CollectionView DataSource Functions
    var skill_fieldDataSource = [String]()
    var interested_fieldDataSource = [String]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 100: // skill_fields
            return self.skill_fieldDataSource.count
        case 101: // interested_fields
            return self.interested_fieldDataSource.count
        default:
            print("CardPopUpVC: Unexpected collection view")
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
            print("CardPopUpVC: Unexpected collection view")
            
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
                print("CardPopUpVC: load user detail fail because \(error.debugDescription)")
            }
        }
    }
    
    private func showDetail(of card: User) {
        DispatchQueue.main.async {
            self.profile_picImageView.image = card.profile_pic
            self.nameLabel.text = "\(card.chinese_name ?? "")/\(card.english_name ?? "")"
            self.titleLabel.text = card.work_exps?.first?.job_title
            self.satisfied_projLabel.text = card.satisfied_projects
            self.cop_topicLabel.text = card.interested_cop_topics
            
            self.skill_fieldDataSource = card.skill_fields.ratingOver3()
            self.interested_fieldDataSource = card.interested_fields.ratingOver3()
            self.refreshCollectionView()
        }
    }
    
    private func refreshCollectionView() {
        self.skill_fieldCollectionView.reloadData()
        self.interested_fieldCollectionView.reloadData()
    }
}
