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
    @IBOutlet weak var assignmentsTableView: UITableView!
    
    // MARK: - Action Methods
    
    @IBAction func studentDetailsPressed(_ sender: Any) { toggle() }
    @IBAction func studentHomeworkPressed(_ sender: Any) { toggle() }
  
    @IBAction func addAssignmentPressed(_ sender: UIButton) {
        setupBlurredBackgroundView()
    }
  
    // MARK: - Properties
  
    var student: Student!
    var activeTextField = UITextField()
    var indexPathForEditRow: IndexPath!

    // MARK: - Life Cycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudent()
        setupUI()
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
    
    private func loadStudentAssignments() {
        
    }
    
    private func toggle() {
        
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
        
        assignmentsTableView.tableFooterView = UIView(frame: .zero)
    }
  
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
  
    private func setupBlurredBackgroundView() {
      let blurredBackgroundView = UIVisualEffectView()
      blurredBackgroundView.frame = view.frame
      blurredBackgroundView.effect = UIBlurEffect(style: .dark)
      view.addSubview(blurredBackgroundView)
    }
  
    //MARK: - Segue
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAssignmentSegue" {
            if let addAssignmentVC = segue.destination as? AddAssignmentViewController {
                addAssignmentVC.delegate = self
                addAssignmentVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.isNavigationBarHidden = true
            }
        }
      
        if segue.identifier == "editAssignmentSegue" {
            if let editAssignmentVC = segue.destination as? EditAssignmentViewController {
                editAssignmentVC.delegate = self
                let currentAssignment = student.assignments[indexPathForEditRow.row]
                editAssignmentVC.assignment = currentAssignment
                editAssignmentVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.isNavigationBarHidden = true
            }
        }
    }
}

// MARK: - Table View Data Source

extension StudentDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if student.assignments.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel = UILabel()
            let attributedString = NSMutableAttributedString(string: "Press  ")
            let addDescImageAttachment = NSTextAttachment()
            addDescImageAttachment.image = UIImage(named: "add-desc-selected")
            addDescImageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            attributedString.append(NSAttributedString(attachment: addDescImageAttachment))
            attributedString.append(NSAttributedString(string: "  To Add A New Assignment!"))
            noDataLabel.attributedText = attributedString
          
            noDataLabel.font = UIFont(name: "Dosis", size: 17)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentCell
      
        let assignment = student.assignments[indexPath.row]
        cell.configureCellWith(assignment: assignment)
      
        return cell
    }
}

// MARK: - Table View Delegate

extension StudentDetailViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
            student.assignments.remove(at: indexPath.row)
            assignmentsTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.student.assignments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
      
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.indexPathForEditRow = indexPath
            self.setupBlurredBackgroundView()
            self.performSegue(withIdentifier: "editAssignmentSegue", sender: nil)
        }
      
        edit.backgroundColor = UIColor.blue
      
        return [delete, edit]
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AssignmentCell
        cell.toggle()
        tableView.reloadData()
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

// MARK: - AddAssignmentController Delegate Methods

extension StudentDetailViewController: AddAssignmentControllerDelegate {

    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        self.navigationController?.isNavigationBarHidden = false
    }
  
    func addAssignment(newAssignment: Assignment) {
        student.assignments.insert(newAssignment, at: 0)
        let teacher = ActiveUser.shared.current as! Teacher
        let indexPath = IndexPath(row: 0, section: 0)
        assignmentsTableView.insertRows(at: [indexPath], with: .automatic)
        CloudKitManager.add(assignment: newAssignment, from: teacher, to: student) { (records) in
            guard let records = records else { fatalError() }
            self.student.record = records.filter { $0.recordType == "Students" }.first!
            DispatchQueue.main.async {
                self.assignmentsTableView.reloadData()
            }
        }
    }
  
}

// MARK: - EditAssignmentController Delegate Methods

extension StudentDetailViewController: EditAssignmentControllerDelegate {
  
    func editAssignment(editedAssignment: Assignment) {
        student.assignments[self.indexPathForEditRow.row] = editedAssignment
        assignmentsTableView.reloadData()
      
//        student.assignments.insert(editedAssignment, at: 0)
//        let teacher = ActiveUser.shared.current as! Teacher
//        let indexPath = IndexPath(row: 0, section: 0)
//        assignmentsTableView.insertRows(at: [indexPath], with: .automatic)
//        CloudKitManager.add(assignment: editedAssignment, from: teacher, to: student) { (records) in
//            guard let records = records else { fatalError() }
//            self.student.record = records.filter { $0.recordType == "Students" }.first!
//            DispatchQueue.main.async {
//                self.assignmentsTableView.reloadData()
//            }
//        }
    }
  
}
