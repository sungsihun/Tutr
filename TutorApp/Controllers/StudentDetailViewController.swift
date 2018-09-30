//
//  StudentDetailViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-18.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import CloudKit


protocol StudentDetailViewControllerDelegate: class {
    func studentDetailViewController(_ controller: StudentDetailViewController, didUpdate record: CKRecord?)
}

class StudentDetailViewController: UIViewController {
    
    // MARK: - Always Viewable Outlets
    
    @IBOutlet weak var studentImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Homework Viewable Outlets
    
    @IBOutlet weak var assignmentsTableView: UITableView!
    
    // MARK: - Action Methods
    
    @IBAction func addAssignmentPressed(_ sender: UIButton) {
        setupBlurredBackgroundView()
    }
    
    // MARK: - Properties
    
    var student: Student!
    var activeTextField = UITextField()
    var indexPathForEditRow: IndexPath!
    var correctAssignments = [Assignment]()
    let noDataLabel = UILabel()
    weak var delegate: StudentDetailViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStudent()
        setupUI()
        setTextForEmptyTableView()
        loadStudentAssignments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Custom Methods
    
    private func loadStudent() {
        nameLabel.text = student.name
        subjectLabel.text = student.subject
        studentImageView.image = student.image
    }
    
    private func loadStudentAssignments() {
        let activeTeacher = ActiveUser.shared.current as! Teacher
        guard let recordName = activeTeacher.record?.recordID.recordName else { fatalError() }
        student.filterAssignments(by: activeTeacher)
        let assignmentsDict = student.teacherAssignmentsDict
        correctAssignments = assignmentsDict[recordName] ?? [Assignment]()
        assignmentsTableView.reloadData()
    }
    
    private func setupUI() {
        
        // MARK: - Navigation Bar
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // MARK: - Table View
        
        assignmentsTableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    func setupAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit", message: "Please edit", preferredStyle: .alert)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            self.correctAssignments[indexPath.row].assignmentTitle = textField.text!
            self.assignmentsTableView.reloadData()
            let titleTextField = alert.textFields![0] as UITextField
            let descriptionTextField = alert.textFields![1] as UITextField
            
            self.correctAssignments[indexPath.row].assignmentTitle = titleTextField.text!
            self.correctAssignments[indexPath.row].assignmentDescription = descriptionTextField.text!
            
            self.assignmentsTableView.reloadData()
        }
        
        alert.addTextField { (textField) in
            textField.text = self.correctAssignments[indexPath.row].assignmentTitle
        }
        alert.addTextField { (textField) in
            textField.text = self.correctAssignments[indexPath.row].assignmentDescription
        }
        
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive)
        
        alert.addAction(dismiss)
        alert.addAction(edit)
        
        self.present(alert, animated: true)
    }
    
    private func setupBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        view.addSubview(blurredBackgroundView)
    }
    
    private func setTextForEmptyTableView() {
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
        assignmentsTableView.addSubview(noDataLabel)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.centerYAnchor.constraint(equalTo: assignmentsTableView.centerYAnchor, constant: assignmentsTableView.frame.size.height/8).isActive = true
        noDataLabel.centerXAnchor.constraint(equalTo: assignmentsTableView.centerXAnchor).isActive = true
        
    }
    
    func updateTableView() {
        if correctAssignments.count > 0 {
            assignmentsTableView.backgroundView = nil
            assignmentsTableView.separatorStyle = .singleLine
            noDataLabel.isHidden = true
            assignmentsTableView.isScrollEnabled = true
        } else {
            // For Empty Table View
            noDataLabel.isHidden = false
            assignmentsTableView.isScrollEnabled = false
        }
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
                let currentAssignment = correctAssignments[indexPathForEditRow.row]
                editAssignmentVC.assignment = currentAssignment
                editAssignmentVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.isNavigationBarHidden = true
            }
        }
    }
}



extension StudentDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        updateTableView()
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return correctAssignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentCell
        
        let assignment = correctAssignments[indexPath.row]
        
        cell.configureCellWith(assignment: assignment)
        updateTableView()
        return cell
    }
}





// MARK: - Table View Delegate

extension StudentDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let assignmentToDelete = self.correctAssignments[indexPath.row]
            self.deleteAssignment(assignmentToDelete) {
                self.correctAssignments.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
            
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
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete = UIContextualAction(style: .normal, title:  "Complete") { _, _, _ in
            let assignment = self.correctAssignments[indexPath.row]
            assignment.isComplete = !assignment.isComplete
            CloudKitManager.updateAssignment(assignment, for: self.student){ (records) in
                guard let records = records else { fatalError() }
                self.student.record = records.filter { $0.recordType == "Students" }.first!
                self.delegate?.studentDetailViewController(self, didUpdate: self.student.record)
                DispatchQueue.main.async {
                    self.assignmentsTableView.reloadData()
                }
            }
        }
        
        complete.backgroundColor = UIColor.blue
        let configuration = UISwipeActionsConfiguration(actions: [complete])
        return configuration
    }
}

// MARK: - Delete Assignment

extension StudentDetailViewController {
    
    private func deleteAssignment(_ assignment: Assignment, completion: @escaping () -> ()) {
        CloudKitManager.deleteAssignment(assignment, from: student) { (newStudentRecord) in
            guard let newStudentRecord = newStudentRecord else { fatalError() }
            self.student.record = newStudentRecord
            self.delegate?.studentDetailViewController(self, didUpdate: self.student.record!)
            completion()
        }
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
        correctAssignments.insert(newAssignment, at: 0)
        let teacher = ActiveUser.shared.current as! Teacher
        let indexPath = IndexPath(row: 0, section: 0)
        assignmentsTableView.insertRows(at: [indexPath], with: .automatic)
        CloudKitManager.add(assignment: newAssignment, from: teacher, to: student) { (records) in
            guard let records = records else { fatalError() }
            self.student.record = records.filter { $0.recordType == "Students" }.first!
            let newAssignmentRecord = records.filter { $0.recordType == "Assignments" }.first!
            self.correctAssignments[0].record = newAssignmentRecord
            self.delegate?.studentDetailViewController(self, didUpdate: self.student.record)
            DispatchQueue.main.async {
                self.assignmentsTableView.reloadData()
            }
        }
    }
}

// MARK: - EditAssignmentController Delegate Methods

extension StudentDetailViewController: EditAssignmentControllerDelegate {
    
    func editAssignment(editedAssignment: Assignment) {
        correctAssignments[indexPathForEditRow.row] = editedAssignment
        assignmentsTableView.reloadData()
        CloudKitManager.updateAssignment(editedAssignment, for: student) { (records) in
            guard let records = records else { fatalError() }
            self.student.record = records.filter { $0.recordType == "Students" }.first!
            self.delegate?.studentDetailViewController(self, didUpdate: self.student.record)
        }
    }
    
}


extension StudentDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTableView()
    }
}
