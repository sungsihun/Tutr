//
//  AssignmentCell.swift
//  TutorApp
//
//  Created by Henry Cooper on 19/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import Foundation

class AssignmentCell: UITableViewCell {

    // MARK: - Outlets
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
  
    // MARK: - Properties
  
    var isExpanded: Bool = false

    // MARK: - Methods
  
    func configureCellWith(assignment: Assignment) {
      
        titleLabel.text = assignment.assignmentTitle
        descriptionLabel.text = self.isExpanded ? assignment.assignmentDescription : ""
        if isExpanded {
            self.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
            titleLabel.textColor = UIColor.white
            descriptionLabel.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.darkGray
            descriptionLabel.textColor = UIColor.darkGray
        }
    }
  
    func toggle() {
        isExpanded = !isExpanded
    }
}
