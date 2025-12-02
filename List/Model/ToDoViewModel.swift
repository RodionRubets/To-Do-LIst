import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    @Published var newTaskText: String = "" {
        didSet {
            loadItems()
        }
    }
    
    func addTask() {
        guard !newTaskText.isEmpty else { return }
        let task = TodoItem(title: newTaskText)
        items.append(task)
        newTaskText = ""
    }
    
    func toggleCompleted(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isDone.toggle()
        }
    }
    
    func deleteCompletedTasks(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
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
    
}
