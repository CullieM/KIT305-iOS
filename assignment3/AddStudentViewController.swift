//
//  AddStudentViewController.swift
//  assignment3
//
//  Created by Cullie McElduff on 22/5/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddStudentViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var picked = Bool()
    var student : Student?
    var mark : Mark?
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var idField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
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
            picked = true
            self.imageView.layer.cornerRadius = 20
            self.imageView.clipsToBounds = true
            imageView.image = image
            dismiss(animated: true, completion: nil)
            // Data in memory
            
            
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAdd(_ sender: Any) {

            let db = Firestore.firestore()
       
        if nameField.text == "" || idField.text == ""  {
            let refreshAlert = UIAlertController(title: "Name and Student ID must be entered.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            //REFERENCE, TAKEN FROM: https://stackoverflow.com/questions/25511945/swift-alert-view-with-ok-and-cancel-which-button-tapped
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [self] (action: UIAlertAction!) in
                print("Affirmative")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }else if idField.text!.count != 6 {
            let refreshAlert = UIAlertController(title: "Student ID must be 6 digits.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [self] (action: UIAlertAction!) in
                print("Affirmative")
            }))
            present(refreshAlert, animated: true, completion: nil)
        }else{
            student = Student(student_id: idField.text!, full_name: nameField.text!, id: idField.text!, overall_mark: 0)
            
            if picked == true {
                var data = Data()
                data = UIImageJPEGRepresentation(self.imageView.image!, 1.0)!
                // Create a reference to the file you want to upload
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let imageRef = storageRef.child("iOSPictures/\(idField.text!).jpg")

                let uploadTask = imageRef.putData(data, metadata: nil)
            }
            
            do
            {
                //update the database (code from lectures)
                try db.collection("studentsiOS").document((student?.student_id!)!).setData(from: student){ [self] err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        mark = Mark(student_id: student?.student_id, mark: 0, week: 0, student_name: student!.full_name)
                        for i in 1...12
                        {
                            do{
                                mark?.week = i
                            try db.collection("weeksiOS").document("Week " + String(i)).collection("student_marks").document((student?.student_id)!).setData(from: mark){ err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                            }
                                catch { print("Error updating document \(error)") }
                            }
                        }
                    self.performSegue(withIdentifier: "addSegue", sender: sender)
                        }
                    }
                catch { print("Error updating document \(error)") } //note "error" is a magic variable
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
