import Firebase
import FirebaseFirestoreSwift

public struct Week : Codable
{
    @DocumentID var id:String?
    var name:String
    var marking_schema:String
    var overall_mark:Int32
}
