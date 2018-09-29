//
//  TeacherListViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import CloudKit

class TeacherListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var teachers = [Teacher]()
    let userDefaults = UserDefaults.standard
    var selectedTeacher: Teacher?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSpinner()
        getStudent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(performSegueChecker), name: .assignmentsChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Fetching student
    
    private func getStudent() {
        getCurrentStudent {
            CloudKitManager.fetchTeachers { (teachers) in
                if let teachers = teachers { self.teachers = teachers }
                DispatchQueue.main.async {
                    if let filterDefaults = self.userDefaults.string(forKey: "filterBy") {
                        self.setupTableView(filterBy: filterDefaults)
                    }
                    self.stopSpinner()
                }
            }
        }
    }
    
    private func getCurrentStudent(completion: @escaping () -> ()) {
        if let _ = ActiveUser.shared.current as? Student {
            completion()
        } else {
            guard let recordIDString = userDefaults.string(forKey: ActiveUser.recordID) else { fatalError() }
            let recordID = CKRecordID(recordName: recordIDString)
            CloudKitManager.getStudentFromRecordID(recordID) { (student) in
                ActiveUser.shared.current = student
                completion()
            }
        }
    }
    
    
    
    // MARK: - Action
    
    @IBAction func filterTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Filter By:", message: nil, preferredStyle: .actionSheet)
        let nameSortAction = UIAlertAction(title: "Name", style: .default) { _ in
            self.setupTableView(filterBy: "Name")
        }
        let subjectSortAction = UIAlertAction(title: "Subject", style: .default) { _ in
            self.setupTableView(filterBy: "Subject")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(nameSortAction)
        controller.addAction(subjectSortAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: - Table View Delegate & Data Source

extension TeacherListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if teachers.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel = UILabel()
            noDataLabel.text = "No Teachers!\nA teacher can find you using your email address."
            noDataLabel.font = UIFont(name: "Dosis", size: 17)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath) as! TeacherCell
        let teacher = teachers[indexPath.row]
        cell.configure(with: teacher)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeacher = teachers[indexPath.row]
        self.selectedTeacher = selectedTeacher
        let currentStudent = ActiveUser.shared.current as! Student
        guard let currentStudentRecord = currentStudent.record else { fatalError("No student record") }
        self.spinner.startAnimating()
        CloudKitManager.getLatestStudentRecord(with: currentStudentRecord.recordID) { (newStudentRecord) in
            guard let newStudentRecord = newStudentRecord else { fatalError("Could not get newStudentRecord") }
            ActiveUser.shared.current = Student(with: newStudentRecord)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
}


// MARK: - UI

extension TeacherListViewController {
    
    private func setupUI() {
        
        // MARK: - Navigation Bar
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.title = "My Teachers"
        // set header height constraint for different devices
        if UIDevice().userInterfaceIdiom == .phone {
            headerHeightConstraint.constant = getHeaderImageHeightForCurrentDevice()
        }
        

        
    }
    
    private func setupSpinner() {
        self.spinner.startAnimating()
        self.spinner.hidesWhenStopped = true
        self.tableView.isHidden = true
    }
    
    private func stopSpinner() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.spinner.stopAnimating()
        }
    }
    
    
    
    
    private func setupTableView(filterBy: String) {
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView(frame: .zero)
        
        
        
        if filterBy == "Name" {
            self.teachers = self.teachers.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            self.teachers = self.teachers.sorted { $0.subject.lowercased() < $1.subject.lowercased() }
        }
        
        self.userDefaults.set(filterBy, forKey: "filterBy")
        self.tableView.reloadData()
    }
    
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        case 2436: // iPhone X
            return 175
        default: // Every other iPhone
            return 145
        }
    }
    
}

extension TeacherListViewController {
    
    // MARK: - Segue
    
    @objc private func performSegueChecker() {
        if selectedTeacher == nil { return }
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.performSegue(withIdentifier: "showAssignments", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAssignments" {
            let nav = segue.destination as! UINavigationController
            let assignmentsVC = nav.viewControllers.first! as! AssignmentListViewController
            guard let selectedTeacher = self.selectedTeacher, let teacherRecord = selectedTeacher.record else { fatalError("Somehow no teacher selected") }
            let currentStudent = ActiveUser.shared.current as! Student
            currentStudent.filterAssignments(by: selectedTeacher)
            assignmentsVC.assignments = currentStudent.teacherAssignmentsDict[teacherRecord.recordID.recordName]
        }
        
    }
}




