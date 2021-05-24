//
//  WeekMarksTableViewController.swift
//  assignment3
//
//  Created by Cullie McElduff on 22/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class WeekMarksTableViewController: UITableViewController {
    var marks = [Mark]()
    
    
    var week : Week?
    var weekIndex : Int?
    
    @IBOutlet var schemaLabel: UILabel!
    @IBOutlet var overallLabel: UILabel!
    @IBAction func shareButtonPressed(_ sender: Any) {
        var sharedText = String((week?.id)!) + "\nMarking Schema: "
        sharedText += week!.marking_schema + "\nAverage Score: "
        sharedText += String(week!.overall_mark) + "%\n"
        
        for i in 0...(marks.count-1){
            sharedText += marks[i].student_name + ": " + String(marks[i].mark) + "%\n"
        }
        let shareViewController = UIActivityViewController(activityItems: [sharedText], applicationActivities: [])
        
        present(shareViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.navigationItem.title = week?.id
        schemaLabel.text = "Marking Schema: " + week!.marking_schema
        
        overallLabel.text = "Class Average: " + String(week!.overall_mark) + "%"
        
        let db = Firestore.firestore()
        let marksCollection = db.collection("weeksiOS").document((week?.id)!).collection("student_marks")
        marksCollection.getDocuments() { [self] (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                var averageMark: Double = 0
                
                for document in result!.documents
                {
                    let conversionResult = Result
                    {
                        try document.data(as: Mark.self)
                    }
                    switch conversionResult
                    {
                        case .success(let convertedDoc):
                            if var mark = convertedDoc
                            {
                                // A `Movie` value was successfully initialized from the DocumentSnapshot.
                                mark.student_id = document.documentID
                                print("Mark: \(mark)")
                                
                                //NOTE THE ADDITION OF THIS LINE
                                averageMark += Double(mark.mark)
                                self.marks.append(mark)
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
                averageMark = averageMark / Double(marks.count)
                self.overallLabel.text = "Class Average: " + String(Int(averageMark)) + "%"
                self.week?.overall_mark = Int32(averageMark)
                
                //NOTE THE ADDITION OF THIS LINE
                self.tableView.reloadData()
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return marks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieUITableViewCell", for: indexPath)

            //get the movie for this row
            let mark = marks[indexPath.row]

            //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
            //note, this could fail, so we use an if let.
            if let markCell = cell as? MovieUITableViewCell
            {
                //populate the cell
                markCell.nameLabel.text = mark.student_name
                markCell.markLabel.text = String(mark.mark) + "%"
            }
            return cell
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Editing mark for: \n" + marks[indexPath.row].student_name, message: "Mark must be an integer from 0-100" , preferredStyle: UIAlertControllerStyle.alert)

        alert.addTextField(configurationHandler: configurationTextField)
        alert.textFields![0].placeholder = String(marks[indexPath.row].mark)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler:{ [self] (UIAlertAction) in
            print("User click Ok button")
            
            var markTemp = alert.textFields![0].text ?? ""
            markTemp = markTemp.replacingOccurrences(of: "%", with: "")
            print(markTemp)
            
            
            if let markInt = Int(markTemp) {
                if markInt > 0 && markInt < 101 {
                    let db = Firestore.firestore()
                    
                    let marksCollection = db.collection("weeksiOS").document((week?.id)!).collection("student_marks").document(marks[indexPath.row].student_id!)
                    marks[indexPath.row].mark = markInt
                    do {
                    try marksCollection.setData(from: marks[indexPath.row]) { [self] err in
                        if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                                tableView.reloadData()
                                
                                var averageMark: Double = 0
                                for index in 0...(marks.count-1) { averageMark += Double(marks[index].mark) }
                                averageMark = averageMark / Double(marks.count)
                                overallLabel.text = "Class Average: " + String(Int(averageMark)) + "%"
                                
                                week?.overall_mark = Int32(averageMark)
                                
                                let marksCollection = db.collection("weeksiOS").document((week?.id)!)
                                do {
                                    try marksCollection.setData(from: week) {_ in
                                    }
                                }
                                catch { print("Error updating document \(error)") }
                            }
                        }
                    }  catch { print("Error updating document \(error)") }
                }
            }
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
            
        })
    }
    func configurationTextField(textField: UITextField!){
        textField.text = ""
        textField.keyboardType = UIKeyboardType.numberPad
    }
}

