//
//  EditAssignmentViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-27.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import CloudKit

protocol EditAssignmentControllerDelegate: class {
    func removeBlurredBackgroundView()
    func editAssignment(editedAssignment: Assignment)
}

class EditAssignmentViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: EditAssignmentControllerDelegate?
    var assignment: Assignment!
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        setupTextView()
    }
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Methods
    
    private func setupTextField() {
        titleTextField.text = assignment?.assignmentTitle
    }
    
    private func setupTextView() {
        
        // line up with title text field
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
        
        descriptionTextView.text = assignment?.assignmentDescription
      
        titleTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
    }
    
    // MARK: - Notification Centre
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        let title = titleTextField.text
        let description = descriptionTextView.text
        let activeTeacher = ActiveUser.shared.current as! Teacher
        let teacherRef = CKReference(record: activeTeacher.record!, action: .none)
        guard let record = assignment.record else { fatalError("Assignment has no record") }
        let newAssignment = Assignment(assignmentTitle: title!, assignmentDescription: description!, teacherRef: teacherRef)
        newAssignment.record = record
        delegate?.editAssignment(editedAssignment: newAssignment)
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        self.view.frame.origin.y = 0
        self.view.endEditing(true)
    }
}




// MARK: - Text Field Delegate

extension EditAssignmentViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
  @objc private func checkTextField() {
    let title = titleTextField.text ?? ""
    let description = descriptionTextView.text ?? ""
    
    if !(title.isEmpty || description.isEmpty) && !(descriptionTextView.text == "Description") {
      editButton.isEnabled = true
      editButton.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
    } else {
      editButton.isEnabled = false
      editButton.backgroundColor = UIColor.lightGray
    }
  }
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLength = textField.text?.count ?? 0
        let newLength = currentLength + string.count - range.length
        print(range.length)
        return newLength < 25
    }
}

// MARK: - Notification Centre Methods

extension EditAssignmentViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            if (self.view.frame.origin.y == 0) && (popupView.frame.origin.y <= keyboardHeight) {
                self.view.frame.origin.y -= (keyboardHeight - popupView.frame.origin.y + 8)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
}

// MARK: - Text View Delegate

extension EditAssignmentViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
  
  func textViewDidChange(_ textView: UITextView) {
    checkTextField()
  }

}
