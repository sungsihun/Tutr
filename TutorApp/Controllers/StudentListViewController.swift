//
//  StudentListViewController.swift
//  TutorApp
//
//  Created by Henry Cooper on 18/09/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  
    // MARK: - Properties
  
    var students = [Student]()
    let filterDefaults = UserDefaults.standard

    // MARK: - Life Cycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupUI()
        let student1 = Student(name: "aHenry Cooper", age: 25, subjectStudying: "zSwift", image: #imageLiteral(resourceName: "henry"))
        let student2 = Student(name: "bHenry Cooper", age: 25, subjectStudying: "ySwift", image: #imageLiteral(resourceName: "henry"))
        let student3 = Student(name: "cHenry Cooper", age: 25, subjectStudying: "xSwift", image: #imageLiteral(resourceName: "henry"))
        students.append(student1)
        students.append(student2)
        students.append(student3)
        guard let filterDefaults = self.filterDefaults.string(forKey: "filterBy") else { return }
        setupTableView(filterBy: filterDefaults)
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
  
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
        case 2436: // iPhone X
            return 175
        default: // Every other iPhone
            return 145
        }
    }
  
    private func setupTableView(filterBy: String) {
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView(frame: .zero)
      
        if filterBy == "Name" {
            self.students = self.students.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            self.students = self.students.sorted { $0.subjectStudying.lowercased() < $1.subjectStudying.lowercased() }
        }
      
        self.filterDefaults.set(filterBy, forKey: "filterBy")
        self.tableView.reloadData()
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
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStudent" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.viewControllers.first! as! AddStudentViewController
            controller.delegate = self
        }
      
        if let index: IndexPath = tableView.indexPathForSelectedRow {
            if segue.identifier == "showDetail" {
                let detailVC = segue.destination as! StudentDetailViewController
                detailVC.student = self.students[index.row]
            }
        }
    }

}

// MARK: - Table View Delegate & Data Source

extension StudentListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if students.count > 0 {
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Press + To Add Your First Student!"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
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
            students.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
  
  
}

// MARK: - AddStudentViewControllerDelegate

extension StudentListViewController: AddStudentViewControllerDelegate {
    
    func add(studentViewController controller: AddStudentViewController, student: Student) {
        students.append(student)
        tableView.reloadData()
    }
    
}

