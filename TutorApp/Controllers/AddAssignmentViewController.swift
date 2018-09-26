//
//  AddAssignmentViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-25.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

protocol AddAssignmentControllerDelegate: class {
    func removeBlurredBackgroundView()
    func addAssignment(newAssignment: Assignment)
}

class AddAssignmentViewController: UIViewController {

    // MARK: - Properties
  
    weak var delegate: AddAssignmentControllerDelegate?
    var assignment: Assignment!
  
    // MARK: - Outlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addButton: UIButton!
  
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
  
    // MARK: - Actions
  
    @IBAction func dismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
  
    @IBAction func addTapped(_ sender: UIButton) {
        let title = titleTextField.text
        let description = descriptionTextView.text
        assignment = Assignment(assignmentTitle: title!, assignmentDescription: description!)
        delegate!.addAssignment(newAssignment: assignment)
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
  
    @IBAction func backgroundTapped(_ sender: Any) {
        self.view.frame.origin.y = 0
        self.view.endEditing(true)
    }
  
    // MARK: - Notification Centre
  
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
  
    // MARK: - Custom Methods
  
    private func setupTextField() {
        addButton.isEnabled = false
        addButton.backgroundColor = UIColor.lightGray
      
        // set text field placeholder color
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
      
        titleTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
    }
  
    private func setupTextView() {
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(0, -4, 0, 0)
    }
}

// MARK: - Text Field Delegate

extension AddAssignmentViewController: UITextFieldDelegate {
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
    @objc private func checkTextField() {
        let title = titleTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
      
        if !(title.isEmpty || description.isEmpty) {
            addButton.isEnabled = true
            addButton.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
        } else {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor.lightGray
        }
    }
}

// MARK: - Notification Centre Methods

extension AddAssignmentViewController {
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

extension AddAssignmentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkTextField()
    }
  
    // text view placeholder
  
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
        }
    }
  
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
