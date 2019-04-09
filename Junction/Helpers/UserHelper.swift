//
//  UserHelper.swift
//  Junction
//
//  Created by 林晏竹 on 2018/4/30.
//  Copyright © 2018年 林晏竹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum UserHelper {
    // Check if the function is currently running
    private static var isRunning = false
    
    static func getUser(_ user_id: String, completion: @escaping ((Error?, User?) -> Void)) {
        if !isRunning {
            self.isRunning = true
            
            let url = Junction.API.getUserAPI.replacingOccurrences(of: "<user_id>", with: user_id)
            Alamofire.request(url).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let userJSON = JSON(value)
                    let user = self.extractUserJSON(userJSON)
                    completion(nil, user)
                    
                case .failure(let error):
                    completion(error, nil)
                }
                
                self.isRunning = false
            }
        } else { return }
    }
    
    
    
    static func postUser(_ user: User, completion: @escaping ((Error?) -> Void)) {
        let url = Junction.API.postUserAPI
        let parameters: Parameters = ["user_id": user.id,
                                      "id_type": user.id_type?.rawValue ?? LoginProvider.None.rawValue,
                                      "chinese_name": user.chinese_name ?? "",
                                      "english_name": user.english_name ?? "",
                                      "gender": user.gender?.rawValue ?? "",
                                      "photo": user.profile_pic_str ?? "",
                                      "company": user.work_exps?.first?.company ?? "",
                                      "job_title": user.work_exps?.first?.job_title ?? "",
                                      "career_year": user.work_exps?.first?.career_length ?? 0,
                                      "job_type": Array(user.work_exps?.first?.job_type ?? Set<String>()),
                                      "industry_type": user.work_exps?.first?.industry_type ?? "",
                                      "bachelor_school": user.bachelor_school ?? "",
                                      "bachelor_major": user.bachelor_major ?? "",
                                      "master_school": user.master_school ?? "",
                                      "master_major": user.master_major ?? "",
                                      "phone_number": user.phone_number ?? "",
                                      "email": user.email ?? "",
                                      "introduction": user.selfintro ?? "",
                                      "satisfied_project": user.satisfied_projects ?? "",
                                      "cooperation_things": user.interested_cop_topics ?? "",
                                      "linked_code": user.invited_code ?? "",
                                      
                                      "pm_i_rating": user.interested_fields.pm,
                                      "marketing_i_rating": user.interested_fields.marketing,
                                      "data_analysis_i_rating": user.interested_fields.data_analysis,
                                      "uiux_i_rating": user.interested_fields.uiux,
                                      "startup_i_rating": user.interested_fields.startup,
                                      "sales_i_rating": user.interested_fields.sales,
                                      "finance_i_rating": user.interested_fields.finance,
                                      "information_technology_i_rating": user.interested_fields.information_technology,
                                      "business_i_rating": user.interested_fields.business,
                                      "other_i_rating": user.interested_fields.other,
                                      
                                      "pm_rating": user.skill_fields.pm,
                                      "marketing_rating": user.skill_fields.marketing,
                                      "data_analysis_rating": user.skill_fields.data_analysis,
                                      "uiux_rating": user.skill_fields.uiux,
                                      "startup_rating": user.skill_fields.startup,
                                      "sales_rating": user.skill_fields.sales,
                                      "finance_rating": user.skill_fields.finance,
                                      "information_technology_rating": user.skill_fields.information_technology,
                                      "business_rating": user.skill_fields.business,
                                      "other_rating": user.skill_fields.other]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    completion(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    static func putUser(_ user: User, user_id: String, completion: @escaping ((Error?) -> Void)) {
        let url = Junction.API.putUserAPI.replacingOccurrences(of: "<user_id>", with: user_id)
        let parameters: Parameters = ["chinese_name": user.chinese_name ?? "",
                                      "english_name": user.english_name ?? "",
                                      "gender": user.gender?.rawValue ?? "",
                                      "photo": user.profile_pic_str ?? "",
                                      "company": user.work_exps?.first?.company ?? "",
                                      "job_title": user.work_exps?.first?.job_title ?? "",
                                      "career_year": user.work_exps?.first?.career_length ?? 0,
                                      "job_type": Array(user.work_exps?.first?.job_type ?? Set<String>()),
                                      "industry_type": user.work_exps?.first?.industry_type ?? "",
                                      "bachelor_school": user.bachelor_school ?? "",
                                      "bachelor_major": user.bachelor_major ?? "",
                                      "master_school": user.master_school ?? "",
                                      "master_major": user.master_major ?? "",
                                      "phone_number": user.phone_number ?? "",
                                      "email": user.email ?? "",
                                      "introduction": user.selfintro ?? "",
                                      "satisfied_project": user.satisfied_projects ?? "",
                                      "cooperation_things": user.interested_cop_topics ?? "",
                                      "pm_i_rating": user.interested_fields.pm,
                                      "marketing_i_rating": user.interested_fields.marketing,
                                      "data_analysis_i_rating": user.interested_fields.data_analysis,
                                      "uiux_i_rating": user.interested_fields.uiux,
                                      "startup_i_rating": user.interested_fields.startup,
                                      "sales_i_rating": user.interested_fields.sales,
                                      "finance_i_rating": user.interested_fields.finance,
                                      "information_technology_i_rating": user.interested_fields.information_technology,
                                      "business_i_rating": user.interested_fields.business,
                                      "other_i_rating": user.interested_fields.other,
                                      
                                      "pm_rating": user.skill_fields.pm,
                                      "marketing_rating": user.skill_fields.marketing,
                                      "data_analysis_rating": user.skill_fields.data_analysis,
                                      "uiux_rating": user.skill_fields.uiux,
                                      "startup_rating": user.skill_fields.startup,
                                      "sales_rating": user.skill_fields.sales,
                                      "finance_rating": user.skill_fields.finance,
                                      "information_technology_rating": user.skill_fields.information_technology,
                                      "business_rating": user.skill_fields.business,
                                      "other_rating": user.skill_fields.other]
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                DispatchQueue.main.async {
                    completion(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    // Report User
    static func reportUser(_ user_id: String, completion: @escaping (Error?) -> Void) {
        let url = Junction.API.reportUserURL.replacingOccurrences(of: "<user_id>", with: user_id)
        Alamofire.request(url).validate().responseJSON { (response) in
            switch response.result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private static func extractUserJSON(_ userJSON: JSON) -> User {
        let id = userJSON["user_id"].stringValue
        let profile_pic_str = userJSON["photo"].stringValue
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
        let selfintro = userJSON["introduction"].stringValue
        let skill_fields = ProfessionalCapability(userJSON["professional_field"].dictionaryValue)
        
        let satisfied_projects = userJSON["satisfied_project"].stringValue
        let interested_cop_topics = userJSON["cooperation_things"].stringValue
        let interested_fields = ProfessionalCapability(userJSON["interest_issue"].dictionaryValue)
        
        let user = User(id: id,
                        profile_pic_str: profile_pic_str,
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
                        selfintro: selfintro,
                        skill_fields: skill_fields,
                        interested_fields: interested_fields,
                        satisfied_projects: satisfied_projects,
                        interested_cop_topics: interested_cop_topics)
        
        return user
    }
}
