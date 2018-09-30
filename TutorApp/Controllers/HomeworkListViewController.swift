
//
//  HomeworkListViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit
import CloudKit


class AssignmentListViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Properties
  
  var assignments: [Assignment]?
  var selectedTeacher: Teacher?
  let refreshControl = UIRefreshControl()
  let userDefaults = UserDefaults.standard

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl.tintColor = #colorLiteral(red: 0.1067340448, green: 0.4299619794, blue: 0.02381768264, alpha: 1)
    tableView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
  }
  
  @objc private func handleRefreshControl() {
    
    guard let recordIDString = userDefaults.string(forKey: ActiveUser.recordID) else { fatalError() }
    let recordID = CKRecordID(recordName: recordIDString)
    
    CloudKitManager.getLatestStudentRecord(with: recordID) { (recordId) in
      CloudKitManager.getAssignmentsFrom(recordId, completion: { (assignmnets) in
        self.assignments = assignmnets.reversed()
        DispatchQueue.main.async {
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
        }
      })
    }
  }


  
  // MARK: - Actions
  
  @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Table View Data Source

extension AssignmentListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return assignments?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "studentAssignmentCell", for: indexPath) as! StudentAssignmentCell
    guard let assignment = assignments?[indexPath.row] else { return cell }
    cell.configureCellWith(assignment: assignment)
    
    return cell
  }
  
  
}

// MARK: - Table View Delegate

extension AssignmentListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! StudentAssignmentCell
    cell.toggle()
    tableView.reloadData()
  }
}

