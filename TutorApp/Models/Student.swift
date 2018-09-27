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

class Student: User {
    
    
    var assignments = [Assignment]()
    
    convenience init?(with studentRecord: CKRecord?) {
        self.init(studentRecord)
        CloudKitManager.getAssignmentsFrom(studentRecord) { (assignments) in
            self.assignments = assignments
        }
    }
    
}
