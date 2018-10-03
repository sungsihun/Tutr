//
//  AddTeacherViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-21.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//



import UIKit
import AVKit

protocol AddTeacherViewControllerDelegate: class {
    func add(teacherViewController controller: AddUserViewController, teacher: Teacher)
}

class AddUserViewController: UIViewController {
    
    // MARK: - Properties
    
    let activeUser = ActiveUser.shared
    var user: User! = nil // either teacher or student
    weak var delegate: AddTeacherViewControllerDelegate?
    
    // MARK : - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorView: UIView!
    
    // MARK: - Life Cycle
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNotificationCenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    

    
    private func setupUser() {
        
        CloudKitManager.createCKUser() { (success) in
            if !success { print("Could not save user"); return }
            
            CloudKitManager.getCKUserName(completion: { (firstName, lastName) in
                guard let firstName = firstName, let lastName = lastName else { self.nameTextField.text = "John Doe"; return}
                
                DispatchQueue.main.async {
                    self.nameTextField.text = "Hello, \(firstName) \(lastName)"
                    self.activityIndicatorView.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    private func createUser() {
        guard let subject = subjectTextField.text else { fatalError("Must be a subject") }
        let image: UIImage!
        
        if imageView.image == UIImage(named: "add-photo-centered") {
            image = UIImage(named: "defaultUser")
        } else {
            image = imageView.image
        }
        let textFieldText = nameTextField.text!
        let name = String(textFieldText[textFieldText.index(textFieldText.startIndex, offsetBy: 7
            )...])
        user = User(name: name, subject: subject, image: image)
        
        CloudKitManager.saveUserDetails(user: user) { (returnedUser) in
            DispatchQueue.main.async {
                self.activeUser.current = returnedUser
                self.activeUser.save()
                self.performSegue(withIdentifier: self.activeUser.currentCategory.segueID(), sender: self)
            }
        }
    }
    
    private func setupImageView() {
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupTextFields() {
        saveButton.isEnabled = false
        subjectTextField.delegate = self
        nameTextField.delegate = self
        
        subjectTextField.autocapitalizationType = .words
        
        subjectTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(checkTextField), for: UIControlEvents.editingChanged)
    }
    
    private func setupActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicatorView.isHidden = false
    }
    
    private func setupUI() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Custom Methods
    
    private func checkICloudDriveStatus() {
        CloudKitManager.requestPermission { (success) in
            if !success {
                DispatchQueue.main.async {
                    setAlertWith(title: "No iCloud account configured", message: "Please activate iCloud drive", from: self) { _ in
                        self.openSettings()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func openProgram(_ type: UIImagePickerControllerSourceType) {
        DispatchQueue.main.async {
            self.open(type)
        }
    }
    
    private func openSettings() {
        let settingsCloudKitURL = URL(string: "App-Prefs:root=CASTLE")
        UIApplication.shared.open(settingsCloudKitURL!)
    }
    
    private func openAppSettings() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    
    // MARK : - Actions
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        subjectTextField.resignFirstResponder()
        setupActivityIndicator()
        createUser()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == AVAuthorizationStatus.denied {
                setAlertWith(title: "Error", message: "Please enable access to camera", from: self) { action in
                    DispatchQueue.main.async {
                        self.openAppSettings()
                    }
                }
                
                
            } else if status == AVAuthorizationStatus.notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (success) in
                    if success { self.openProgram(.camera) }
                }
                
                
            } else {
                self.openProgram(.camera)
            }
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openProgram(.photoLibrary)
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
            
            if (self.view.frame.origin.y == 0) && ((view.frame.size.height - subjectTextField.frame.origin.y) <= keyboardHeight) {
                self.view.frame.origin.y += (keyboardHeight - subjectTextField.frame.origin.y)
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
}
