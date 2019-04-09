//
//  User.swift
//  LinkedInXDcard
//
//  Created by 林晏竹 on 2017/11/30.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import UIKit
import SwiftyJSON
import os.log

enum Gender: String {
    case 男
    case 女
    case 其他
    
    static let allCases = [男, 女, 其他]
}

struct User {
    
    // MARK: - Properties
    var id: String
    var id_type: LoginProvider?
    var profile_pic_str: String? { // Base64 or URL
        didSet {
            self.profile_pic = self.profile_pic_str?.toImage()
        }
    }
    var chinese_name: String?
    var english_name: String?
    var gender: Gender?
    var bachelor_school: String?
    var bachelor_major: String?
    var master_school: String?
    var master_major: String?
    var phone_number: String?
    var email: String?
    var work_exps: [WorkExperience]?
    var selfintro: String?
    var satisfied_projects: String?
    var interested_cop_topics: String?
    var skill_fields: ProfessionalCapability
    var interested_fields: ProfessionalCapability
    var invited_code: String?
    
    // get-only properties
    private(set) var profile_pic: UIImage?
    var highest_edu: String? {
        get {
            if !(self.master_school?.isEmpty ?? true) {
                return "\(self.master_school!) \(self.master_major ?? "")"
            } else {
                return "\(self.bachelor_school ?? "") \(self.bachelor_major ?? "")"
            }
        }
    }
    
    // MARK: - Initializers
    init(id: String,
         profile_pic_str: String?,
         chinese_name: String?,
         english_name: String?,
         gender: Gender?,
         bachelor_school: String?,
         bachelor_major: String?,
         master_school: String?,
         master_major: String?,
         phone_number: String?,
         email: String?,
         work_exps: [WorkExperience]?,
         selfintro: String?,
         skill_fields: ProfessionalCapability = ProfessionalCapability(),
         interested_fields: ProfessionalCapability = ProfessionalCapability(),
         satisfied_projects: String?,
         interested_cop_topics: String?) {
        
        self.id = id
        self.chinese_name = chinese_name
        self.english_name = english_name
        self.gender = gender
        self.bachelor_school = bachelor_school
        self.bachelor_major = bachelor_major
        self.master_school = master_school
        self.master_major = master_major
        self.phone_number = phone_number
        self.email = email
        self.work_exps = work_exps
        self.selfintro = selfintro
        self.skill_fields = skill_fields
        self.interested_fields = interested_fields
        self.satisfied_projects = satisfied_projects
        self.interested_cop_topics = interested_cop_topics
        
        // Let didSet to be called when initializing
        defer {
            self.profile_pic_str = profile_pic_str
        }
    }
    
    
    // For only one work_exp
    init(id: String,
         profile_pic_str: String?,
         chinese_name: String?,
         english_name: String?,
         gender: Gender?,
         bachelor_school: String?,
         bachelor_major: String?,
         master_school: String?,
         master_major: String?,
         phone_number: String?,
         email: String?,
         company: String?,
         job_title: String?,
         job_type: Set<String>?,
         industry_type: String?,
         career_length: Int?,
         selfintro: String?,
         skill_fields: ProfessionalCapability = ProfessionalCapability(),
         interested_fields: ProfessionalCapability = ProfessionalCapability(),
         satisfied_projects: String?,
         interested_cop_topics: String?) {
        
        var work_exps = [WorkExperience]()
        let work_exp = WorkExperience(company: company, job_title: job_title, job_type: job_type, industry_type: industry_type, career_length: career_length)
        work_exps.append(work_exp)
        
        self.init(id: id, profile_pic_str: profile_pic_str, chinese_name: chinese_name, english_name: english_name, gender: gender, bachelor_school: bachelor_school, bachelor_major: bachelor_major, master_school: master_school, master_major: master_major, phone_number: phone_number, email: email, work_exps: work_exps, selfintro: selfintro, skill_fields: skill_fields, interested_fields: interested_fields, satisfied_projects: satisfied_projects, interested_cop_topics: interested_cop_topics)
    }
    
    
    // For registration (has id_type, invited_code)
    init(id: String,
         id_type: LoginProvider,
         invited_code: String? = nil,
         profile_pic_str: String? = nil,
         chinese_name: String?,
         english_name: String?,
         gender: Gender? = nil,
         bachelor_school: String? = nil,
         bachelor_major: String? = nil,
         master_school: String? = nil,
         master_major: String? = nil,
         phone_number: String? = nil,
         email: String? = nil,
         work_exps:[WorkExperience]? = nil,
         selfintro: String? = nil,
         skill_fields: ProfessionalCapability = ProfessionalCapability(),
         interested_fields: ProfessionalCapability = ProfessionalCapability(),
         satisfied_projects: String? = nil,
         interested_cop_topics: String? = nil) {
        
        self.init(id: id, profile_pic_str: profile_pic_str, chinese_name: chinese_name, english_name: english_name, gender: gender, bachelor_school: bachelor_school, bachelor_major: bachelor_major, master_school: master_school, master_major: master_major, phone_number: phone_number, email: email, work_exps: work_exps, selfintro: selfintro, skill_fields: skill_fields, interested_fields: interested_fields, satisfied_projects: satisfied_projects, interested_cop_topics: interested_cop_topics)
        self.id_type = id_type
        self.invited_code = invited_code
    }
    
    
    // For registration (has id_type, invited_code) but only one work_exp
    init(id: String,
         id_type: LoginProvider,
         invited_code: String? = nil,
         profile_pic_str: String? = nil,
         chinese_name: String?,
         english_name: String?,
         gender: Gender? = nil,
         bachelor_school: String? = nil,
         bachelor_major: String? = nil,
         master_school: String? = nil,
         master_major: String? = nil,
         phone_number: String? = nil,
         email: String? = nil,
         company: String?,
         job_title: String?,
         job_type: Set<String>?,
         industry_type: String?,
         career_length: Int?,
         selfintro: String? = nil,
         skill_fields: ProfessionalCapability = ProfessionalCapability(),
         interested_fields: ProfessionalCapability = ProfessionalCapability(),
         satisfied_projects: String? = nil,
         interested_cop_topics: String? = nil) {
        
        var work_exps = [WorkExperience]()
        let work_exp = WorkExperience(company: company, job_title: job_title, job_type: job_type, industry_type: industry_type, career_length: career_length)
        work_exps.append(work_exp)
        
        self.init(id: id, profile_pic_str: profile_pic_str, chinese_name: chinese_name, english_name: english_name, gender: gender, bachelor_school: bachelor_school, bachelor_major: bachelor_major, master_school: master_school, master_major: master_major, phone_number: phone_number, email: email, work_exps: work_exps, selfintro: selfintro, skill_fields: skill_fields, interested_fields: interested_fields, satisfied_projects: satisfied_projects, interested_cop_topics: interested_cop_topics)
        self.id_type = id_type
        self.invited_code = invited_code
    }
    
    // For CardTableList, ChatRoomVC (when received notification)
    init(id: String,
         profile_pic_str: String,
         chinese_name: String,
         english_name: String,
         job_title: String? = nil,
         skill_fields: ProfessionalCapability = ProfessionalCapability(),
         interested_fields: ProfessionalCapability = ProfessionalCapability()) {
        
        self.init(id: id, profile_pic_str: profile_pic_str, chinese_name: chinese_name, english_name: english_name, gender: nil, bachelor_school: nil, bachelor_major: nil, master_school: nil, master_major: nil, phone_number: nil, email: nil, company: nil, job_title: job_title, job_type: nil, industry_type: nil, career_length: nil, selfintro: nil, satisfied_projects: nil, interested_cop_topics: nil)
    }
    
    
    
    // MARK: - Class Functions
    /*  Check if the field_tags need to be preselected is in the dataSource.
     1. If not, return the items that is not in the datasource.
     2. If yes, return nil
     */
    func field_tagsNeedAddingForPreselect(_ field_tags: [String: Int]?, in dataSource: [String]) -> [String]? {
        guard let _ = field_tags else {
            return nil
        }
        
        let itemSet = Set(field_tags!.keys)
        let dataSourceSet = Set(dataSource)
        if !itemSet.isSubset(of: dataSourceSet) {
            return Array(itemSet.subtracting(dataSourceSet))
        } else { return nil }
    }
}
