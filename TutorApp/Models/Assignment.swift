//
//  Homework.swift
//  TutorApp
//
//  Created by Henry Cooper on 19/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import CloudKit

class Assignment: NSObject, NSCoding {
  
    var assignmentTitle: String
    var assignmentDescription: String
    var record: CKRecord?
    var teacherRef: CKRecord.Reference?
    var isComplete = false
    var createdAt: Date?
    
    init(assignmentTitle: String, assignmentDescription: String, teacherRef: CKRecord.Reference?) {
        self.assignmentTitle = assignmentTitle
        self.assignmentDescription = assignmentDescription
        self.teacherRef = teacherRef
    }
    
    convenience init?(_ record: CKRecord) {
        guard let title = record["title"] as? String else { fatalError("Assignment missing title") }
        guard let description = record["description"] as? String else { fatalError("Assignment missing description") }
        guard let teacherRef = record["teacherRef"] as? CKRecord.Reference else { fatalError() }
        guard let isComplete = record["isComplete"] as? Int else { fatalError() }
        self.init(assignmentTitle: title, assignmentDescription: description, teacherRef: teacherRef)
        self.createdAt = record.creationDate
        self.isComplete = isComplete.boolValue
        self.record = record
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(assignmentDescription, forKey: "description")
        aCoder.encode(assignmentTitle, forKey: "title")
        aCoder.encode(isComplete, forKey: "isComplete")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let isComplete = aDecoder.decodeBool(forKey: "isComplete")
        guard let title = aDecoder.decodeObject(forKey: "title") as? String,
            let description = aDecoder.decodeObject(forKey: "description") as? String else { return nil }
        self.init(assignmentTitle: title, assignmentDescription: description, teacherRef: nil)
        self.isComplete = isComplete

    }
}
