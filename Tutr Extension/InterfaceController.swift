//
//  InterfaceController.swift
//  Tutr Extension
//
//  Created by Henry Cooper on 03/10/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    var studentDict = [String:Data]()
    let sharedStudents = WatchStudents.sharedInstance
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        studentDict = sharedStudents.studentDict
        loadStudents()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func loadStudents() {
        table.setNumberOfRows(studentDict.count, withRowType: "NameRow")
        for i in 0..<studentDict.count {
            if let row = table.rowController(at: i) as? NameRow {
                let currentKey = Array(studentDict.keys)[i]
                row.nameLabel.setText(currentKey)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let currentStudent = Array(studentDict.keys)[rowIndex]
        self.pushController(withName: "AssignmentsViewController", context: studentDict[currentStudent])
    }
    
}
