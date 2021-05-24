//
//  DetailViewController.swift
//  assignment3
//
//  Created by Cullie McElduff on 16/5/21.
//

import UIKit
import Firebase

class DetailViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    

    @IBOutlet var marksLabel: UILabel!
    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var yearLabel: UITextField!
    @IBOutlet var durationLabel: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var overallLabel: UILabel!
    var marks = [Mark]()
    var marksString = String()
    var picked = Bool()

    
    //MARK: btnSharePressed
    @IBAction func btnSharePressed(_ sender: Any) {
        var sharedText = (student?.full_name)!
        sharedText +=  "\nAverage Score: " + String(student!.overall_mark) + "%\n"
        sharedText += marksString
        
        let shareViewController = UIActivityViewController(activityItems: [sharedText], applicationActivities: [])
        
        present(shareViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onPictureButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
    {
            print("Camera available")
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("No camera available")
        }
    }
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    {
        self.imageView.layer.cornerRadius = 20
        self.imageView.clipsToBounds = true
        imageView.image = image
        picked = true
        dismiss(animated: true, completion: nil)
    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
}
    @IBAction func onSave(_ sender: Any) {
        

        if titleLabel.text == "" || yearLabel.text == ""  {
            let refreshAlert = UIAlertController(title: "Name and Student ID must be entered.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            //REFERENCE, TAKEN FROM: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [self] (action: UIAlertAction!) in
                print("Affirmative")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }else if yearLabel.text!.count != 6 {
            let refreshAlert = UIAlertController(title: "Student ID must be 6 digits.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [self] (action: UIAlertAction!) in
                print("Affirmative")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }else{
            var data = Data()
            data = UIImageJPEGRepresentation(self.imageView.image!, 1.0)!
            
            // Create a reference to the file you want to upload
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let imageRef = storageRef.child("iOSPictures/" + (student?.student_id ?? "000000") + ".jpg")

            // Upload the file
            if picked == true {let uploadTask = imageRef.putData(data, metadata: nil)}
            
        let db = Firestore.firestore()
            student!.full_name = titleLabel.text!
            student!.id = yearLabel.text! //good code would check this is an int
            (sender as! UIBarButtonItem).title = "Loading..."
            do
            {
                //update the database (code from lectures)
                try db.collection("studentsiOS").document(student!.student_id!).setData(from: student!){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        //this code triggers the unwind segue manually
                        self.performSegue(withIdentifier: "saveSegue", sender: sender)
                    }
                }
            } catch { print("Error updating document \(error)") } //note "error" is a magic variable
        }
    }
    //MARK: onDelete
    @IBAction func onDelete(_ sender: Any) {
        let db = Firestore.firestore()
        let refreshAlert = UIAlertController(title: "Delete " + (student!.full_name) + "?", message: "This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        //REFERENCE, TAKEN FROM: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
            print("Affirmative")
            
            db.collection("studentsiOS").document(student!.student_id!).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
                for i in 1...12{
                    db.collection("weeksiOS").document("Week " + String(i)).collection("student_marks").document((student?.student_id)!).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
                
                //TODO REMOVE ALL WEEK MARKS
                
                self.performSegue(withIdentifier: "deleteSegue", sender: sender)
            }
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Negative")
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    var student : Student?
    var studentIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false 
        view.addGestureRecognizer(tap)
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("iOSPictures/" + (student?.student_id ?? "000000") + ".jpg")
        
        imageRef.getData(maxSize: 1 * 4096 * 4096) { data, error in
            if let error = error {
              // Uh-oh, an error occurred!
            } else {
              // Data for "images/island.jpg" is returned
              let imageDownload = UIImage(data: data!)
                self.imageView.image = imageDownload
                self.imageView.layer.cornerRadius = 20
                self.imageView.clipsToBounds = true
            }
          }
        
        //MARK: Get marks
        let db = Firestore.firestore()
        for index in 1...12 {
            let marksCollection = db.collection("weeksiOS").document("Week "+String(index)).collection("student_marks").document(String((student?.student_id)!))
        marksCollection.getDocument { (document, error) in
        if let document = document, document.exists {
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
                    print("Error decoding week: \(error)")
            }
        } else {
            print("Document does not exist")
        }
            self.marks = self.marks.sorted(by: { $0.week < $1.week })
            self.marksString = ""
            for i in 0...(self.marks.count-1){
                self.marksString += "Week " + String(self.marks[i].week) + ": " + String(self.marks[i].mark) + "%\n"
                     }
            self.marksLabel.text = self.marksString
            var averageMark: Double = 0
            for index in 0...(self.marks.count-1) { averageMark += Double(self.marks[index].mark) }
            averageMark = averageMark / Double(self.marks.count)
            self.overallLabel.text = String(Int(averageMark)) + "%"
            self.student?.overall_mark = Int32(averageMark)
             }
            
            
 
        }
         
        //MARK: Change labels
        // Do any additional setup after loading the view.
        if let displayStudent = student
            {
             self.navigationItem.title = displayStudent.full_name //this awesome line sets the page title
                titleLabel.text = displayStudent.full_name
                yearLabel.text = displayStudent.id
            overallLabel.text = String(displayStudent.overall_mark) + "%"
            }
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
