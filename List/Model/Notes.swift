import Foundation

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var text: String
    var updatedAt: Date = Date()
}
