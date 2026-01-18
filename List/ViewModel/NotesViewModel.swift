import Foundation

final class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet { save() }
    }

    private let key = "notes_storage_v1"

    init() {
        load()
        if notes.isEmpty {
            notes = [Note(title: "Welcome", text: "Write your first note ✍️")]
        }
    }

    func addNote() {
        notes.insert(Note(title: "New note", text: ""), at: 0)
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }

    func update(note: Note) {
        guard let idx = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[idx] = note
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: key)
        } catch { }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            notes = []
        }
    }
}
