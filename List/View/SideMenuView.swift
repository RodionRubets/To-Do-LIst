import SwiftUI

struct SideMenuView: View {

    // MARK: - Dependencies
    @ObservedObject var todoVM: TodoViewModel
    @ObservedObject var listsVM: TodoListsViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var accent: Color {
        AppTheme.accentColor(for: colorScheme)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }


    @Binding var showMenu: Bool
    @Binding var showSettings: Bool

    // MARK: - UI State
    @State private var showCreateListAlert = false
    @State private var newListName = ""

    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var listToRename: TodoList?

    @State private var showColorPicker = false
    @State private var listForColor: TodoList?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Header
            HStack {
                Text("To-Do")
                    .font(.title.bold())
                    .padding(.horizontal, 10)

                Spacer()
            }
            .padding(.top, 45)

            Divider()

            // MARK: - Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - LISTS
                    Text("LISTS")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(spacing: 6) {
                        ForEach(listsVM.lists) { list in
                            sideMenuRow(
                                title: list.title,
                                systemImage: list.isSystem ? "tray.full" : "folder",
                                count: list.isSystem
                                    ? todoVM.countAll()
                                    : todoVM.count(for: list.id),
                                color: list.isSystem
                                    ? .primary
                                    : Color(hex: list.colorHex),
                                isSelected: listsVM.selectedListID == list.id
                            ) {
                                listsVM.selectedListID = list.id
                                todoVM.activeFilter = .none
                                closeMenu()
                            }
                            .contextMenu {
                                if !list.isSystem {

                                    Button {
                                        listToRename = list
                                        renameText = list.title
                                        showRenameAlert = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.primary)

                                    Button {
                                        listForColor = list
                                        showColorPicker = true
                                    } label: {
                                        Label("Change color", systemImage: "paintpalette")
                                    }
                                    .tint(.primary)

                                    Button(role: .destructive) {
                                        listsVM.deleteList(list)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                            }
                        }

                        // New List
                        sideMenuRow(
                            title: "New List",
                            systemImage: "plus",
                            color: .secondary,
                            isSelected: false,
                            isSecondary: true
                        ) {
                            newListName = ""
                            showCreateListAlert = true
                        }
                    }

                    // MARK: - FILTERS
                    Text("FILTERS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    VStack(spacing: 6) {
                        sideMenuRow(
                            title: "Today",
                            systemImage: "calendar",
                            count: todoVM.countToday(),
                            color: .secondary,
                            isSelected: todoVM.activeFilter == .today
                        ) {
                            todoVM.activeFilter = .today
                            listsVM.selectedListID = TodoListsViewModel.allTasksID
                            closeMenu()
                        }

                        sideMenuRow(
                            title: "Completed",
                            systemImage: "checkmark.circle",
                            count: todoVM.countCompleted(),
                            color: .secondary,
                            isSelected: todoVM.activeFilter == .completed
                        ) {
                            todoVM.activeFilter = .completed
                            listsVM.selectedListID = TodoListsViewModel.allTasksID
                            closeMenu()
                        }
                    }
                }
                .padding(.top, 4)
            }

            Divider()

            // MARK: - Settings
            Button {
                closeMenu()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showSettings = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape")
                        .foregroundColor(accent)

                    Text("Settings")
                        .foregroundColor(textColor)
                }
            }
            .padding(.bottom, 14)
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 4, y: 0)
        .ignoresSafeArea()

        // MARK: - Color Picker
        .sheet(isPresented: $showColorPicker) {
            VStack(spacing: 16) {
                Text("List Color")
                    .font(.headline)

                HStack {
                    ForEach(
                        ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE"],
                        id: \.self
                    ) { hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 36, height: 36)
                            .onTapGesture {
                                if let list = listForColor {
                                    listsVM.setColor(hex, for: list)
                                }
                                showColorPicker = false
                            }
                    }
                }
            }
            .padding()
        }

        // MARK: - Alerts
        .alert("New List", isPresented: $showCreateListAlert) {
            TextField("List name", text: $newListName)

            Button("Create") {
                let trimmed = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
                     guard !trimmed.isEmpty else { return }
                     listsVM.addList(title: trimmed)
                     newListName = ""
                     closeMenu()            }

            Button("Cancel", role: .cancel) {
                newListName = ""
            }
        }

        .alert("Rename List", isPresented: $showRenameAlert) {
            TextField("List name", text: $renameText)

            Button("Save") {
                if let list = listToRename {
                    listsVM.renameList(list, newTitle: renameText)
                }
            }

            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Row helper
    private func sideMenuRow(
        title: String,
        systemImage: String,
        count: Int? = nil,
        color: Color,
        isSelected: Bool,
        isSecondary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundColor(isSecondary ? .secondary : color)

                Text(title)
                    .foregroundColor(.primary)
                    .font(isSecondary ? .body : .body.weight(.medium))

                if let count {
                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                        ? .primary.opacity(0.1)
                        : Color.clear
                    )
            )
        }
    }

    private func closeMenu() {
        withAnimation(.easeInOut) {
            showMenu = false
        }
    }
}

