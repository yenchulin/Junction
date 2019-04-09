//
//  CardTableViewController.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/11/30.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import SwiftyJSON
import Starscream

class CardTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, WebSocketAdvancedDelegate {
    
    // MARK: - Outlets
    @IBOutlet var empty_placeholderView: UIView!
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    
    // MARK: - Properties
    var chatRoomList = [ChatRoom]()
    var card_tableSocket = WebSocket(url: URL(string: "ws://echo.websocket.org")!)
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        
        // Socket init
        if let mytableURL = URL(string: Junction.API.card_tableSocketURL.replacingOccurrences(of: "<user_id>", with: user_id)) {
            self.card_tableSocket = WebSocket(url: mytableURL)
            
        } else {
            print("CardTableVC: socket url is nil")
        }
        
        
        // Delegates:
        if forceTouchIsAvailable() {
            self.registerForPreviewing(with: self, sourceView: self.view)
        }
        self.card_tableSocket.advancedDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        
        // Functions:
        self.registerAppStateNotifications()
        self.loadChatRoomList(of: user_id) {
            self.card_tableSocket.connect()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Functions:
        self.card_tableSocket.disconnect()
        self.deregisterAppStateNotifications()
    }
    
    
    
    
    // MARK: - Websocket Advanced Delegate Functions
    func websocketDidConnect(socket: WebSocket) {
        print("CardTableVC: card_tableSocket connected.")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("CardTableVC: card_tableSocket disconnected because \(error.debugDescription).")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        switch socket {
        case self.card_tableSocket:
            print("CardTableVC: card_tableSocket received message = \(text).")
            
            let messageJSON = JSON(parseJSON: text)
            let chatRoom_id = messageJSON["message_id"].stringValue
            let unread_number = messageJSON["unread_message_number"].intValue
            
            // Find the chatroom index that receuved new message
            let index = self.chatRoomList.index(where: { (chatRoom) -> Bool in
                return chatRoom.id == chatRoom_id
            })
            
            self.updateUnreadView(at: index!, in: self.tableView, section: 0, with: unread_number)
            self.moveToFirstRow(from: index!, in: self.tableView, section: 0)

        default:
            print("CardTableVC ERROR: receivedMessage() unexpected socket.")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {}
    
    func websocketHttpUpgrade(socket: WebSocket, request: String) {}
    
    func websocketHttpUpgrade(socket: WebSocket, response: String) {}
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Determine whether to show table empty placeholder
        if self.chatRoomList.isEmpty {
            tableView.backgroundView = self.empty_placeholderView
        } else {
            tableView.backgroundView = nil
        }
        
        return self.chatRoomList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cardCell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardTableViewCell
        
        let chatRoom = self.chatRoomList[indexPath.row]
        cardCell.profile_picImageView.image = chatRoom.friend.profile_pic
        cardCell.english_nameLabel.text = chatRoom.friend.english_name
        cardCell.chinese_nameJob_titleLabel.text = "\(chatRoom.friend.chinese_name ?? "")｜\(chatRoom.friend.work_exps?.first?.job_title ?? "")"
        
        // Determine whether to place an Unread-Red-Dot
        self.updateUnreadView(at: cardCell, with: chatRoom.unread_number)

        return cardCell
    }
 
    
    
    // MARK: - ViewController Previewing Delegate Functions
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location),
              let cell = self.tableView.cellForRow(at: indexPath) else {
                print("CardTableVC: Cannot find indexPath or cell.")
                return nil
        }
        let chatRoom = self.chatRoomList[indexPath.row]
        
        let cardPopUpVC = self.storyboard?.instantiateViewController(withIdentifier: "CardPopUpVC") as! CardPopUpViewController
        cardPopUpVC.friend_id = chatRoom.friend.id
        previewingContext.sourceRect = self.tableView.convert(cell.frame, to: self.tableView)
        
        return cardPopUpVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {}
    
    
    
    // MARK: - App State Functions
    private func registerAppStateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppState(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    private func deregisterAppStateNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc private func handleAppState(_ notification: NSNotification) {
        let user_id = UserDefaults.standard.string(forKey: "user_id") ?? "0"
        self.loadChatRoomList(of: user_id) {
            if !self.card_tableSocket.isConnected {
                self.card_tableSocket.connect()
            }
        }
    }
    
    
    
    // MARK: - Navigation Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "cardTableShowFriendCard":
            let cardDetailVC = segue.destination as! CardDetailViewController
            let to_cardBttn = sender as! UIButton
            let cell = to_cardBttn.superview?.superview?.superview as! CardTableViewCell
            let indexPath = self.tableView.indexPath(for: cell)!
            let chatRoom = self.chatRoomList[indexPath.row]
            cardDetailVC.user_id = chatRoom.friend.id
            
        case "showChatRoom":
            let chatRoomVC = segue.destination as! ChatRoomViewController
            let to_chatBttn = sender as! UIButton
            let cell = to_chatBttn.superview?.superview?.superview as! CardTableViewCell
            let indexPath = self.tableView.indexPath(for: cell)!
            let chatRoom = self.chatRoomList[indexPath.row]
            chatRoomVC.chatRoom = chatRoom
            
        default:
            print("CardTableVC: Unexpected Segue Identifier.")
            return
        }
    }
    

    
    
    
    // MARK: - Helper Functions
    func loadChatRoomList(of user_id: String, completion: @escaping (() -> Void)) {
        
        // Show activity indicator
        self.startAnimating(activityIndicatorView: self.activityIndicatorView)
        
        // Fetch API
        ChatRoomHelper.getChatRooms(user_id) { (error, chatRooms) in
            
            // Dismiss activity indicator
            self.stopAnimating(activityIndicatorView: self.activityIndicatorView)
            
            // Check if fetching has error
            if error == nil {
                
                // Clear dataSource
                self.chatRoomList.removeAll()
                
                // Assign new dataSource
                self.chatRoomList = chatRooms!
                self.refreshTable()
                
                completion()
                
            } else {
                print("CardTableVC ERROR: load chatRoom list fail because \(error.debugDescription)")
            }
        }
    }
   
    private func refreshTable() {
        self.chatRoomList = self.chatRoomList.sorted(by: { (chatRoom1, chatRoom2) -> Bool in
            
            /* - Return true if ch1 should be before ch2
             - So, return true if ch1_time is greater than ch2_time
             
             ch1   ch2
             1. nil |  v   -> false
             2.  v  | nil  -> true
             3. nil | nil  -> false(or true)
             4.  v  |  v   -> compare
             */
            if chatRoom1.last_messageTime == nil && chatRoom2.last_messageTime != nil {
                return false
            } else if chatRoom1.last_messageTime != nil && chatRoom2.last_messageTime == nil {
                return true
            } else if chatRoom1.last_messageTime == nil && chatRoom2.last_messageTime == nil {
                return false
            } else {
                return chatRoom1.last_messageTime!.compare(chatRoom2.last_messageTime!) == .orderedDescending
            }
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func moveToFirstRow(from index: Int, in tableView: UITableView, section: Int) {
        DispatchQueue.main.async {
            // Move table cell
            let currentIndexPath = IndexPath(row: index, section: section)
            let firstIndexPath = IndexPath(row: 0, section: section)
            tableView.moveRow(at: currentIndexPath, to: firstIndexPath)
            
            // Move datasource data
            self.chatRoomList.insert(self.chatRoomList[index], at: 0)
            self.chatRoomList.remove(at: index + 1)
        }
    }
    
    // Update unreadView when websocket receive message
    private func updateUnreadView(at index: Int, in tableView: UITableView, section: Int, with unread_number: Int) {
        let currentIndexPath = IndexPath(row: index, section: section)
        let cardCell = tableView.cellForRow(at: currentIndexPath) as! CardTableViewCell
        
        self.updateUnreadView(at: cardCell, with: unread_number)
    }
    
    // Update unreadView when rendering cells in tableView(_:cellForRowAt:)
    private func updateUnreadView(at cardCell: CardTableViewCell, with unread_number: Int) {
        if unread_number > 0 {
            cardCell.hasUnreadMessage = true
        } else {
            cardCell.hasUnreadMessage = false
        }
    }
    
    // Check 3D touch availability
    private func forceTouchIsAvailable () -> Bool {
        if self.traitCollection.forceTouchCapability == .available {
            return true
        } else {
            return false
        }
    }
}
