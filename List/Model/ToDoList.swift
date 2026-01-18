import Foundation

struct TodoList: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var colorHex: String
    var isSystem: Bool = false

    init(
        id: UUID = UUID(),
        title: String,
        colorHex: String = "#007AFF",
        isSystem: Bool = false
    ) {
        self.id = id
        self.title = title
        self.colorHex = colorHex
        self.isSystem = isSystem
    }
}
