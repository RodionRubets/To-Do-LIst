import SwiftUI

struct NotesListView: View {
    @StateObject var notesVM = NotesViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(notesVM.notes) { note in
                    NavigationLink(destination: NoteEditorView(note: note, notesVM: notesVM)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                                .font(.headline)
                            Text(note.text.isEmpty ? "No text…" : note.text)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: notesVM.delete)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { notesVM.addNote() } label: { Image(systemName: "plus") }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }
}
#Preview {
    NotesListView()
}
