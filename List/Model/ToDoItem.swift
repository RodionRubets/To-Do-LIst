import Foundation

struct TodoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
    var previousUndoneIndex: Int? = nil
    let listID: UUID
    let createdAt: Date 
}
