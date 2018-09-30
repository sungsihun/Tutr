//
//  CloudKitManager.swift
//  TutorApp
//
//  Created by Henry Cooper on 21/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


class CloudKitManager {
    
    static let container = CKContainer(identifier: "iCloud.com.henry.CloudKitScratch")
    static let db = container.publicCloudDatabase
    
    
    
    
    // MARK: - USERS
    
    // Creating A User
    
    static func createCKUser(completion: @escaping (Bool) -> ()) {
        
        // Get user permission
        
        requestPermission { (granted) in
            if !granted { print("User did not provide permission");
                return }
            
            // We have user permission, so get the recordID
            
            getCKUserID { (recordID) in
                guard let recordID = recordID else { fatalError("Could not get recordID") }
                let record = CKRecord(recordType: ActiveUser.shared.currentCategory.rawValue)
                let recordName = recordID.recordName
                
                record["userRef"] = recordName as NSString
                
                // Save the record
                
                self.save([record]) { (records) in
                    guard (records?.first) != nil else { completion(false); return }
                    completion(true)
                }
            }
        }
    }
    
    //  Requesting Permission
    
    static func requestPermission(completion: @escaping (Bool) -> ()) {
        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
            if let error = error { print(#line, error.localizedDescription) }
            if status != .granted {
                completion(false)
            }
            completion(true)
        }
    }
    
    //  Saving Records
    
    private static func save(_ records: [CKRecord], completionHandler: (([CKRecord]?) -> ())?) {
        let op = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        op.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error { print(#line, error.localizedDescription); completionHandler?(nil) }
            completionHandler?(records)
        }
        db.add(op)
    }
    
    //  Save User Details
    
    static func saveUserDetails(user: User, completion: @escaping (User?) -> ()) {
        
        let activeUser = ActiveUser.shared
        let type = activeUser.currentCategory
        
        getCurrentUserRecordOfType(type) { (userRecord) in
            
            guard let userRecord = userRecord else { fatalError("No user") }
            
            userRecord["name"] = user.name as NSString
            userRecord["subject"] = user.subject as NSString
            guard let data = UIImageJPEGRepresentation(user.image!, 0.0) else { print("Could not turn image to data"); return }
            
            getDataURL(from: data){ (url) in
                guard let url = url else { print("No url"); return }
                userRecord["image"] = CKAsset(fileURL: url)
            }
            
            
            
            
            save([userRecord]) { savedUserRecords in
                guard let savedUserRecords = savedUserRecords, let savedUserRecord = savedUserRecords.first else { fatalError("Could not save") }
                setRecordToUserDefaults(savedUserRecord)
                let returnedUser: User!
                
                switch activeUser.currentCategory {
                case .student: returnedUser = Student(savedUserRecord)
                case .teacher: returnedUser = Teacher(savedUserRecord)
                case .notSet: fatalError()
                }
                
                completion(returnedUser)
                
            }
        }
    }
    
    //  Get Name Of User
    
    static func getCKUserName(completion: @escaping (String?, String?) -> ()) {
        getCKUserID { (recordID) in
            guard let recordID = recordID else { fatalError("Could Not get recordID") }
            container.discoverUserIdentity(withUserRecordID: recordID, completionHandler: { (userId, error) in
                if let error = error { print(error.localizedDescription); return }
                guard let userId = userId else { return }
                completion(userId.nameComponents?.givenName, userId.nameComponents?.familyName)
            })
        }
    }
    
    // Get current userID
    
    static func getCKUserID(completion: @escaping (CKRecordID?) -> ()) {
        container.fetchUserRecordID { (recordID, error) in
            if let error = error { print(error.localizedDescription); return }
            completion(recordID)
        }
    }
    
    
    // MARK: - TEACHERS
    
     static func getUserRecord(with id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        let op = CKFetchRecordsOperation(recordIDs: [id])
        op.queuePriority = .veryHigh
        op.qualityOfService = .userInteractive
        op.perRecordCompletionBlock = { record, _, _ in
            print(CFAbsoluteTimeGetCurrent())
            completion(record)
        }
        db.add(op)
    }
    
    static func getTeacherFromRecordID(_ id: CKRecordID, completion: @escaping (Teacher?) -> ()) {
        getUserRecord(with: id) { (record) in
            guard let record = record else { completion(nil); return }
            let teacher = Teacher(record)
            completion(teacher)
        }
    }
    
    // Fetch teachers
    
    static func fetchTeachers(completion: @escaping ([Teacher]?) -> ()) {
        
        let student = ActiveUser.shared.current as! Student
        
        guard let record = student.record else { fatalError("Student has no record") }
        
        // Get the array of the teacher's students
        
        guard let teacherRefs = record["teachers"] as? Array<CKReference>  else { completion(nil); return }
        
        // Get the recordID of each student
        
        let ids = teacherRefs.map{ $0.recordID }
        
        // Get the record of each student
        
        let op = CKFetchRecordsOperation(recordIDs: ids)
        op.qualityOfService = .userInteractive
        op.queuePriority = .veryHigh
        var returnTeachers = [Teacher]()
        
        // Below is essentially a loop that is called for each record got
        
        op.perRecordCompletionBlock = { record, _, _ in
            if let teacher = Teacher(record) {
                returnTeachers.append(teacher)
            }
        }
        
        op.fetchRecordsCompletionBlock = { _, _ in
            completion(returnTeachers)
        }
        
        db.add(op)
    }
    
    
    
    // MARK: - STUDENTS
    
    // Add student to teacher list
    
    static func addStudent(_ student: Student, to teacher: Teacher, completion: @escaping ([CKRecord]?) -> ()) {
        
        guard let studentRecord = student.record, let teacherRecord = teacher.record else { fatalError("Missing record") }
        
        var studentResults = [CKReference]()
        var teacherResults = [CKReference]()
        
        let currentTeacher = CKReference(record: teacherRecord, action: .none)
        let currentStudent = CKReference(record: studentRecord, action: .none)
        
        if let studentRefs = teacherRecord["students"] as? [CKReference] {
            studentResults = studentRefs
        }
        if let teacherRefs = studentRecord["teachers"] as? [CKReference] {
            teacherResults = teacherRefs
        }
        
        teacherResults.append(currentTeacher)
        studentResults.append(currentStudent)
        
        studentRecord["teachers"] = teacherResults as NSArray
        teacherRecord["students"] = studentResults as NSArray
        
        save([teacherRecord, studentRecord]) { (records) in
            completion(records)
        }
    }
    
    // Fetch students
    
    static func fetchStudents(completion: @escaping ([Student]?) -> ()) {
        
        let teacher = ActiveUser.shared.current as! Teacher
        
        guard let record = teacher.record else { fatalError("Teacher has no record") }
        
        // Get the array of the teacher's students
        
        guard let studentRefs = record["students"] as? Array<CKReference>  else { completion(nil); return }
        
        // Get the recordID of each student
        
        let ids = studentRefs.map{ $0.recordID }
        
        // Get the record of each student
        
        let op = CKFetchRecordsOperation(recordIDs: ids)
        op.qualityOfService = .userInteractive
        op.queuePriority = .veryHigh
        var returnStudents = [Student]()
        
        // Below is essentially a loop that is called for each record got
        
        op.perRecordCompletionBlock = { record, _, _ in
            if let student = Student(with: record) {
                returnStudents.append(student)
            }
        }
        
        op.fetchRecordsCompletionBlock = { _, _ in
            completion(returnStudents)
        }
        
        db.add(op)
    }
    
    // Delete student
    
    static func deleteStudent(_ student: Student, completion: @escaping (Bool) -> ()) {
        guard let studentRecord = student.record else { fatalError() }
        let teacher = ActiveUser.shared.current as! Teacher
        guard let teacherRecord = teacher.record else { fatalError("Teacher has no record") }
        
        guard let studentRefs = teacherRecord["students"] as? [CKReference], let teacherRefs = studentRecord["teachers"] as? [CKReference]  else { completion(false); return }
        
        let newTeachersRefs = teacherRefs.filter { $0.recordID != teacherRecord.recordID }
        let newStudentsRefs = studentRefs.filter { $0.recordID != studentRecord.recordID }
        
        studentRecord["teachers"] = newTeachersRefs as NSArray
        teacherRecord["students"] = newStudentsRefs as NSArray
        
        save([teacherRecord, studentRecord]) { records in
            guard let records = records else { return }
            let teacherRecord = records.filter { $0.recordType == "Teachers" }.first!
            let teacher = Teacher(teacherRecord)
            ActiveUser.shared.current = teacher
            completion(true)
        }
    }
    
    // Get student record from CKID
    
    static private func getStudentRecord(with ckUserID: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        let predicate = NSPredicate(format: "userRef = %@", ckUserID.recordName)
        let query = CKQuery(recordType: ActiveUser.Category.student.rawValue, predicate: predicate)
        db.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error { print(error.localizedDescription); completion(nil) }
            completion(records?.first)
        }
    }
    
    static func getStudentFromCKUserID(_ id: CKRecordID, completion: @escaping (Student?) -> ()) {
        getStudentRecord(with: id) { (record) in
            guard let record = record else { completion(nil); return }
            let student = Student(with: record)
            completion(student)
        }
    }
    
    static func getStudentFromRecordID(_ id: CKRecordID, completion: @escaping (Student?) -> ()) {
        getUserRecord(with: id) { (record) in
            guard let record = record else { completion(nil); return }
            let student = Student(with: record)
            completion(student)
        }
    }
    
    // Search for student
    
    static func findStudentWith(email: String, completion: @escaping (Student?) -> ()) {
        container.discoverUserIdentity(withEmailAddress: email) { (userIdentity, error) in
            if let error = error { print(#line, error.localizedDescription); completion(nil) }
            guard let userIdentity = userIdentity,
                let recordID = userIdentity.userRecordID
                else { completion(nil); return }
            getStudentFromCKUserID(recordID) { (student) in
                completion(student)
            }
        }
    }
    
    
    // MARK: - Assignments
    
    static func add(assignment: Assignment, from teacher: Teacher, to student: Student, completion: @escaping ([CKRecord]?) -> ()) {
        
        var tempAssignments = [CKReference]()
        
        guard let studentRecord = student.record,
            let teacherRecord = teacher.record else {
                fatalError("Teacher or student is missing a record")
        }
        
        CloudKitManager.getUserRecord(with: studentRecord.recordID) { (newStudentRecord) in
            
            guard let newStudentRecord = newStudentRecord else { fatalError() }
            
            if let assignmentsRefs = newStudentRecord["assignments"] as? [CKReference] {
                tempAssignments = assignmentsRefs
            }
            
            let newAssignmentRecord = CKRecord(recordType: "Assignments")
            newAssignmentRecord["title"] = assignment.assignmentTitle as NSString
            newAssignmentRecord["description"] = assignment.assignmentDescription as NSString
            newAssignmentRecord["isComplete"] = assignment.isComplete
            let currentTeacher = CKReference(record: teacherRecord, action: .none)
            newAssignmentRecord["teacherRef"] = currentTeacher
            let newAssignmentRef = CKReference(record: newAssignmentRecord, action: .none)
            
            
            
            tempAssignments.append(newAssignmentRef)
            
            newStudentRecord["assignments"] = tempAssignments as NSArray
            
            
            save([newStudentRecord, newAssignmentRecord]) { (records) in
                completion(records)
            }
        }
    }
    
    static func updateAssignment(_ assignment: Assignment, for student: Student, completion: @escaping ([CKRecord]?) -> ()) {
        guard let assignmentRecord = assignment.record, let studentRecord = student.record else { fatalError() }
        assignmentRecord["title"] = assignment.assignmentTitle
        assignmentRecord["description"] = assignment.assignmentDescription
        assignmentRecord["isComplete"] = assignment.isComplete
        
        save([assignmentRecord, studentRecord]) { (records) in
            completion(records)
        }
    }
    
    static func getAssignmentsFrom(_ studentRecord: CKRecord?, completion: @escaping ([Assignment]) -> ()) {
        
        
        guard let record = studentRecord else { fatalError("No record") }
        if let assignmentsRefs = record["assignments"] as? [CKReference] {
            let ids = assignmentsRefs.map() { $0.recordID }
            var assignmentRecords = [CKRecord]()
            
            let op = CKFetchRecordsOperation(recordIDs: ids)
            op.queuePriority = .veryHigh
            op.qualityOfService = .userInteractive
            
            op.perRecordCompletionBlock = { record, _, error in
                if let error = error { print(#line, error.localizedDescription); return }
                guard let record = record else { print("Could not unwrap record"); return }
                assignmentRecords.append(record)
            }
            
            op.fetchRecordsCompletionBlock = { _, error in
                if let error = error { print(#line, error.localizedDescription); return}
                completion(getAssignmentsFrom(assignmentRecords))
            }
            db.add(op)
        } else {
            let assignments = [Assignment]()
            completion(assignments)
        }
        
        
    }
    
    private static func getAssignmentsFrom(_ records: [CKRecord]) -> [Assignment] {
        var assignments = [Assignment]()
        for record in records {
            
            guard let newAssignment = Assignment(record) else { fatalError() }
            assignments.append(newAssignment)
        }
        return assignments
        
    }
    
    static func deleteAssignment(_ assignment: Assignment, from student: Student, completion: @escaping (CKRecord?) -> ()) {
        
        guard let assignmentRecord = assignment.record, let studentRecord = student.record else { return }
        let recordID = assignmentRecord.recordID
        db.delete(withRecordID: recordID) { (_, error) in
            if let error = error { print(#line, error.localizedDescription) }
            guard let assignmentsRefs = studentRecord["assignments"] as? [CKReference] else { fatalError() }
            let newAssignmentRefs = assignmentsRefs.filter { $0.recordID != recordID }
            studentRecord["assignments"] = newAssignmentRefs
            save([studentRecord]) { (records) in
                guard let records = records else { fatalError() }
                completion(records.first)
            }
        }
    }
    
    
    
    
    
    // MARK: - HELPERS
    
    //  Get url of image
    
    private static func getDataURL(from data: Data, completion: (URL?) -> ()) {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID()).dat")
        do {
            try data.write(to: url)
            completion(url)
        } catch {
            completion(nil)
            print(#line, error.localizedDescription)
        }
    }
    
    //  Convert CKRecord To Data
    
    private static func setRecordToUserDefaults(_ record: CKRecord) {
        let data = NSKeyedArchiver.archivedData(withRootObject: record)
        UserDefaults.standard.set(data, forKey: "userRecord")
    }
    
    // Get 'User' record from ID
    
    private static func getUserWithID(_ id: CKRecordID, completion: @escaping (CKRecord?) -> ()) {
        db.fetch(withRecordID: id) { (user, error) in
            if let error = error { print(#line, error.localizedDescription) }
            completion(user)
        }
    }
    
    // Get teacher or students record
    
    private static func getCurrentUserRecordOfType(_ type: ActiveUser.Category, completion: @escaping (CKRecord?) -> ()) {
        
        getCKUserID { (recordID) in
            guard let recordID = recordID else { fatalError("Could not get recordID") }
            
            // Wrapper around the recordID
            
            let predicate = NSPredicate(format: "userRef = %@", recordID.recordName)
            let query = CKQuery(recordType: type.rawValue, predicate: predicate)
            
            self.db.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error { print(#line, error.localizedDescription); return }
                guard let record = records?.first else {
                    print("No record exists")
                    completion(nil)
                    return
                }
                completion(record)
            })
        }
    }
    
    
    
    
    
}


