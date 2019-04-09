//
//  Constants.swift
//  Junction
//
//  Created by 林晏竹 on 2018/3/22.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit

enum JunctionSocketAPI {
    
}

enum Junction {
    static let about_usURL = "https://www.joinjunction.me"
    static let FBFanPageURL = "https://www.facebook.com/junctioninsights/"
    
    enum Color {
        static let red = #colorLiteral(red: 0.7960000038, green: 0.1059999987, blue: 0.2709999979, alpha: 1)
        static let dark_blue = #colorLiteral(red: 0.0549999997, green: 0.2039999962, blue: 0.5059999824, alpha: 1)
        static let light_blue = #colorLiteral(red: 0.3140000105, green: 0.5450000167, blue: 0.7570000291, alpha: 1)
        static let yellow = #colorLiteral(red: 0.9100000262, green: 0.7839999795, blue: 0.1099999994, alpha: 1)
        static let black = #colorLiteral(red: 0.1099999994, green: 0.1099999994, blue: 0.1410000026, alpha: 1) /* #1C1C24 */
        static let grey = #colorLiteral(red: 0.8353, green: 0.8392, blue: 0.8471, alpha: 1) /* #d5d6d8 */
    }
    
    enum Font {
        static let pickerViewFont = UIFont.systemFont(ofSize: 23)
        static let chatBubbleFont = UIFont.init(name: "PingFangTC-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    enum API {
        private static let ip = "http://52.91.88.137"
        private static let socket_ip = "ws://52.91.88.137"
        
        static let getChatRoomsURL = ip + "/user/<user_id>/friends/"
        static let getMessagesURL = ip + "/message/messageDetail/<chatRoom_id>/"
        static let readMessagesURL = ip + "/message/readMessage/<chatRoom_id>/"
        static let card_tableSocketURL = socket_ip + "/friendList/<user_id>/"
        static let chat_roomSocketURL = socket_ip + "/message/<chatRoom_id>/"
        
        static let getCardStatusURL = ip + "/user/<user_id>/drawCardStatus/"
        static let putCardStatusURL = ip + "/user/<user_id>/drawCardStatus/"
        static let getCardURL = ip + "/user/<user_id>/card"
        static let approveFriendURL = ip + "/inviteFriend/<user_id>/"
        
        static let postUserAPI = ip + "/user/"
        static let putUserAPI = ip + "/user/<user_id>/"
        static let getUserAPI = ip + "/user/<user_id>/"
        static let reportUserURL = ip + "/report/<user_id>/"
        
        static let putChatRoomNotificationURL = ip + "/message/updateNotification/<chatRoom_id>/"
        static let putDeviceIDAPI = ip + "/user/deviceSetting/<user_id>/"
        static let checkUserExistAPI = ip + "/checkUser/<user_id>"
        static let checkInvitedCodeExistAPI = ip + "/checkApplicant/<invited_code>/"
        
        static let getWebUserAPI = ip + "/applicant/<invited_code>/"
        static let getInvitationCodeAPI = ip + "/invitationCode/<invited_code>/"
        static let postBetaFeedbackAPI = ip + "/feedback/beta/"
    }
}
