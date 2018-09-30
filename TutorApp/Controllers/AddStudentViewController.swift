//
//  AddStudentViewController.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

protocol AddStudentViewControllerDelegate: class {
    func add(studentViewController controller: AddStudentViewController, student: Student)
}

class AddStudentViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
  
    // MARK: - Properties
    
    weak var delegate: AddStudentViewControllerDelegate?
    var emailTextField: UITextField!
    var activeStudent: Student?
    
    // MARK: - Action Methods
  
    @IBAction func savePressed(_ sender: Any) {
        guard let activeStudent = activeStudent else { fatalError() }
        delegate?.add(studentViewController: self, student: activeStudent)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        let alertCtrl = UIAlertController(title: "Add Student", message: "Enter student's email", preferredStyle: .alert)
      
        // Add text field to alert controller
        alertCtrl.addTextField { (textField) in
          self.emailTextField = textField
          self.emailTextField.placeholder = "student@example.com"
        }
      
        // Add cancel button to alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
        // "Add" button with callback
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            self.spinner.isHidden = false
            self.spinner.startAnimating()
            guard let textField = alertCtrl.textFields?.first else { return }
            self.addUserWith(email: textField.text!)
        }
        
        alertCtrl.addAction(addAction)
        alertCtrl.addAction(cancelAction)
        
        present(alertCtrl, animated: true, completion: nil)
    }
  
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        spinner.isHidden = true
        setupStudentImageView()
        setupTextFields()
    }
    
    
    
    // MARK: - Custom Methods
    
    private func addUserWith(email: String) {
        CloudKitManager.findStudentWith(email: email) { (student) in
            guard let student = student else {
                DispatchQueue.main.async {
                    self.showStudentNotFound()
                }
                return
            }
            self.setFields(with: student)
            self.activeStudent = student
        }
    }
    
    private func setFields(with student: Student) {
        DispatchQueue.main.async {
            self.nameTextField.text = student.name
            self.subjectTextField.text = student.subject
            self.studentImageView.image = student.image
            self.checkTextField()
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
        }

    }
    
    private func showStudentNotFound() {
        let alertController = UIAlertController(title: "Error", message: "User not found", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
        present(alertController, animated: true, completion: nil)
    }
  
    // MARK: - Setup
    
    private func setupStudentImageView() {
        studentImageView.layer.borderWidth = 1.5
        studentImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupTextFields() {
        saveButton.isEnabled = false
        subjectTextField.delegate = self
        nameTextField.delegate = self
    }

}

// MARK: - Text Field

extension AddStudentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func checkTextField() {
        let name = nameTextField.text ?? ""
        let subject = subjectTextField.text ?? ""
        if !(name.isEmpty || subject.isEmpty) {
            saveButton.isEnabled = true
            saveButton.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor.lightGray
        }
    }
}

extension String {
    
    func isInt() -> Bool {
        return Int(self) != nil
    }
}
