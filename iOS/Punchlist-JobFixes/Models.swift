import Foundation

struct PunchItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var location: String = ""
    var status: String = ""
    var notes: String = ""
    var dateAdded: Date = Date()
}
