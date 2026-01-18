import SwiftUI

struct NoteEditorView: View {
    @State var note: Note
    @ObservedObject var notesVM: NotesViewModel

    var body: some View {
        VStack(spacing: 12) {
            TextField("Title", text: $note.title)
                .font(.title3)
                .padding(.horizontal)

            Divider()

            TextEditor(text: $note.text)
                .padding(.horizontal)
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            note.updatedAt = .now
            notesVM.update(note: note)
        }
    }
}

#Preview {
        NoteEditorView(note: .init(id: UUID(), title: "Test", text: "Test"), notesVM: .init())
}
