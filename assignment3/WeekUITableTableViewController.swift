//
//  MovieUITableViewController.swift
//  assignment3
//
//  Created by Cullie McElduff on 16/5/21.
//

import UIKit
import Firebase

class WeekUITableViewController: UITableViewController {

    var weeks = [Week]()
 
    override func viewDidLoad()
    {
            super.viewDidLoad()
            let db = Firestore.firestore()
            let weeksCollection = db.collection("weeksiOS")
            weeksCollection.getDocuments() { (result, err) in
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
                            try document.data(as: Week.self)
                        }
                        switch conversionResult
                        {
                            case .success(let convertedDoc):
                                if var week = convertedDoc
                                {
                                    // A `Movie` value was successfully initialized from the DocumentSnapshot.
                                    week.id = document.documentID
                                    print("Week: \(week)")
                                    
                                    //NOTE THE ADDITION OF THIS LINE
                                    self.weeks.append(week)
                                }
                                else
                                {
                                    // A nil value was successfully initialized from the DocumentSnapshot,
                                    // or the DocumentSnapshot was nil.
                                    print("Document does not exist")
                                }
                            case .failure(let error):
                                // A `Movie` value could not be initialized from the DocumentSnapshot.
                                print("Error decoding week: \(error)")
                        }
                    }
                    //REFERENCE, TAKEN FROM: https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value
                    self.weeks = self.weeks.sorted(by: { $0.name < $1.name })
                    
                    //NOTE THE ADDITION OF THIS LINE
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
        return weeks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieUITableViewCell", for: indexPath)

        //get the movie for this row
        let week = weeks[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
        //note, this could fail, so we use an if let.
        if let weekCell = cell as? MovieUITableViewCell
        {
            //populate the cell
            weekCell.titleLabel.text = week.id
            weekCell.subTitleLabel.text = week.marking_schema
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "showWeekSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let weekMarksTableViewController = segue.destination as? WeekMarksTableViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedWeekCell = sender as? MovieUITableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the umber of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedWeekCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which movie it is using the row number
              let selectedWeek = weeks[indexPath.row]

              //send it to the details screen
              weekMarksTableViewController.week = selectedWeek
              weekMarksTableViewController.weekIndex = indexPath.row
        }
    }

}
