//
//  AssignmentsController.swift
//  Tutr Extension
//
//  Created by Henry Cooper on 03/10/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import WatchKit
import Foundation


class AssignmentsController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    var assignments = [Assignment]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let assignmentsData = context as? Data {
            do {
                let assignments = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(assignmentsData) as! [Assignment]
                self.assignments = assignments
            } catch {
                print(error.localizedDescription)
            }
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        loadAssignments()
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func loadAssignments() {
        table.setNumberOfRows(assignments.count, withRowType: "AssignmentRow")
        for i in 0..<assignments.count {
            if let row = table.rowController(at: i) as? AssignmentRow {
                row.assignmentLabel.setText(assignments[i].assignmentTitle)
            }
        }
    }

}
