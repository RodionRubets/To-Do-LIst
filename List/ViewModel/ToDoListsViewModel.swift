import Foundation
import SwiftUI

final class TodoListsViewModel: ObservableObject {

    // MARK: - System list IDs
    static let allTasksID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let todayID    = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let doneID     = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

    // MARK: - Published
    @Published var lists: [TodoList] = []
    @Published var selectedListID: UUID = allTasksID

    private let key = "todo_lists"

    // MARK: - Init
    init() {
        load()
        createDefaultsIfNeeded()
    }

    // MARK: - Defaults
    private func createDefaultsIfNeeded() {
        guard lists.isEmpty else { return }

        lists = [
            TodoList(id: Self.allTasksID, title: "All Tasks", isSystem: true),
            TodoList(title: "Personal"),
            TodoList(title: "Work")
        ]
        save()
    }

    // MARK: - CRUD
    func addList(title: String) {
        let list = TodoList(title: title)
        lists.append(list)
        save()
    }

    func deleteList(_ list: TodoList) {
        guard !list.isSystem else { return }

        lists.removeAll { $0.id == list.id }

        if selectedListID == list.id {
            selectedListID = Self.allTasksID
        }

        save()
    }

    // MARK: - Persistence
    private func save() {
        guard let data = try? JSONEncoder().encode(lists) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([TodoList].self, from: data)
        else { return }

        lists = decoded
    }
    
    func renameList(_ list: TodoList, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let index = lists.firstIndex(of: list) else { return }
        lists[index].title = trimmed
        save()
    }
    
    func setColor(_ hex: String, for list: TodoList) {
        guard let index = lists.firstIndex(of: list) else { return }
        lists[index].colorHex = hex
        save()
    }
}
