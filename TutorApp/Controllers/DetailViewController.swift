//
//  DetailViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-18.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Outlets
  
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
  
    // MARK: - Properties
  
    var student: Student?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let student = student {
            nameLabel.text = student.name
            ageLabel.text = String(student.age)
            subjectLabel.text = student.subjectStudying
          
            studentImageView.image = student.image
            studentImageView.layer.cornerRadius = studentImageView.frame.size.height / 2

        }
    }

}
