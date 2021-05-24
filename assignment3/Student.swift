import Firebase
import FirebaseFirestoreSwift

public struct Student : Codable
{
    @DocumentID var student_id:String?
    var full_name:String
    var id:String
    var overall_mark:Int32
}
