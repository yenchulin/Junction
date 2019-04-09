//
//  ChatRoomViewController.swift
//  Dots
//
//  Created by 林晏竹 on 2018/1/30.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Starscream
import SDCAlertView

class ChatRoomViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, WebSocketAdvancedDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var chatCollectionView: UICollectionView!
    @IBOutlet weak var messageTextField: UITextFieldX!
    @IBOutlet weak var sendMessageBttn: UIButtonX!
    @IBOutlet weak var textBarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var more_actionView: UIView!
    @IBOutlet weak var notificationOnOffBttn: UIButtonX!
    
    
    // MARK: - Constants
//    let chat_roomSocketURL = "ws://54.254.208.10/message/<chatRoom_id>/"
//    let card_tableSocketURL = "ws://54.254.208.10/friendList/<friend_id>/"
    let messageTextConstraintWidth: CGFloat = 250
    
    
    
    // MARK: - Properties
    var chatRoom: ChatRoom?
    var messages = [Message]()
    var chat_roomSocket = WebSocket(url: URL(string: "ws://echo.websocket.org")!)
    var card_tableSocket = WebSocket(url: URL(string: "ws://echo.websocket.org")!)
    var more_actionBarBttnIsTapped = false
    var notificationIsOn = true /* First set in viewWillAppear(_:) -> loadMessages(of:), update in turnOnOffNotification(_:) */
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Socket init
        if let mychatURL = URL(string: Junction.API.chat_roomSocketURL.replacingOccurrences(of: "<chatRoom_id>", with: self.chatRoom?.id ?? "0")),
           let mytableURL = URL(string: Junction.API.card_tableSocketURL.replacingOccurrences(of: "<friend_id>", with: self.chatRoom?.friend.id ?? "0")) {
            
            self.chat_roomSocket = WebSocket(url: mychatURL)
            self.card_tableSocket = WebSocket(url: mytableURL)
            
        } else {
            print("ChatRoomVC: socket url is nil")
        }
        
        
        // Delegates:
        self.chatCollectionView.dataSource = self
        self.chatCollectionView.delegate = self
        self.messageTextField.delegate = self
        self.chat_roomSocket.advancedDelegate = self
        self.card_tableSocket.advancedDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = self.chatRoom?.friend.english_name
        
        // Functions:
        self.registerAppStateNotifications()
        self.registerKeyboardNotifications()
        self.readMessage(of: self.chatRoom?.id ?? "0")
        self.loadMessages(of: self.chatRoom?.id ?? "0") {
            self.chat_roomSocket.connect()
            self.card_tableSocket.connect()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Hide Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Functions:
        self.chat_roomSocket.disconnect()
        self.card_tableSocket.disconnect()
        self.deregisterKeyboardNotifications()
        self.deregisterAppStateNotifications()
    }

    deinit {
        print("ChatRoomVC: deinit")
    }
    
    
    
    // MARK: - Actions
    @IBAction func resignFirstResponder(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if self.messageTextField.text?.isEmpty ?? true {
            return
        }
        
        let sender_id = UserDefaults.standard.string(forKey: "user_id")!
        let message = Message(text: self.messageTextField.text ?? "", send_date: Date(), sender_id: sender_id)
        self.insert(message)
        
        // Clear textfield
        self.messageTextField.text = nil
        
        // Send to Server (chat_room)
        let chat_roomMsgJSON: JSON = ["user_id": message.sender_id,
                                 "time": message.send_date.toStringFromISO(),
                                 "content": message.text]
        self.chat_roomSocket.write(string: "\(chat_roomMsgJSON)")
        
        // Send to Server (card_table)
        let card_tableMsgJSON: JSON = ["user_id": message.sender_id,
                                       "time": message.send_date.toStringFromISO(),
                                       "message_id": self.chatRoom?.id ?? "0"]
        self.card_tableSocket.write(string: "\(card_tableMsgJSON)")
    }
    
    @IBAction func moreBttnTapped(_ sender: UIBarButtonItem) {
        if self.more_actionBarBttnIsTapped {
            self.dismiss(self.more_actionView, transition: .move)
            self.more_actionBarBttnIsTapped = false
        } else {
            self.present(self.more_actionView, transition: .move)
            self.more_actionBarBttnIsTapped = true
        }
    }
    
    /* Turn on(off) notification:
       1. Update button image & title (by configureNotificationBttn(isOn:))
       2. Send the updated status to server
       3. Update global var 'notificationIsOn'
    */
    @IBAction func turnOnOffNotification(_ sender: UIButton) {
        // 1.
        self.configureNotificationBttn(isOn: !self.notificationIsOn)
        
        // 2.
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        let chatRoom_id = self.chatRoom?.id ?? "0"
        PushNotificationHelper.putChatRoomNotification(chatRoom_id, user_id: user_id, isOn: !self.notificationIsOn) { (error) in
            if error != nil {
                print("ChatRoomVC: \(#function) fail becauser \(error.debugDescription)")
            }
        }
        // 3.
        self.notificationIsOn = !self.notificationIsOn
    }
    
    @IBAction func reportUser(_ sender: UIButton) {
        // Show Alert
        let reportAlert = AlertController(title: "警告", message: "您確定要檢舉嗎？")
        let noAction = AlertAction(title: "取消", style: .normal)
        let okAction = AlertAction(title: "是", style: .destructive) { (action) in
            // Fetch API
            let friend_id = self.chatRoom?.friend.id ?? "0"
            UserHelper.reportUser(friend_id) { (error) in
                if error != nil {
                    print("ChatRoomVC: \(#function) fail because \(error.debugDescription)")
                }
            }
        }
        reportAlert.addAction(noAction)
        reportAlert.addAction(okAction)
        reportAlert.present()
    }
    
    
    
    // MARK: - Websocket Functions
    func websocketDidConnect(socket: WebSocket) {
        print("ChatRoomVC: socket connected.")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("ChatRoomVC: socket disconnected because \(error.debugDescription).")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        switch socket {
        case self.chat_roomSocket:
            print("ChatRoomVC: chat_roomSocket received message = \(text).")
            
            let messageJSON = JSON(parseJSON: text)
            let id = messageJSON["content_id"].intValue
            let text = messageJSON["content"].stringValue
            let send_date = messageJSON["time"].stringValue
            let sender_id = messageJSON["user_id"].stringValue
            
            let message = Message(id: id, text: text, send_date: send_date.toDateFromISO()!, sender_id: sender_id, isRead: true)
            let user_id = UserDefaults.standard.string(forKey: "user_id")!
            if message.sender_id != user_id {
                self.insert(message)
            }
        case self.card_tableSocket:
            print("ChatRoomVC: card_tableSocket received message = \(text).")
            
        default:
            print("ChatRoomVC ERROR: receivedMessage() unexpected socket.")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {}
    
    func websocketHttpUpgrade(socket: WebSocket, request: String) {}
    
    func websocketHttpUpgrade(socket: WebSocket, response: String) {}
    
    
    
    // MARK: - CollectionView DataSource Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessageCollectionViewCell
        let message = self.messages[indexPath.item]
        messageCell.messageTextLabel.text = message.text
        messageCell.profile_picImageView.image = self.chatRoom?.friend.profile_pic
        
        
        let estimatedFrame = message.text.rect(withConstrainedWidth: self.messageTextConstraintWidth, font: Junction.Font.chatBubbleFont)
        
        if message.isSender {
            // Bubble on the right, light_blue color
            messageCell.bubbleView.frame = CGRect(x: self.view.frame.width - 8 - (estimatedFrame.width + 20) , y: 0, width: 10 + estimatedFrame.width + 10, height: estimatedFrame.height + 8)
            messageCell.bubbleView.backgroundColor = Junction.Color.light_blue
            messageCell.messageTextLabel.frame = CGRect(x: 10, y: 0, width: estimatedFrame.width, height: estimatedFrame.height + 8)
            
            // Text color is white
            messageCell.messageTextLabel.textColor = UIColor.white
            
            // Profile_pic should hide
            messageCell.profile_picImageView.isHidden = true
            
        } else {
            // Bubble on the left, white color
            messageCell.bubbleView.frame = CGRect(x: 8 + 32 + 8, y: 0, width: 10 + estimatedFrame.width + 10, height: estimatedFrame.height + 8)
            messageCell.bubbleView.backgroundColor = UIColor.white
            messageCell.messageTextLabel.frame = CGRect(x: 10, y: 0, width: estimatedFrame.width, height: estimatedFrame.height + 8)
            
            // Text color is black
            messageCell.messageTextLabel.textColor = Junction.Color.black
            
            // Profile_pic should show
            messageCell.profile_picImageView.isHidden = false
        }
        return messageCell
    }
    
    
    
    // MARK: - CollectionView Delegate FlowLayout Functions
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let messageText = self.messages[indexPath.item].text
        let estimatedFrame = messageText.rect(withConstrainedWidth: self.messageTextConstraintWidth, font: Junction.Font.chatBubbleFont)
        
        return CGSize(width: self.view.frame.width, height: estimatedFrame.height + 8)
    }
    
    
    
    // MARK: - TextField Delegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.messageTextField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Keyboard vs Scrollview Functions
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func handleKeyboardChangeFrame(_ notification: NSNotification) {
        guard let keyboardEndFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationCurveInt = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt,
            let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            print("ERROR: ChatRoomVC handleKeyboardChangeFrame(_:) cannot get keyboard frame.")
            return
        }
        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveInt << 16)
        let oldYContentOffset = self.chatCollectionView.contentOffset.y
        let oldChatViewHeight = self.chatCollectionView.bounds.size.height
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            
            // Push up/down textField
            if keyboardEndFrame.origin.y >= UIScreen.main.bounds.height {
                self.textBarViewBottomConstraint.constant = 0
            } else {
                self.textBarViewBottomConstraint.constant = -keyboardEndFrame.height
            }
            self.view.layoutIfNeeded()
        
            // Calculate new y content offset
            let newChatViewHeight = self.chatCollectionView.bounds.size.height
            let chatViewHeightDifference = newChatViewHeight - oldChatViewHeight
            var newYContentOffset = oldYContentOffset - chatViewHeightDifference
            
            // Prevent new Y content offset to exceed the range
            let contentSizeHeight = self.chatCollectionView.contentSize.height
            let possibleBottommostYContentOffset = contentSizeHeight - newChatViewHeight
            newYContentOffset = min(newYContentOffset, possibleBottommostYContentOffset)
            
            let possibleTopmostYContentOffset: CGFloat = 0
            newYContentOffset = max(possibleTopmostYContentOffset, newYContentOffset)
            
            // Create new content offset
            let newChatViewContentOffset = CGPoint(x: self.chatCollectionView.contentOffset.x, y: newYContentOffset)
            self.chatCollectionView.contentOffset = newChatViewContentOffset
           
        }, completion: nil)
    }
    
    
    
    // MARK: - App State Functions
    private func registerAppStateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppState(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func deregisterAppStateNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleAppState(_ notification: NSNotification) {
        self.readMessage(of: self.chatRoom?.id ?? "0")
        self.loadMessages(of: self.chatRoom?.id ?? "0") {
            if !self.chat_roomSocket.isConnected {
                self.chat_roomSocket.connect()
            }
            if !self.card_tableSocket.isConnected {
                self.card_tableSocket.connect()
            }
        }
    }
    
    
    // MARK: Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "chatRoomShowFriendCard":
            let cardDetailVC = segue.destination as! CardDetailViewController
            cardDetailVC.user_id = self.chatRoom?.friend.id
        default:
            print("ChatRoomVC: Unexpected Segue Identifier.")
            return
        }
    }
    
    
    
    // MARK: - Helper Functions
    private func loadMessages(of chatroom_id: String, completion: @escaping (() -> Void)) {
        let user_id = UserDefaults.standard.string(forKey: "user_id")!
        let url = Junction.API.getMessagesURL.replacingOccurrences(of: "<chatRoom_id>", with: chatroom_id)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                
                // Clear dataSource
                self.messages.removeAll()
                
                // Extract JSON
                let chatRoomJSON = JSON(value)
                
                // Configure notification setting
                let notification = chatRoomJSON["notification"].dictionaryValue
                let user_idsJSON = chatRoomJSON["user_id"].dictionaryValue
                let user1 = user_idsJSON["user_1"]!.stringValue
                if user_id == user1 {
                    self.configureNotificationBttn(isOn: notification["user_1"]!.boolValue)
                    self.notificationIsOn = notification["user_1"]!.boolValue
                } else {
                    // user_id == user2
                    self.configureNotificationBttn(isOn: notification["user_2"]!.boolValue)
                    self.notificationIsOn = notification["user_2"]!.boolValue
                }
                
                // Extract message
                let messagesJSON = chatRoomJSON["messages"].arrayValue
                self.messages = messagesJSON.map { (messageJSON) -> Message in
                    let id = messageJSON["id"].intValue
                    let text = messageJSON["content"].stringValue
                    let send_date = messageJSON["time"].stringValue
                    let sender_id = messageJSON["user_id"].stringValue
                    
                    let message = Message(id: id, text: text, send_date: send_date.toDateFromISO()!, sender_id: sender_id, isRead: true)
                    return message
                }
                
                self.reloadMessage()
                self.scrollToLastItem(in: self.chatCollectionView, section: 0, at: .bottom, animated: false)
                completion()
                
            case .failure(let error):
                print("ChatRoomVC: loadMessage(of:) fail because \(error).")
            }
        }
    }
    
    private func insert(_ message: Message) {
        
        // Insert into collection view
        self.messages.append(message)
        let lastItem = self.messages.count - 1
        let insertionIndexPath = IndexPath(item: lastItem, section: 0)
        DispatchQueue.main.async {
            self.chatCollectionView.insertItems(at: [insertionIndexPath])
        }
        
        // Scroll to last item
        self.scrollToLastItem(in: self.chatCollectionView, section: 0, at: .bottom, animated: true)
    }
    
    private func scrollToLastItem(in collectionView: UICollectionView, section: Int, at position: UICollectionViewScrollPosition, animated: Bool) {
        let dataSource_count = collectionView.numberOfItems(inSection: section)
        if dataSource_count > 0 {
            let lastItem = dataSource_count - 1
            let lastItemIndexPath = IndexPath(item: lastItem, section: section)
            DispatchQueue.main.async {
                collectionView.scrollToItem(at: lastItemIndexPath, at: position, animated: animated)
            }
        } else { return }
    }
    
    private func reloadMessage() {
        
        // Arrange array by Date
        self.messages = self.messages.sorted { (message1, message2) -> Bool in
            return message1.send_date.compare(message2.send_date) == .orderedAscending
        }
        DispatchQueue.main.async {
            self.chatCollectionView.reloadData()
        }
    }
    
    private func readMessage(of chatroom_id: String) {
        let url = Junction.API.readMessagesURL.replacingOccurrences(of: "<chatRoom_id>", with: chatroom_id)
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        let parameters: Parameters = [ "message": "read",
                                       "user_id": user_id]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let message = JSON(value)["message"].stringValue
                print("ChatRoomVC: \(#function) \(message).")
            case .failure(let error):
                print("ChatRoomVC ERROR: readMessage(of:) fail because \(error).")
            }
        }
    }
    
    private func configureNotificationBttn(isOn: Bool) {
        if isOn {
            self.notificationOnOffBttn.setImage(#imageLiteral(resourceName: "notification off.pdf"), for: .normal)
            self.notificationOnOffBttn.setTitle("通知 OFF", for: .normal)
        } else {
            self.notificationOnOffBttn.setImage(#imageLiteral(resourceName: "notification on.pdf"), for: .normal)
            self.notificationOnOffBttn.setTitle("通知 ON", for: .normal)
        }
    }
}
