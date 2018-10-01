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
  @IBOutlet weak var refreshButton: UIButton!
  
  // MARK: - Properties
  
  var teachers = [Teacher]()
  let userDefaults = UserDefaults.standard
  var selectedTeacher: Teacher?
  var indexPathForSelectedRow: IndexPath!
  let refreshControl = UIRefreshControl()
  
  
  // MARK: - Life Cycle
  
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
  
  @objc private func getStudent() {
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
    guard let recordIDString = userDefaults.string(forKey: ActiveUser.recordID) else { fatalError() }
    let recordID = CKRecordID(recordName: recordIDString)
    CloudKitManager.getStudentFromRecordID(recordID) { (student) in
      ActiveUser.shared.current = student
      completion()
    }
  }
  
  
  
  // MARK: - Action
  
  @IBAction func refreshTapped(_ sender: UIButton) {
    setupSpinner()
    getStudent()
  }
  
  
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


extension TeacherListViewController: UITableViewDelegate, UITableViewDataSource {
  
  // MARK: - Table View Delegate & Data Source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if teachers.count > 0 {
      tableView.backgroundView = nil
      tableView.separatorStyle = .singleLine
      if tableView.refreshControl == nil {
        tableView.refreshControl = refreshControl
      }
    } else {
      let noDataLabel = UILabel()
      noDataLabel.text = "No Teachers!\nA teacher can find you using your email address."
      noDataLabel.font = UIFont(name: "Dosis", size: 17)
      noDataLabel.textColor = UIColor.black
      noDataLabel.textAlignment = .center
      noDataLabel.numberOfLines = 0
      tableView.backgroundView = noDataLabel
      tableView.separatorStyle = .none
      tableView.refreshControl = nil
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
    indexPathForSelectedRow = indexPath
    let selectedTeacher = teachers[indexPath.row]
    self.selectedTeacher = selectedTeacher
    let currentStudent = ActiveUser.shared.current as! Student
    guard let currentStudentRecord = currentStudent.record else { fatalError("No student record") }
    self.startSpinnerInCell()
    CloudKitManager.getUserRecord(with: currentStudentRecord.recordID) { (newStudentRecord) in
      guard let newStudentRecord = newStudentRecord else { fatalError("Could not get a new student record") }
      ActiveUser.shared.current = Student(with: newStudentRecord)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}




extension TeacherListViewController {
  
  // MARK: - UI
  
  private func setupUI() {
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationItem.title = "My Teachers"
    // set header height constraint for different devices
    if UIDevice().userInterfaceIdiom == .phone {
      headerHeightConstraint.constant = getHeaderImageHeightForCurrentDevice()
    }
    tableView.tableFooterView = UIView()
    tableView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
  }
  
  // MARK: - Spinner
  
  private func setupSpinner() {
    self.spinner.startAnimating()
    self.spinner.hidesWhenStopped = true
    self.tableView.isHidden = true
    refreshButton.isHidden = true
  }
  
  @objc private func didRefresh() {
    selectedTeacher = nil
    getStudent()
  }
  
  private func stopSpinner() {
    DispatchQueue.main.async {
      if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
      self.tableView.reloadData()
      self.tableView.isHidden = false
      self.spinner.stopAnimating()
      
      if self.teachers.count == 0 {
        self.refreshButton.isHidden = false
      } else {
        self.refreshButton.isHidden = true
      }
    }
  }
  
  private func startSpinnerInCell() {
    let selectedCell = tableView.cellForRow(at: indexPathForSelectedRow) as! TeacherCell
    selectedCell.spinner.startAnimating()
    selectedCell.spinner.isHidden = false
  }
  
  private func stopSpinnerInCell() {
    guard let selectedCell = self.tableView.cellForRow(at: self.indexPathForSelectedRow) as? TeacherCell else { return }
    selectedCell.spinner.stopAnimating()
    selectedCell.spinner.isHidden = true
  }
  
  // MARK: - Other
  
  private func setupTableView(filterBy: String) {
    tableView.separatorInset = UIEdgeInsets.zero
    tableView.tableFooterView = UIView(frame: .zero)
    if filterBy == "Name" {
      teachers = teachers.sorted { $0.name.lowercased() < $1.name.lowercased() }
    } else {
      teachers = teachers.sorted { $0.subject.lowercased() < $1.subject.lowercased() }
    }
    self.userDefaults.set(filterBy, forKey: "filterBy")
    self.tableView.reloadData()
  }
  
  private func getHeaderImageHeightForCurrentDevice() -> CGFloat {
    switch UIScreen.main.nativeBounds.height {
    case 2436: // iPhone X
      return 175
    case 2688: // iPhone Xs Max
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
      self.stopSpinnerInCell()
      self.performSegue(withIdentifier: "showAssignments", sender: self)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showAssignments" {
      let nav = segue.destination as! UINavigationController
      let assignmentsVC = nav.viewControllers.first! as! AssignmentListViewController
      guard let selectedTeacher = self.selectedTeacher, let teacherRecord = selectedTeacher.record else{ fatalError("Somehow no teacher selected") }
      let currentStudent = ActiveUser.shared.current as! Student
      currentStudent.filterAssignments(by: selectedTeacher)
      assignmentsVC.assignments = currentStudent.teacherAssignmentsDict[teacherRecord.recordID.recordName]
      assignmentsVC.selectedTeacher = selectedTeacher
    }
  }
}




