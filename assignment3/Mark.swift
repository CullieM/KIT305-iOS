//
//  Mark.swift
//  assignment3
//
//  Created by Cullie McElduff on 22/5/21.
//
import Firebase
import FirebaseFirestoreSwift

public struct Mark : Codable
{
    @DocumentID var student_id:String?
    var mark:Int
    var week:Int
    var student_name:String
}
