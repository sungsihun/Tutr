//
//  StudentListViewController.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import CloudKit
import WatchConnectivity

var didLaunchFromShortcuts: Bool! = false

class StudentListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    
    var students: [Student] = []
    let userDefaults = UserDefaults.standard
    var selectedIndexRow: Int?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setShortcutItem()
        setupSpinner()
        setupUI()
        getTeacher()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkForShortcuts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .assignmentsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendStudentsToWatch), name: .assignmentsChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action Methods
    
    @IBAction func filterButtonPressed(_ sender: Any) {
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
    
    // MARK: - Custom Methods
    
    private func setShortcutItem() {
        let application = UIApplication.shared
        application.shortcutItems = ShortcutManager.setShortcutItem()
    }
    
    private func checkForShortcuts() {
        if didLaunchFromShortcuts { performSegue(withIdentifier: "addStudent", sender: self) }
    }
    
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        case 2436: // iPhone X
            return 175
        case 2688: // iPhone Xs Max
            return 175
        default: // Every other iPhone
            return 145
        }
    }
    
    private func getTeacher() {
        getCurrentTeacher {
            CloudKitManager.fetchStudents() { (students) in
                DispatchQueue.main.async {
                    if let students = students { self.students = students }
                    if let filterString = self.userDefaults.string(forKey: "filterBy") {
                        self.setupTableView(filterBy: filterString)
                    }
                    self.tableView.reloadData()
                    self.stopSpinner()
                }
            }
        }
    }
    
    private func getCurrentTeacher(completion: @escaping () -> ()) {
        guard let recordIDString = userDefaults.string(forKey: ActiveUser.recordID) else { fatalError() }
        let recordID = CKRecordID(recordName: recordIDString)
        CloudKitManager.getTeacherFromRecordID(recordID) { (teacher) in
            ActiveUser.shared.current = teacher
            completion()
        }
    }
    
    @objc private func stopSpinner() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.spinner.stopAnimating()
        }
    }
    
    private func setupTableView(filterBy: String) {
        tableView.separatorInset = UIEdgeInsets.zero
        
        if filterBy == "Name" {
            self.students = self.students.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            self.students = self.students.sorted { $0.subject.lowercased() < $1.subject.lowercased() }
        }
        
        self.userDefaults.set(filterBy, forKey: "filterBy")
        self.tableView.reloadData()
    }
    
    @objc private func sendStudentsToWatch() {
        if WCSession.isSupported() {
            var studentDict = [String:[String]]()
            for student in students {
                student.filterAssignments(by: ActiveUser.shared.current as! Teacher)
                let assignmentNames = student.assignments.map { $0.assignmentTitle }
                studentDict[student.name] = assignmentNames
            }
            let session = WCSession.default
            if session.isWatchAppInstalled {
                do {
                    let dict = ["studentDict":studentDict]
                    try session.updateApplicationContext(dict)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func setupUI() {
        
        // MARK: - Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.title = "My Students"
        // set header height constraint for different devices
        if UIDevice().userInterfaceIdiom == .phone {
            headerHeightConstraint.constant = getHeaderImageHeightForCurrentDevice()
        }
        
        tableView.tableFooterView = UIView(frame: .zero)

        
    }
    
    private func setupSpinner() {
        self.spinner.startAnimating()
        self.spinner.hidesWhenStopped = true
        self.tableView.isHidden = true
    }
    
    // MARK: - Segue
    
    var indexPathForSelectedRow: IndexPath? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStudent" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.viewControllers.first! as! AddStudentViewController
            controller.delegate = self
            controller.currentStudents = students
            didLaunchFromShortcuts = false
        } else {
            if let index = tableView.indexPathForSelectedRow {
                
                if segue.identifier == "showDetail" {
                    let detailVC = segue.destination as! StudentDetailViewController
                    detailVC.student = self.students[index.row]
                    selectedIndexRow = index.row
                    detailVC.delegate = self
                }
            }
        }
        

    }
    
}

// MARK: - Table View Delegate & Data Source

extension StudentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if students.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel = UILabel()
            let attributedString = NSMutableAttributedString(string: "Press  ")
            let addDescImageAttachment = NSTextAttachment()
            addDescImageAttachment.image = UIImage(named: "add-people")
            addDescImageAttachment.bounds = CGRect(x: 0, y: -5, width: 25, height: 25)
            attributedString.append(NSAttributedString(attachment: addDescImageAttachment))
            attributedString.append(NSAttributedString(string: "  To Add Your First Student!"))
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
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentCell
        let student = students[indexPath.row]
        cell.configure(with: student)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to remove \(students[indexPath.row].name)?", preferredStyle: .alert)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                let studentToDelete = self.students[indexPath.row]
                tableView.isUserInteractionEnabled = false
                self.spinner.startAnimating()
                CloudKitManager.deleteStudent(studentToDelete) { (success) in
                    if !success { setAlertWith(title: "Error", message: "Could not delete student", from: self, handler: nil); return }
                    self.students.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.spinner.stopAnimating()
                        tableView.isUserInteractionEnabled = true
                    }
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            deleteAlert.addAction(delete)
            deleteAlert.addAction(cancel)
            
            present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    
}

// MARK: - AddStudentViewControllerDelegate

extension StudentListViewController: AddStudentViewControllerDelegate {
    
    func add(studentViewController controller: AddStudentViewController, student: Student) {
        spinner.startAnimating()
        tableView.isUserInteractionEnabled = false
        let currentTeacher = ActiveUser.shared.current as! Teacher
        CloudKitManager.addStudent(student, to: currentTeacher) { (records) in
            guard let records = records else { fatalError() }
            currentTeacher.record = records.filter() { $0.recordType == "Teachers" }.first!
            let newStudentRecord = records.filter() { $0.recordType == "Students" }.first!
            guard let newStudent = Student(with: newStudentRecord) else { fatalError() }
            self.students.append(newStudent)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                self.tableView.isUserInteractionEnabled = true
            }
        }
        
    }
    
}

extension StudentListViewController: StudentDetailViewControllerDelegate {
    func studentDetailViewController(_ controller: StudentDetailViewController, didUpdate record: CKRecord?) {
        guard let record = record else { fatalError() }
        guard let selectedIndexRow = selectedIndexRow else { fatalError() }
        guard let newStudent = Student(with: record) else { fatalError() }
        students[selectedIndexRow] = newStudent
    }
}

