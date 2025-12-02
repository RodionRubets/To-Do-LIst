import Foundation

struct TodoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}
