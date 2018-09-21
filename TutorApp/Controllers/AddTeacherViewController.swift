//
//  AddTeacherViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-21.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

protocol AddTeacherViewControllerDelegate: class {
  func add(teacherViewController controller: AddTeacherViewController, teacher: Teacher)
}

class AddTeacherViewController: UIViewController {

    // MARK: - Properties
  
    weak var delegate: AddTeacherViewControllerDelegate?
  
    // MARK : - Outlets
  
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        addViewGestureRecogniser()
        addImageGestureRecogniser()
        setupStudentImageView()
        setupTextFields()
    }
    

    // MARK : - Actions
  
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        guard let subject = subjectTextField.text else { return }
      
        let teacher = Teacher(name: name, subject: subject)
      
        if imageView.image == #imageLiteral(resourceName: "addImage") {
          teacher.image = UIImage(named: "default-student")
        } else {
          teacher.image = imageView.image
        }
      
        delegate?.add(teacherViewController: self, teacher: teacher)
    }
  
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
    // MARK: - Setup
  
    private func setupStudentImageView() {
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
  
    private func setupTextFields() {
        saveButton.isEnabled = false
        subjectTextField.delegate = self
        nameTextField.delegate = self
      
        subjectTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
    }

}

// MARK: - Image Picker and Navigation Delegate

extension AddTeacherViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  
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
    imageView.image = image
    dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Text Field

extension AddTeacherViewController: UITextFieldDelegate {
  
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

// MARK: - Gesture Recognisers

extension AddTeacherViewController {
  
    private func addViewGestureRecogniser() {
        let tapGestureRecogniser = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGestureRecogniser)
        tapGestureRecogniser.addTarget(self, action: #selector(handleViewRecogniserTap(_:)))
    }
  
    private func addImageGestureRecogniser() {
        let tapRecogniser = UITapGestureRecognizer()
        imageView.addGestureRecognizer(tapRecogniser)
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

