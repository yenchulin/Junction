//
//  RegistrationHelper.swift
//  Junction
//
//  Created by 林晏竹 on 2018/5/10.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum RegistrationHelper {
    
    enum InvitedCodeStatus {
        case registered, unregistered, not_exist, error
    }
    
    
    static func getWebUser(_ invited_code: String, user_id: String, id_type: LoginProvider, completion: @escaping (Error?, User?) -> Void) {
        let url = Junction.API.getWebUserAPI.replacingOccurrences(of: "<invited_code>", with: invited_code)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let userJSON = JSON(value)
                let user = self.extractWebUserJSON(userJSON, user_id: user_id, id_type: id_type, invited_code: invited_code)
                completion(nil, user)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    /* Check if the invited code exists in applicant & user pool:
          applicant | user
         1.   v     |  v   -> registered
         2.   v     |  x   -> unregistered
         3.   x     |  x   -> not_exist
         4.   x     |  v   -> error
    */
    static func checkInvitedCodeExist(_ invited_code: String, completion: @escaping (Error?, InvitedCodeStatus?) -> Void) {
        let url = Junction.API.checkInvitedCodeExistAPI.replacingOccurrences(of: "<invited_code>", with: invited_code)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let existInApplicant = JSON(value)["applicant_exist"].boolValue
                let existInUser = JSON(value)["user_exist"].boolValue
                
                if existInApplicant && existInUser {
                    completion(nil, .registered)
                } else if existInApplicant && !existInUser {
                    completion(nil, .unregistered)
                } else if !existInApplicant && !existInUser {
                    completion(nil, .not_exist)
                } else {
                    completion(nil, .error)
                }
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    static func checkUserExist(_ user_id: String, completion: @escaping (Error?, Bool?) -> Void) {
        let url = Junction.API.checkUserExistAPI.replacingOccurrences(of: "<user_id>", with: user_id)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let user_exist = JSON(value)["user_exist"].boolValue
                completion(nil, user_exist)
                
            case .failure(let error):
                completion(error, nil)
            }
        }
    }
    
    static private func extractWebUserJSON(_ userJSON: JSON, user_id: String, id_type: LoginProvider, invited_code: String) -> User {
        let chinese_name = userJSON["chinese_name"].stringValue
        let english_name = userJSON["english_name"].stringValue
        let gender = Gender(rawValue: userJSON["gender"].stringValue)
        let bachelor_school = userJSON["bachelor_school"].stringValue
        let bachelor_major = userJSON["bachelor_major"].stringValue
        let master_school = userJSON["master_school"].stringValue
        let master_major = userJSON["master_major"].stringValue
        let phone_number = userJSON["phone_number"].stringValue
        let email = userJSON["email"].stringValue
        
        let company_name = userJSON["company"].stringValue
        let job_title = userJSON["job_title"].stringValue
        let job_type = Set(userJSON["job_type"].arrayValue.map { $0.stringValue })
        let industry_type = userJSON["industry_type"].stringValue
        let career_length = userJSON["career_year"].intValue
        let skill_fields = ProfessionalCapability(userJSON["professional_field"].dictionaryValue)
        let interested_fields = ProfessionalCapability(userJSON["interest_issue"].dictionaryValue)
        
        let satisfied_projects = userJSON["satisfied_project"].stringValue
        let interested_cop_topics = userJSON["cooperation_things"].stringValue
        
        let user = User(id: user_id,
                        id_type: id_type,
                        invited_code: invited_code,
                        profile_pic_str: nil,
                        chinese_name: chinese_name,
                        english_name: english_name,
                        gender: gender,
                        bachelor_school: bachelor_school,
                        bachelor_major: bachelor_major,
                        master_school: master_school,
                        master_major: master_major,
                        phone_number: phone_number,
                        email: email,
                        company: company_name,
                        job_title: job_title,
                        job_type: job_type,
                        industry_type: industry_type,
                        career_length: career_length,
                        selfintro: nil,
                        skill_fields: skill_fields,
                        interested_fields: interested_fields,
                        satisfied_projects: satisfied_projects,
                        interested_cop_topics: interested_cop_topics)
        
        return user
    }
}
