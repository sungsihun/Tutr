//
//  Student.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
class Student {
    
    var name: String
    var record: CKRecord?
    var subjectStudying: String?
    var image: UIImage? = #imageLiteral(resourceName: "defaultUser")
    var assignments = [Assignment]()
    
    convenience init?(_ record: CKRecord?) {
        guard let record = record,
            let name = record["name"] as? String,
            let subjectStudying = record["subjectStudying"] as? String else { return nil }

        self.init(name: name, subjectStudying: subjectStudying, record: record)
    }
    
    init(name: String, subjectStudying: String? = nil, record: CKRecord? = nil) {
        self.name = name
        self.subjectStudying = subjectStudying
        self.record = record
    }
    
    
    
}
