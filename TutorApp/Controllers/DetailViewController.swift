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
    @IBOutlet weak var studentDetailsButton: UIButton!
    @IBOutlet weak var studentHomeworkButton: UIButton!
    
    
    // MARK: - Action Methods
    
    @IBAction func studentDetailsPressed(_ sender: Any) {
        toggle()
    }
    
    @IBAction func studentHomeworkPressed(_ sender: Any) {
        toggle()
    }
    
    
    // MARK: - Properties
  
    var student: Student?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudent()
    }
    
    
    // MARK: - Custom Methods

    private func loadStudent() {
        if let student = student {
            nameLabel.text = student.name
            ageLabel.text = String(student.age)
            subjectLabel.text = student.subjectStudying
            
            studentImageView.image = student.image
            studentImageView.layer.cornerRadius = studentImageView.frame.size.height / 2
            self.title = student.name
        }
        
        studentDetailsButton.isSelected = true
        studentDetailsButton.isEnabled = false
    }
    
    private func toggle() {
        studentDetailsButton.isSelected = !studentDetailsButton.isSelected
        studentHomeworkButton.isSelected = !studentHomeworkButton.isSelected
        studentDetailsButton.isEnabled = !studentDetailsButton.isSelected
        studentHomeworkButton.isEnabled = !studentHomeworkButton.isSelected
    }

}
