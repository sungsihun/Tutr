//
//  Homework.swift
//  TutorApp
//
//  Created by Henry Cooper on 19/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import CloudKit

class Assignment {
  
    var assignmentTitle: String
    var assignmentDescription: String
    var record: CKRecord?
    var teacherRef: CKReference
    var isComplete = false
    
    init(assignmentTitle: String, assignmentDescription: String, teacherRef: CKReference) {
        self.assignmentTitle = assignmentTitle
        self.assignmentDescription = assignmentDescription
        self.teacherRef = teacherRef
    }
    
    convenience init?(_ record: CKRecord) {
        guard let title = record["title"] as? String else { fatalError("Assignment missing title") }
        guard let description = record["description"] as? String else { fatalError("Assignment missing description") }
        guard let teacherRef = record["teacherRef"] as? CKReference else { fatalError() }
        guard let isComplete = record["isComplete"] as? Int else { fatalError() }
        self.init(assignmentTitle: title, assignmentDescription: description, teacherRef: teacherRef)
        self.isComplete = isComplete.boolValue
        self.record = record

    }
}
