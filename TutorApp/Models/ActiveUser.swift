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
    static var current: Category?
    private static let key = "activeUser"
    
    private init() {
        if let user = UserDefaults.standard.string(forKey: ActiveUser.key) {
            ActiveUser.current = Category(rawValue: user)
        }
    }
    
    public enum Category: String {
        case student = "Students"
        case teacher = "Teachers"
    }
    
    static func save() {
        if let current = ActiveUser.current {
            UserDefaults.standard.set(current.rawValue, forKey: ActiveUser.key)
        }
    }
    
    
}
