//
//  DrawCardViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/15.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDCAlertView

class DrawCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CardStatusDelegate {

    // MARK: - Outlets
    @IBOutlet weak var cardView: UIViewX!
    @IBOutlet weak var profile_picImageView: UIImageViewX!
    @IBOutlet weak var english_nameLabel: UILabel!
    @IBOutlet weak var chinese_nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var satisfied_projLabel: UILabel!
    @IBOutlet weak var cop_topicLabel: UILabel!
    @IBOutlet weak var eduLabel: UILabel!
    @IBOutlet weak var company_nameLabel: UILabel!
    @IBOutlet weak var selfintroLabel: UILabel!
    @IBOutlet weak var skill_fieldCollectionView: UICollectionView!
    @IBOutlet weak var interested_fieldCollectionView: UICollectionView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var invitation_sentLabel: UILabel!
    
    @IBOutlet weak var comming_soonView: UIViewX!
    @IBOutlet weak var count_downLabel: UILabel!
    
    @IBOutlet weak var draw_cardView: UIViewX!
    
    let activityIndicatorView = UIActivityIndicatorView()
    weak var clockShapeLayer: CAShapeLayer!
    
    
    // MARK: - Properties
    var count_downTimer = Timer()
    var timerIsRunning = false
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        self.skill_fieldCollectionView.delegate = self
        self.skill_fieldCollectionView.dataSource = self
        self.interested_fieldCollectionView.delegate = self
        self.interested_fieldCollectionView.dataSource = self
        
        
        // Functions:
        self.configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        
        // Functions
        CardHelper.getCardStatus(user_id, delegate: self)
    }
    
    
    
    // MARK: - Actions
    @IBAction func skip(_ sender: UIButton) {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        self.ignore(from: user_id)
    }
    
    @IBAction func agreeTBFriends(_ sender: UIButton) {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        self.sendInvitation(from: user_id)
    }
    
    @IBAction func drawCard(_ sender: UIButton) {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        self.drawCard(user_id: user_id)
    }
    
    
    
    // MARK: - CollectionView DataSourece Functions
    var skill_fieldDataSource = [String]()
    var interested_fieldDataSource = [String]()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 100: // skill_fields
            return self.skill_fieldDataSource.count
        case 101: // interested_fields
            return self.interested_fieldDataSource.count
        default:
            print("DrawCardVC: Unexpected collection view")
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
            print("DrawCardVC: Unexpected collection view")
            
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: "skill_fieldTagCell", for: indexPath) as! TagCollectionViewCell
            tagCell.titleLabel.text = self.skill_fieldDataSource[indexPath.item]
            return tagCell
        }
    }
    
    
    // MARK: - Card Status Delegate Functions
    func cardStatusHandler(_ status: CardStatus) {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        switch status {
        case .notDrawn:
            self.presentDrawCardView()
            
        case .userDidNothing:
            self.presentCardWithBttn()
            self.getCard(user_id)
            
        case .userAcceptFriend:
            self.presentCardWithLabel()
            self.getCard(user_id)
            
        case .userRejectFriend:
            self.presentCardComingSoonView()
            
        case .error:
            self.presentCardComingSoonView()
        }
    }
    

    // MARK: - Helper Functions
    private func getCard(_ user_id: String) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        CardHelper.getCard(user_id) { (error, user) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Deal with response
            if error == nil {
                self.showDetail(of: user!)
            } else {
                // ** have to present sth indicating error
                print("DrawCardVC: get card fail because \(error.debugDescription)")
            }
        }
    }
    
    // Button Tapped Functions:
    private func sendInvitation(from user_id: String) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        CardHelper.sendInvitaion(user_id) { (error, message) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Deal with response
            if error == nil {
                self.cardStatusHandler(.userAcceptFriend)
                if message!.contains("these two user become friends") {
                    AlertController.alert(withTitle: "恭喜！", message: "你們成為好友了", actionTitle: "好")
                } else {
                    // message: "waiting for another user accepts the invitation!"
                }
            } else {
                print("DrawCardVC: \(#function) fail because: \(error.debugDescription)")
            }
        }
    }
    
    private func ignore(from user_id: String) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        CardHelper.ignore(user_id) { (error, _) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Deal with response
            if error == nil {
                self.cardStatusHandler(.userRejectFriend)
                
            } else {
                print("DrawCardVC: \(#function) fail because: \(error.debugDescription)")
            }
        }
    }
    
    private func drawCard(user_id: String) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        CardHelper.drawCard(user_id) { (error, _) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Deal with response
            if error == nil {
                self.cardStatusHandler(.userDidNothing)
                
            } else {
                print("DrawCardVC: \(#function) fail because: \(error.debugDescription)")
            }
        }
    }
    
    // Card View Functions:
    private func presentDrawCardView() {
        self.cardView.isHidden = true
        self.comming_soonView.isHidden = true
        
        self.draw_cardView.isHidden = false
        self.stopCountDownTimer()
    }
    
    private func presentCardComingSoonView() {
        self.cardView.isHidden = true
        self.draw_cardView.isHidden = true
        
        self.comming_soonView.isHidden = false
        self.startCountDownTimer()
    }
    
    private func presentCardWithBttn() {
        self.cardView.isHidden = false
        self.bottomStackView.isHidden = false
        
        self.invitation_sentLabel.isHidden = true
        self.comming_soonView.isHidden = true
        self.draw_cardView.isHidden = true
        self.stopCountDownTimer()
    }
    
    private func presentCardWithLabel() {
        self.cardView.isHidden = false
        self.invitation_sentLabel.isHidden = false
        
        self.bottomStackView.isHidden = true
        self.draw_cardView.isHidden = true
        self.comming_soonView.isHidden = true
        self.stopCountDownTimer()
    }
    
    private func configureViews() {
        
        // Invitation_sent Label
        self.cardView.addSubview(self.invitation_sentLabel)
        self.invitation_sentLabel.frame = self.bottomStackView.frame
        self.invitation_sentLabel.isHidden = true
        
        // Coming Soon View
        self.view.addSubview(self.comming_soonView)
        self.comming_soonView.center = self.view.center
        self.comming_soonView.frame.size.width = self.cardView.frame.width
        self.comming_soonView.frame.size.height = self.comming_soonView.frame.width / 69 * 80
        self.comming_soonView.isHidden = true
        self.addCircularProgressBar(on: self.comming_soonView, linkedToTime: true)
        
        // Draw Card View
        self.view.addSubview(self.draw_cardView)
        self.draw_cardView.center = self.view.center
        self.draw_cardView.frame.size.width = self.cardView.frame.width
        self.draw_cardView.frame.size.height = self.draw_cardView.frame.width / 69 * 80
        self.draw_cardView.isHidden = true
        self.addCircularProgressBar(on: self.draw_cardView, linkedToTime: false)
    }
    
    private func addCircularProgressBar(on view: UIView, linkedToTime: Bool) {
        let circleCenter = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: 140, startAngle: -.pi/2, endAngle: .pi * 3 / 2, clockwise: true)
        
        let trackShapeLayer = self.createCircleShapeLayer(circlePath, stokeColor: Junction.Color.grey, strokeEnd: 1, needShadow: false)
        view.layer.addSublayer(trackShapeLayer)
        
        if linkedToTime {
            self.clockShapeLayer = self.createCircleShapeLayer(circlePath, stokeColor: Junction.Color.light_blue, strokeEnd: 0, needShadow: false)
            view.layer.addSublayer(self.clockShapeLayer)
        } else {
            let circleShapeLayer = self.createCircleShapeLayer(circlePath, stokeColor: Junction.Color.light_blue, strokeEnd: 1, needShadow: false)
            view.layer.addSublayer(circleShapeLayer)
        }
    }
    
    private func createCircleShapeLayer(_ circlePath: UIBezierPath, stokeColor: UIColor, strokeEnd: CGFloat, needShadow: Bool) -> CAShapeLayer {
        let circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = circlePath.cgPath
        circleShapeLayer.strokeEnd = strokeEnd
        circleShapeLayer.strokeColor = stokeColor.cgColor
        circleShapeLayer.lineWidth = 30
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        
        if needShadow {
            circleShapeLayer.shadowColor = UIColor.black.cgColor
            circleShapeLayer.shadowOpacity = 0.5
            circleShapeLayer.shadowOffset = CGSize(width: 3, height: 3)
        }
        
        return circleShapeLayer
    }
    
    private func showDetail(of card: User) {
        DispatchQueue.main.async {
            self.profile_picImageView.image = card.profile_pic
            self.english_nameLabel.text = card.english_name
            self.chinese_nameLabel.text = "\(card.chinese_name ?? "")/\(card.gender?.rawValue ?? "")"
            self.titleLabel.text = card.work_exps?.first?.job_title
            self.satisfied_projLabel.text = card.satisfied_projects
            self.cop_topicLabel.text = card.interested_cop_topics
            self.eduLabel.text = card.highest_edu
            self.company_nameLabel.text = card.work_exps?.first?.company
            self.selfintroLabel.text = card.selfintro
            
            self.skill_fieldDataSource = card.skill_fields.ratingOver3()
            self.interested_fieldDataSource = card.interested_fields.ratingOver3()
            self.refreshCollectionView()
        }
    }
    
    private func refreshCollectionView() {
        self.skill_fieldCollectionView.reloadData()
        self.interested_fieldCollectionView.reloadData()
    }
    
    // Timer Functions:
    private func startCountDownTimer() {
        if !self.timerIsRunning {
            self.count_downTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountDownLabel), userInfo: nil, repeats: true)
            
            self.timerIsRunning = true
        }
    }
    
    private func stopCountDownTimer() {
        if self.timerIsRunning {
            self.count_downTimer.invalidate()
            
            self.timerIsRunning = false
        }
    }
    
    @objc private func updateCountDownLabel() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let dateAtMidnight = calendar.startOfDay(for: tomorrow)
        let secondsToMid = lrint(dateAtMidnight.timeIntervalSinceNow)
        let hours = secondsToMid / 3600
        let minutes = secondsToMid / 60 % 60
        self.count_downLabel.text = String(format: "%02i:%02i", hours, minutes)
        
        // Update circular progress bar
        self.clockShapeLayer.strokeEnd = 1 - CGFloat(secondsToMid / 60) / 1440
    }
 }
