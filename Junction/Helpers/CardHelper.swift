//
//  CardHelper.swift
//  Junction
//
//  Created by 林晏竹 on 2018/5/5.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol CardStatusDelegate: AnyObject{
    func cardStatusHandler(_ status: CardStatus)
}

enum CardStatus: String {
    case notDrawn = "undraw"
    case userDidNothing = "draw"
    case userAcceptFriend = "accept"
    case userRejectFriend = "reject"
    case error
}

enum CardHelper {
    static func getCardStatus(_ user_id: String, delegate: CardStatusDelegate) {
        let url = Junction.API.getCardStatusURL.replacingOccurrences(of: "<user_id>", with: user_id)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let cardStatus = CardStatus(rawValue: JSON(value)["draw_card_status"].stringValue)!
                delegate.cardStatusHandler(cardStatus)
                
            case .failure(let error):
                delegate.cardStatusHandler(.error)
                print("CardHelper: \(#function) failed because \(error.localizedDescription)")
            }
        }
    }
    
    static func getCard(_ user_id: String, completion: @escaping (Error?, User?) -> Void) {
        let url = Junction.API.getCardURL.replacingOccurrences(of: "<user_id>", with: user_id)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let cardJSON = JSON(value)
                let card = extractCardJSON(cardJSON)
                completion(nil, card)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    static func sendInvitaion(_ user_id: String, completion: @escaping (Error?, String?) -> Void) {
        let url = Junction.API.approveFriendURL.replacingOccurrences(of: "<user_id>", with: user_id)
        let parameters: Parameters = ["message": "invite", "action": "accept"]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let message = JSON(value)["message"].stringValue
                completion(nil, message)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    static func ignore(_ user_id: String, completion: @escaping (Error?, String?) -> Void) {
        let url = Junction.API.approveFriendURL.replacingOccurrences(of: "<user_id>", with: user_id)
        let parameters: Parameters = ["message": "invite", "action": "reject"]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let message = JSON(value)["message"].stringValue
                completion(nil, message)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }

    static func drawCard(_ user_id: String, completion: @escaping (Error?, String?) -> Void) {
        let url = Junction.API.getCardStatusURL.replacingOccurrences(of: "<user_id>", with: user_id)
        let parameters: Parameters = ["message": "draw card"]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let message = JSON(value)["message"].stringValue
                completion(nil, message)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    private static func extractCardJSON(_ cardJSON: JSON) -> User {
        let id = cardJSON["user_id"].stringValue
        let profile_pic_str = cardJSON["photo"].stringValue
        let chinese_name = cardJSON["chinese_name"].stringValue
        let english_name = cardJSON["english_name"].stringValue
        let gender = cardJSON["gender"].stringValue
        let job_title = cardJSON["job_title"].stringValue
        
        let satisfied_projects = cardJSON["satisfied_project"].stringValue
        let interested_cop_topics = cardJSON["cooperation_things"].stringValue
        
        let skill_fields = ProfessionalCapability(cardJSON["professional_field"].dictionaryValue)
        let interested_fields = ProfessionalCapability(cardJSON["interest_issue"].dictionaryValue)
        
        let bachelor_school = cardJSON["bachelor_school"].stringValue
        let bachelor_major = cardJSON["bachelor_major"].stringValue
        let master_school = cardJSON["master_school"].stringValue
        let master_major = cardJSON["master_major"].stringValue
        let company_name = cardJSON["company"].stringValue
        let selfintro = cardJSON["introduction"].stringValue
        
        
        let card = User(id: id,
                        profile_pic_str: profile_pic_str,
                        chinese_name: chinese_name,
                        english_name: english_name,
                        gender: Gender(rawValue: gender),
                        bachelor_school: bachelor_school,
                        bachelor_major: bachelor_major,
                        master_school: master_school,
                        master_major: master_major,
                        phone_number: nil,
                        email: nil,
                        company: company_name,
                        job_title: job_title,
                        job_type: nil,
                        industry_type: nil,
                        career_length: nil,
                        selfintro: selfintro,
                        skill_fields: skill_fields,
                        interested_fields: interested_fields,
                        satisfied_projects: satisfied_projects,
                        interested_cop_topics: interested_cop_topics)
        
        return card
    }
}
