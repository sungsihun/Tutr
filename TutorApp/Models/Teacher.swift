//
//  Teacher.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Teacher {
  
    var name: String
    var subject: String?
    var image: UIImage?
    var record: CKRecord?
  
    init(name: String, subject: String? = nil, image: UIImage? = nil, record: CKRecord? = nil) {
        self.name = name
        self.subject = subject
        self.image = image
        self.record = record
    }
    
    convenience init?(_ record: CKRecord) {
        guard let name = record["name"] as? String,
            let subject = record["subjectTeaching"] as? String
            else { return nil }
        self.init(name: name, subject: subject, image: nil, record: record)
    }
    

}
