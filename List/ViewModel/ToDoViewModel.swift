import SwiftUI

enum TaskFilter {
    case none
    case today
    case completed
}

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    @Published var activeFilter: TaskFilter = .none
    
    @Published var newTaskText: String = ""
    private let migrationKey = "tasks_migrated_to_lists"
    
    func addTask(to listID: UUID) {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let task = TodoItem(
            title: trimmed,
            listID: listID,
            createdAt: Date()
        )

        items.insert(task, at: 0)
        newTaskText = ""
    }
    
    
    func tasks(
        for listID: UUID,
        calendar: Calendar = .current
    ) -> [TodoItem] {

        var result = items

        if listID != TodoListsViewModel.allTasksID {
            result = result.filter { $0.listID == listID }
        }

        switch activeFilter {
        case .today:
            result = result.filter {
                calendar.isDateInToday($0.createdAt)
            }

        case .completed:
            result = result.filter { $0.isDone }

        case .none:
            break
        }

        return result
    }
    
    func toggleCompleted(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        let wasDone = items[index].isDone

        if !wasDone {
            let undoneIndexBefore = items[..<index].filter { !$0.isDone }.count
            items[index].previousUndoneIndex = undoneIndexBefore
        }

        items[index].isDone.toggle()

        var updated = items.remove(at: index)

        if updated.isDone {
            items.append(updated)
        } else {
            let firstDoneIndex = items.firstIndex(where: { $0.isDone }) ?? items.count
            let undoneCount = firstDoneIndex
            let targetUndoneIndex = min(updated.previousUndoneIndex ?? undoneCount, undoneCount)

            var insertionIndex = 0
            var count = 0
            while insertionIndex < items.count && count < targetUndoneIndex {
                if !items[insertionIndex].isDone {
                    count += 1
                }
                insertionIndex += 1
            }

            updated.previousUndoneIndex = nil
            items.insert(updated, at: insertionIndex)
        }
    }
    
    func deleteCompletedTasks(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
        
    func edit(itemID: UUID, newTitle: String) {
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let index = items.firstIndex(where: {$0.id == itemID}) else { return }
        items[index].title = newTitle
    }
    
    // MARK: - Counters

    func countAll() -> Int {
        items.count
    }

    func count(for listID: UUID) -> Int {
        items.filter { $0.listID == listID }.count
    }

    func countToday(calendar: Calendar = .current) -> Int {
        items.filter {
            calendar.isDateInToday($0.createdAt)
        }.count
    }

    func countCompleted() -> Int {
        items.filter { $0.isDone }.count
    }
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "ToDoItem")
        }
    }
    
    public func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "ToDoItem"),
           let savedItems = try? JSONDecoder().decode([TodoItem].self, from: data) {
            DispatchQueue.main.async {
                self.items = savedItems
            }
        }
    }
    
    func migrateTasksIfNeeded(allTasksID: UUID) {
        let alreadyMigrated = UserDefaults.standard.bool(
            forKey: migrationKey
        )

        guard !alreadyMigrated else { return }

        var didMigrate = false

        for index in items.indices {
            if items[index].listID != allTasksID {
                items[index] = TodoItem(
                    id: items[index].id,
                    title: items[index].title,
                    isDone: items[index].isDone,
                    previousUndoneIndex: items[index].previousUndoneIndex,
                    listID: allTasksID,
                    createdAt: Date()
                )
                didMigrate = true
            }
        }

        if didMigrate {
            UserDefaults.standard.set(true, forKey: migrationKey)
        }
    }
    
}
