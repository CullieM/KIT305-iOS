//
//  MovieUITableViewController.swift
//  assignment3
//
//  Created by Cullie McElduff on 16/5/21.
//

import UIKit
import Firebase

class MovieUITableViewController: UITableViewController, UISearchBarDelegate{

    var students = [Student]()
    var filteredStudents: [Student]!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBAction func unwindToStudentListWithDelete(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? DetailViewController
        {
            students.remove(at: detailScreen.studentIndex!)
            filteredStudents = students
            tableView.reloadData()
        }
    }
    @IBAction func unwindToStudentListwithAdd(sender: UIStoryboardSegue)
    {
        if let addScreen = sender.source as? AddStudentViewController
        {
            self.students.append(addScreen.student!)
            filteredStudents = students
            tableView.reloadData()
        }
    }
    @IBAction func unwindToMovieList(sender: UIStoryboardSegue)
    {
        //we could reload from db, but lets just trust the local movie object
            if let detailScreen = sender.source as? DetailViewController
            {
                students[detailScreen.studentIndex!] = detailScreen.student!
                filteredStudents = students
                tableView.reloadData()
            }
    }

    @IBAction func unwindToMovieListWithCancel(sender: UIStoryboardSegue)
    {
    }
    override func viewDidLoad()
    {
            super.viewDidLoad()
        searchBar.delegate = self
        filteredStudents = students
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
            
            let db = Firestore.firestore()
            let studentsCollection = db.collection("studentsiOS")
            studentsCollection.getDocuments() { (result, err) in
                if let err = err
                {
                    print("Error getting documents: \(err)")
                }
                else
                {
                    for document in result!.documents
                    {
                        let conversionResult = Result
                        {
                            try document.data(as: Student.self)
                        }
                        switch conversionResult
                        {
                            case .success(let convertedDoc):
                                if var student = convertedDoc
                                {
                                    // A `Movie` value was successfully initialized from the DocumentSnapshot.
                                    student.student_id = document.documentID
                                    print("Student: \(student)")
                                    
                                    //NOTE THE ADDITION OF THIS LINE
                                    self.students.append(student)
                                }
                                else
                                {
                                    // A nil value was successfully initialized from the DocumentSnapshot,
                                    // or the DocumentSnapshot was nil.
                                    print("Document does not exist")
                                }
                            case .failure(let error):
                                // A `Movie` value could not be initialized from the DocumentSnapshot.
                                print("Error decoding student: \(error)")
                        }
                    }
                    
                    //NOTE THE ADDITION OF THIS LINE
                    self.filteredStudents = self.students
                    self.tableView.reloadData()
                }
            }
            
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredStudents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieUITableViewCell", for: indexPath)

        //get the movie for this row
        let student = filteredStudents[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
        //note, this could fail, so we use an if let.
        if let studentCell = cell as? MovieUITableViewCell
        {
            //populate the cell
             studentCell.titleLabel.text = student.full_name
            studentCell.subTitleLabel.text = student.id
        }

        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "ShowMovieDetailSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let detailViewController = segue.destination as? DetailViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedMovieCell = sender as? MovieUITableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedMovieCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which movie it is using the row number
              let selectedStudent = students[indexPath.row]

              //send it to the details screen
              detailViewController.student = selectedStudent
              detailViewController.studentIndex = indexPath.row
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredStudents = students
        if searchText == "" {
            filteredStudents = students
        }else{
            filteredStudents = filteredStudents.filter{
                $0.full_name.lowercased().contains(searchText.lowercased())
                }
            
            }
        print(searchText)
        self.tableView.reloadData()
        }
    //REFERENCE, TAKEN FROM: https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    }

