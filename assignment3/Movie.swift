import Firebase
import FirebaseFirestoreSwift

public struct Movie : Codable
{
    @DocumentID var id:String?
    var title:String
    var year:Int32
    var duration:Float
}
