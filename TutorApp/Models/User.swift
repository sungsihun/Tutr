//
//  User.swift
//  TutorApp
//
//  Created by Henry Cooper on 24/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class User {
    
    var name: String
    var record: CKRecord?
    var subject: String
    var image: UIImage?
    
    
    init(name: String, subject: String, image: UIImage? = #imageLiteral(resourceName: "defaultUser"), record: CKRecord? = nil) {
        self.name = name
        self.subject = subject
        self.image = image
        self.record = record
    }
    
    convenience init?(_ record: CKRecord?) {
        guard let record = record,
            let name = record["name"] as? String,
            let subject = record["subject"] as? String else { return nil }
        
        self.init(name: name, subject: subject, record: record)
    }
    
    
    
}
