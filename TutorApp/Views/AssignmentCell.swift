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
      
      if assignment.isComplete {
        self.accessoryType = .checkmark
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: assignment.assignmentTitle)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        titleLabel.attributedText = attributeString
      } else {
        self.accessoryType = .none
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: assignment.assignmentTitle)
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
        
        titleLabel.attributedText = attributeString
      }
    }
  
    func toggle() {
        isExpanded = !isExpanded
    }
}
