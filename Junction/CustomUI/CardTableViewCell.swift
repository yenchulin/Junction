//
//  CardTableViewCell.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/11/30.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    
    // MARK: - Outlets
    @IBOutlet weak var profile_picImageView: UIImageView!
    @IBOutlet weak var english_nameLabel: UILabel!
    @IBOutlet weak var chinese_nameJob_titleLabel: UILabel!
    @IBOutlet weak var to_chatBttn: UIButton!
    let chat_unreadImage = #imageLiteral(resourceName: "chat_unread")
    let chat_readImage = #imageLiteral(resourceName: "chat_read")
    
    
    // MARK: - Properties
    var hasUnreadMessage = false {
        didSet {
            DispatchQueue.main.async {
                if self.hasUnreadMessage {
                    self.to_chatBttn.setImage(self.chat_unreadImage, for: .normal)
                } else {
                    self.to_chatBttn.setImage(self.chat_readImage, for: .normal)
                }
            }
        }
    }
}
