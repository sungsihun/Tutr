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
  @IBOutlet weak var creationDateLabel: UILabel!
  var isExpanded: Bool = false
  
  func configureCellWith(assignment: Assignment) {
    
    let titleText = assignment.assignmentTitle
    
    var creationDateText: String?
    if let creationDate = assignment.createdAt {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM d, yyyy"
      creationDateText = dateFormatter.string(from: creationDate)
    }
    creationDateLabel.text = creationDateText
    
    descriptionLabel.text = self.isExpanded ? assignment.assignmentDescription : ""
    
    if isExpanded {
      backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
      titleLabel.textColor = UIColor.white
      descriptionLabel.textColor = UIColor.white
      creationDateLabel.textColor = UIColor.white
    } else {
      backgroundColor = UIColor.white
      titleLabel.textColor = UIColor.darkGray
      descriptionLabel.textColor = UIColor.darkGray
      creationDateLabel.textColor = UIColor.darkGray
    }
    
    if assignment.isComplete {
      let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
      attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
      titleLabel.attributedText = attributeString
    } else {
      let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: titleText)
      attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
      titleLabel.attributedText = attributeString
    }
  }
  
  func toggle() {
    isExpanded = !isExpanded
  }
  
}
