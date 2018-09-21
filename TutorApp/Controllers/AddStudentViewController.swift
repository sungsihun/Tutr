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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
  
    
    
    // MARK: - Properties
    
    weak var delegate: AddStudentViewControllerDelegate?
    
    
    
    
    // MARK: - Action Methods
    
    @IBAction func savePressed(_ sender: Any) {
        guard  let name = nameTextField.text else { return }
        guard let age = Int(ageTextField.text!) else { return }
        guard let subject = subjectTextField.text else { return }
        
        var student = Student(name: name, age: age, subjectStudying: subject)
        
        if studentImageView.image == #imageLiteral(resourceName: "addImage") {
            student.image = UIImage(named: "default-student")
        } else {
            student.image = studentImageView.image
        }
        
        delegate?.add(studentViewController: self, student: student)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        addViewGestureRecogniser()
        addImageGestureRecogniser()
        setupStudentImageView()
        setupTextFields()
    }
    
    
    
    // MARK: - Setup
    
    private func setupStudentImageView() {
        studentImageView.layer.borderWidth = 1.5
        studentImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupTextFields() {
        saveButton.isEnabled = false
        subjectTextField.delegate = self
        ageTextField.delegate = self
        nameTextField.delegate = self
        
        subjectTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
        ageTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
    }
    

}






// MARK: - Image Picker and Navigation Delegate

extension AddStudentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    private func open(_ sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        studentImageView.image = image
        dismiss(animated: true, completion: nil)
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
        let age = ageTextField.text ?? ""
        let subject = subjectTextField.text ?? ""
        if (age.isInt()) && !(name.isEmpty || age.isEmpty || subject.isEmpty) {
            saveButton.isEnabled = true
            saveButton.backgroundColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor.lightGray
        }
    }
}

// MARK: - Gesture Recognisers

extension AddStudentViewController {
    
    private func addViewGestureRecogniser() {
        let tapGestureRecogniser = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGestureRecogniser)
        tapGestureRecogniser.addTarget(self, action: #selector(handleViewRecogniserTap(_:)))
    }
    
    private func addImageGestureRecogniser() {
        let tapRecogniser = UITapGestureRecognizer()
        studentImageView.addGestureRecognizer(tapRecogniser)
        tapRecogniser.addTarget(self, action: #selector(handleTap(_:)))
    }
    
    @objc private func handleViewRecogniserTap(_ recogniser: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func handleTap(_ recogniser: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Add Image", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {_ in
            self.open(.camera)
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.open(.photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension String {
    
    func isInt() -> Bool {
        return Int(self) != nil
    }
}
