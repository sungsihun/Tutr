//
//  AddTeacherViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-21.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//



import UIKit

protocol AddTeacherViewControllerDelegate: class {
    func add(teacherViewController controller: AddUserViewController, teacher: Teacher)
}

class AddUserViewController: UIViewController {
    
    // MARK: - Properties
    
    let userDefaults = UserDefaults.standard
    var userType: UserType!
    var activeTeacher: Teacher?
    var activeStudent: Student?
    weak var delegate: AddTeacherViewControllerDelegate?

    
    // MARK : - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkICloudDriveStatus()
        setupActivityIndicator()
        addViewGestureRecogniser()
        addImageGestureRecogniser()
        setupImageView()
        setupTextFields()
        setupUser()
        setupUI()
        setupNotificationCenter()
    }
    
    // MARK: - Custom Methods
    
    private func checkICloudDriveStatus() {
        CloudKitManager.requestPermission { (success) in
            if !success {
                let alert = UIAlertController(title: "No iCloud account is configured", message: "Please activate your iCloud Drive", preferredStyle: .alert)
                
                let settingsCloudKitURL = URL(string: "App-Prefs:root=CASTLE")
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                    UIApplication.shared.open(settingsCloudKitURL!)
                })
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private func setupUser() {
        guard let userType = userType else { fatalError("User must have a type")}
        
        CloudKitManager.createUserOfType(userType.rawValue) { (success) in
            if !success { print("Could not save user"); return }
            
            CloudKitManager.getCurrentUserName(completion: { (firstName, lastName) in
                guard let firstName = firstName, let lastName = lastName else { self.nameTextField.text = "John Doe"; return}
                
                switch userType {
                case .Teachers: self.activeTeacher = Teacher(name: "\(firstName) \(lastName)")
                case .Students: self.activeStudent = Student(name: "\(firstName) \(lastName)")
                }
                
                DispatchQueue.main.async {
                    self.nameTextField.text = "Hello, \(firstName) \(lastName)!"
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    
    
    private func createTeacher() {
        guard let subjectText = subjectTextField.text else { fatalError("Must be a subject") }
        guard let activeTeacher = activeTeacher else { fatalError("No teacher was ever created") }
        let image = imageView.image ?? #imageLiteral(resourceName: "defaultUser")
        
        CloudKitManager.saveUserDetails(type: .Teachers, name: activeTeacher.name, subject: subjectText, image: image) { (success, teacher, _) in
            if success {
                self.activeTeacher = teacher
                self.userDefaults.set(true, forKey: "isTeacher")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "userCreatedSegue", sender: nil)
                }
                
            }
        }
    }
    
    private func createStudent() {
        guard let subjectText = subjectTextField.text else { fatalError("Must be a subject") }
        guard let activeStudent = activeStudent else { fatalError("No student was ever created") }
        let image = imageView.image ?? #imageLiteral(resourceName: "defaultUser")
        
        CloudKitManager.saveUserDetails(type: .Students, name: activeStudent.name, subject: subjectText, image: image) { (success, nil, student) in
            if success {
                self.activeStudent = student
                self.userDefaults.set(true, forKey: "isStudent")
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "userCreatedSegue", sender: nil)
                }
            }
        }
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
  

    
    // MARK : - Actions
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        guard let userType = userType else { fatalError("Must have a userType")}
        
        switch userType {
        case .Students: createStudent()
        case .Teachers: createTeacher()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    // MARK: - Setup
    
    private func setupImageView() {
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
    
    private func setupActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicatorView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userCreatedSegue" {
            let userListNav = segue.destination as! UINavigationController
            let userListVC = userListNav.viewControllers.first! as! UserListViewController
            
            userListVC.userType = userType
            
            switch userType! {
            case .Students: userListVC.activeStudent = activeStudent
            case .Teachers: userListVC.activeTeacher = activeTeacher
            }
            
        }
    }
    
    private func setupUI() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    }

}







// MARK: - Image Picker and Navigation Delegate

extension AddUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    private func open(_ sourceType: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Text Field

extension AddUserViewController: UITextFieldDelegate {
    
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

extension AddUserViewController {
    
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

// MARK: - Notification Center Methods

extension AddUserViewController {
  @objc func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardHeight = keyboardFrame.cgRectValue.height
      if self.view.frame.origin.y == 0 {
        self.view.frame.origin.y += (keyboardHeight - subjectTextField.frame.origin.y)
      }
    }
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    self.view.frame.origin.y = 0
  }
}
