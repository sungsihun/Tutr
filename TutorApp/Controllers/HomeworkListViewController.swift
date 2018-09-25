
//
//  HomeworkListViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class HomeworkListViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Properties
  
  var assignments = [Assignment]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let assignment = Assignment(assignmentTitle: "My title", assignmentDescription: "Desc")
    let assignment2 = Assignment(assignmentTitle: "Another", assignmentDescription: "Again")
    assignments.append(assignment2)
    assignments.append(assignment)
    
  }
  
  // MARK: - Actions
  
  @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Table View Data Source

extension HomeworkListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return assignments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "studentAssignmentCell", for: indexPath) as! StudentAssignmentCell
    
    cell.configure(assignment: assignments[indexPath.row])
    
    return cell
  }
}

// MARK: - Table View Delegate

extension HomeworkListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! StudentAssignmentCell
    cell.toggle()
    tableView.beginUpdates()
    tableView.reloadRows(at: [indexPath], with: .automatic)
    tableView.endUpdates()

  }
  
  
  
}

