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
    
    var assignments = [Assignment]() {
        didSet {
            let center = NotificationCenter.default
            center.post(name: .assignmentsChanged, object: nil)
        }
    }
    var teacherAssignmentsDict = [String:Array<Assignment>]()
    
    convenience init?(with studentRecord: CKRecord?) {
        self.init(studentRecord)
        CloudKitManager.getAssignmentsFrom(studentRecord) { (assignments) in
            self.assignments = assignments
            print("Assignments set")
        }
    }
    
    func filterAssignments(by teacher: Teacher)  {
        guard let teacherRecord = teacher.record, self.assignments.count > 0 else { return }
        let teacherReference = CKReference(record: teacherRecord, action: .none)
        let filteredAssignments = self.assignments.filter { $0.teacherRef == teacherReference }
        let teacherRecordName = teacherRecord.recordID.recordName
        teacherAssignmentsDict[teacherRecordName] = filteredAssignments.reversed()
    }
    
}
