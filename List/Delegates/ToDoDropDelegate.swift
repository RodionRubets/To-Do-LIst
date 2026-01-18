import SwiftUI
import UniformTypeIdentifiers

struct TodoDropDelegate: DropDelegate {

    let item: TodoItem
    @Binding var items: [TodoItem]
    @Binding var draggedItem: TodoItem?

    func dropEntered(info: DropInfo) {
        guard
            let draggedItem,
            draggedItem.id != item.id,
            let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
            let toIndex = items.firstIndex(where: { $0.id == item.id })
        else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            items.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
