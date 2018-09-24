
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

    var student: Student!
  
    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
    // MARK: - Actions
  
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
}

// MARK: - Table Veiw Data Source 

extension HomeworkListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.assignments.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! AssignmentCell
        cell.assignmentDescLabel.text = student.assignments[indexPath.row].assignmentDescription
      
        return cell
    }
}

// MARK: - Table View Delegate

extension HomeworkListViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
          student.assignments.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

