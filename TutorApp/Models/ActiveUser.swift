//
//  ActiveUserType.swift
//  TutorApp
//
//  Created by Henry Cooper on 24/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation

final class ActiveUser {
    
    static let shared = ActiveUser()
    var current: User?
    var currentCategory: Category = .notSet
    private static let key = "activeUser"
    static let recordID = "activeUserID"
    private init() {
        if let user = UserDefaults.standard.string(forKey: ActiveUser.key) {
            currentCategory = Category(rawValue: user)!
        }
    }
    
    public enum Category: String {
        case student = "Students"
        case teacher = "Teachers"
        case notSet = "notSet"
        
        func segueID() -> String {
            switch self {
            case .student:
                return "studentCreatedSegue"
            case .teacher:
                return "teacherCreatedSegue"
            default: fatalError()
            }
        }
    }
    
    func save() {
        UserDefaults.standard.set(currentCategory.rawValue, forKey: ActiveUser.key)
        UserDefaults.standard.set(current?.record?.recordID.recordName, forKey: ActiveUser.recordID)
    }
    
   

}
