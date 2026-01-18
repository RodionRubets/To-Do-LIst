import SwiftUI

struct TodoRowView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    let item: TodoItem
    
    let isSelectionMode: Bool
    let isSelected: Bool


    // Callbacks — НІЯКОЇ логіки тут
    let onToggleSelect: () -> Void
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    let onDragStart: () -> NSItemProvider
    let onDrop: (TodoItem) -> TodoDropDelegate
    
    
    private var accent: Color {
        AppTheme.accentColor(for: colorScheme)
    }

    var body: some View {
        HStack {
            

            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.red : .secondary)
                    .onTapGesture {
                        onToggleSelect()
                    }
                Text(" ")
            }
            
            Button {
                if !isSelectionMode {
                    onToggle()
                }
            } label: {
                if !isSelectionMode {
                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(accent)
                        .font(.system(size: 18))
                } else { EmptyView() }
            }
            .disabled(isSelectionMode)

            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundColor(item.isDone ? .secondary : .primary)
                .font(.custom("Arial", size: 18))
            
            
            Spacer().frame(minWidth: 0, maxWidth: .infinity, alignment: .init(horizontal: .trailing, vertical: .center))
            if isSelectionMode {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primary.opacity(0.06))

                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                        .background(.clear)
                }
                
                .frame(width: 40, height: 35)
                .contentShape(Rectangle())      
                .onDrag {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    return onDragStart()
                }
            }

            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.primary.opacity(0.06) : .clear)
        )
        .contentShape(Rectangle())
        .onDrop(
            of: [.text],
            delegate: onDrop(item))
        .onTapGesture {
            if isSelectionMode {
                onToggleSelect()
            }
        }
        .contextMenu {
            if !isSelectionMode {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.primary)
                
                Button {
                    onCopy()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .tint(.primary)
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
    }
}
