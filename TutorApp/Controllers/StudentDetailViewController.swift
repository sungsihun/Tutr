//
//  StudentDetailViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-18.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class StudentDetailViewController: UIViewController {

    // MARK: - Always Viewable Outlets
  
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var studentDetailsButton: UIButton!
    @IBOutlet weak var studentHomeworkButton: UIButton!
    
    // MARK: - Details Viewable Outlets
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var nextLessonLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    // MARK: - Homework Viewable Outlets
    
    @IBOutlet weak var homeworkView: UIView!
    @IBOutlet weak var homeworkTableView: UITableView!
    @IBOutlet weak var addHomeworkTextfield: UITextField!
    
    // MARK: - Action Methods
    
    @IBAction func studentDetailsPressed(_ sender: Any) { toggle() }
    @IBAction func studentHomeworkPressed(_ sender: Any) { toggle() }
    
    // MARK: - Properties
  
    var addCellCount = 1
    var cellTextfieldTag = 0
    var student: Student!
    var activeTextField = UITextField()

    // MARK: - Life Cycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudent()
        setupUI()
        setupGestureRecogniser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Custom Methods

    private func loadStudent() {
    
        profileView.isHidden = false
        homeworkView.isHidden = true
        
        nameLabel.text = student.name
        ageLabel.text = String(student.age)
        subjectLabel.text = student.subjectStudying
        
        studentImageView.image = student.image
    }
    
    private func toggle() {
        handleTap()
        
        studentDetailsButton.isSelected = !studentDetailsButton.isSelected
        studentHomeworkButton.isSelected = !studentHomeworkButton.isSelected
        
        studentDetailsButton.isUserInteractionEnabled = !studentDetailsButton.isSelected
        studentHomeworkButton.isUserInteractionEnabled = !studentHomeworkButton.isSelected
        
        profileView.isHidden = !profileView.isHidden
        homeworkView.isHidden = !homeworkView.isHidden

    }
    
    private func setupUI() {
        
        // MARK: - Navigation Bar
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
      
        // MARK: - Buttons
        
        studentDetailsButton.setTitleColor(UIColor.black, for: .selected)
        studentDetailsButton.setTitleColor(UIColor.black, for: .disabled)
        studentHomeworkButton.setTitleColor(UIColor.black, for: .disabled)
        studentHomeworkButton.setTitleColor(UIColor.black, for: .selected)
        studentDetailsButton.isSelected = true
        
        // MARK: - Table View
        
        homeworkTableView.tableFooterView = UIView(frame: .zero)
        homeworkTableView.allowsSelection = false;
        
        // MARK: - Text Field
        
        addHomeworkTextfield.delegate = self
    
    }
    
    private func setupGestureRecogniser() {
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecogniser)
    }
    
    @objc private func handleTap() {
        activeTextField.resignFirstResponder()
    }

}



// MARK: - Table View Data Source

extension StudentDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.homeworkItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell", for: indexPath) as! HomeworkCell
        cell.homeworkDescLabel.text = student.homeworkItems[indexPath.row].homeworkDescription

        return cell
    }
}

// MARK: - Table View Delegate

extension StudentDetailViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            student.homeworkItems.remove(at: indexPath.row)
            homeworkTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}





// MARK: - Text Field Delegate

extension StudentDetailViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        
        // Insert a new row at the top
        
        
      let newHomeworkItem = Homework(homeworkDescription: textField.text!)
        student.homeworkItems.insert(newHomeworkItem, at: 0)
        
        textField.text = ""
        let indexPath = IndexPath(row: 0, section: 0)
        homeworkTableView.insertRows(at: [indexPath], with: .automatic)
        
        homeworkTableView.reloadData()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}

