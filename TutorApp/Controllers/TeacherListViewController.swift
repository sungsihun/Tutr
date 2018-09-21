//
//  TeacherListViewController.swift
//  TutorApp
//
//  Created by NICE on 2018-09-20.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class TeacherListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
  
    // MARK: - Properties
  
    var teachers = [Teacher]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupUI()
        let teacher = Teacher(name: "Steve Thompson", subject: "Swift", image: UIImage(named: "steve"))
        teachers.append(teacher)
    }
    
    // MARK: - Custom Methods
  
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
  
    // MARK: - Custom Methods
  
    private func setupTableView() {
      tableView.separatorInset = UIEdgeInsets.zero
      tableView.tableFooterView = UIView(frame: .zero)
    }
  
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        case 2436: // iPhone X
          return 175
        default: // Every other iPhone
          return 145
        }
    }
  
    // MARK: - Action

    @IBAction func filterTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Filter By:", message: nil, preferredStyle: .actionSheet)
        let nameSortAction = UIAlertAction(title: "Name", style: .default) { _ in
          self.teachers = self.teachers.sorted { $0.name.lowercased() < $1.name.lowercased() }
          self.tableView.reloadData()
        }
        let subjectSortAction = UIAlertAction(title: "Subject", style: .default) { _ in
          self.teachers = self.teachers.sorted { $0.subject.lowercased() < $1.subject.lowercased() }
          self.tableView.reloadData()
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
      tableView.deselectRow(at: indexPath, animated: true)
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      
      if editingStyle == .delete {
        teachers.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
    }
  
}
