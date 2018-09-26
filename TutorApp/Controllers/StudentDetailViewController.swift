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
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
  
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
        setupNotificationCenter()
    }

  
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Methods

    private func loadStudent() {
    
        profileView.isHidden = false
        homeworkView.isHidden = true
        
        nameLabel.text = student.name
        subjectLabel.text = student.subject
        fullNameLabel.text = student.name
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
  
    func setupAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit", message: "Please edit", preferredStyle: .alert)
      
        let edit = UIAlertAction(title: "Edit", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            self.student.assignments[indexPath.row].assignmentTitle = textField.text!
            self.homeworkTableView.reloadData()
        }
      
        alert.addTextField { (textField) in
            textField.text = self.student.assignments[indexPath.row].assignmentTitle
        }
      
      
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive) { (action:UIAlertAction!) in print("Cancel button tapped") }
      
        alert.addAction(dismiss)
        alert.addAction(edit)
      
        self.present(alert, animated: true)
    }
  
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

}



// MARK: - Table View Data Source

extension StudentDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell", for: indexPath) as! AssignmentCell
        cell.assignmentDescLabel.text = student.assignments[indexPath.row].assignmentTitle
      
        return cell
    }
}

// MARK: - Table View Delegate

extension StudentDetailViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            student.assignments.remove(at: indexPath.row)
            homeworkTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
  
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.student.assignments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
      
        let share = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.setupAlert(indexPath: indexPath)
        }
      
        share.backgroundColor = UIColor.blue
      
        return [delete, share]
    }
}





// MARK: - Text Field Delegate

extension StudentDetailViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        
        // Insert a new row at the top
        
        
      let newHomeworkItem = Assignment(assignmentTitle: textField.text!)
        student.assignments.insert(newHomeworkItem, at: 0)
        
        textField.text = ""
        let indexPath = IndexPath(row: 0, section: 0)
        homeworkTableView.insertRows(at: [indexPath], with: .automatic)
        
        homeworkTableView.reloadData()
        textField.resignFirstResponder()
        addHomeworkTextfield.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}

// MARK: - Notification Center Methods

extension StudentDetailViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
          
            if (self.view.frame.origin.y == 0) && ((view.frame.size.height - homeworkView.frame.origin.y) <= keyboardHeight) {
                self.view.frame.origin.y += (keyboardHeight - homeworkView.frame.origin.y)
            }
        }
    }
  
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
}
