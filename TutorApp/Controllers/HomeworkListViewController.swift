
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
      
      
      
        let assignment1 = Assignment(assignmentTitle: "title1", assignmentDescription: "dofjdif fjkdsajk frfrij fadsfad fdafds frwqfw dsafdsa ewrewrew adsfads")
        let assignment2 = Assignment(assignmentTitle: "title2", assignmentDescription: "dfjk ffr aaaa fff eee ddd  eee  fadsf  fdsjkfkf  e few f ewfw afd  sadf a")
        let assignment3 = Assignment(assignmentTitle: "title3", assignmentDescription: "dfjk ffr aaaa fff eee ddd  eee  fadsf  fdsjkfkf  e few f ewfw afd  sadf a")
        let assignment4 = Assignment(assignmentTitle: "title4", assignmentDescription: "dfjk ffr aaaa fff eee ddd  eee  fadsf  fdsjkfkf  e few f ewfw afd  sadf afjdksajklfjdklsajfkldsjkfldjsklfjdaklfjdklsafjkldsjfkldjfkldajfkldajklfdjaklfjaklfjklafjakldjaslk")
      
        assignments.append(assignment1)
        assignments.append(assignment2)
        assignments.append(assignment3)
        assignments.append(assignment4)

    }
  
    // MARK: - Actions
  
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
}

// MARK: - Table Veiw Data Source 

extension HomeworkListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentCell", for: indexPath) as! StudentAssignmentCell
      
        cell.configure(assignment: assignments[indexPath.row])
      
        return cell
    }
}

// MARK: - Table View Delegate

extension HomeworkListViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
        if editingStyle == .delete {
          assignments.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = assignments[indexPath.row]
        assignment.expanded = !assignment.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

