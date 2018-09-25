//
//  StudentAssignmentCell.swift
//  TutorApp
//
//  Created by NICE on 2018-09-25.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class StudentAssignmentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var expanded: Bool = false
  
    func configure(assignment: Assignment) {
        self.titleLabel.text = assignment.assignmentTitle
        self.descriptionLabel.text = self.expanded ? assignment.assignmentDescription: ""
        if self.expanded {
            self.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
            self.titleLabel.textColor = UIColor.white
            self.descriptionLabel.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
            self.titleLabel.textColor = UIColor.darkGray
            self.descriptionLabel.textColor = UIColor.darkGray
        }
    }
}
