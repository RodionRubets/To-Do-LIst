import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}



struct ContentView: View {
    
    // MARK: - ViewModels
    @StateObject var vm: TodoViewModel
    @Binding var isSelectionMode: Bool
    @State private var selectedIDs: Set<UUID> = []
    @State private var showDeleteConfirmation = false
    @State private var draggedItem: TodoItem? = nil
    @FocusState private var isInputFocused: Bool
    @StateObject private var listsVM = TodoListsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    

    
    // MARK: - UI State
    @State private var showSettings = false
    @Binding var showMenu: Bool
    @State private var showNotes = false
    
    @State private var editingItem: TodoItem? = nil
    @State private var editingText: String = ""
    
    
    private var accent: Color {
        AppTheme.accentColor(for: colorScheme)
    }
    
    private var fieldBackground: Color {
        colorScheme == .dark ? .white : .black
    }

    private var fieldTextColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var fieldBorder: Color {
        colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4)
    }

    
    var body: some View {
        
        
        ZStack(alignment: .leading) {
            
            NavigationView {
                mainContent
                    .navigationTitle(navigationTitle())
                    .toolbar {
                        
                        // ☰ Menu
                        ToolbarItem(placement: .topBarLeading) {
                            Button() {
                                withAnimation { showMenu.toggle() }
                                hideKeyboard()
                                isSelectionMode = false
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(accent)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(isSelectionMode ? "Done" : "Edit") {
                                withAnimation {
                                    isSelectionMode.toggle()
                                    selectedIDs.removeAll()
                                    hideKeyboard()
                                }
                            }
                            .padding(4)
                            .foregroundColor(accent)
                        }

                        ToolbarItem(placement: .bottomBar) {
                            if isSelectionMode && !selectedIDs.isEmpty {
                                Button {
                                    showDeleteConfirmation = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 9)
                                        .background(
                                            Capsule()
                                                .fill(Color.red)
                                        )
                                }
                            }
                        }
                        

                    }
            }
            
            // Overlay
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showMenu = false }
                    }
            }
            
            // Side menu
            SideMenuView(
                todoVM: vm,
                listsVM: listsVM,
                showMenu: $showMenu,
                showSettings: $showSettings
            )
            .frame(width: UIScreen.main.bounds.width * 0.55)
            .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width)
        }
        .sheet(isPresented: $showNotes) {
            NotesListView()
        }
        .fullScreenCover(isPresented: $showSettings, content: {
            NavigationStack {
                SettingsView()
            }
        })
        .onAppear {
            vm.loadItems()
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack {
            
            HStack {
                TextField("Enter your text", text: $vm.newTaskText)
                    .padding(14)
                    .focused($isInputFocused)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(fieldBorder)
                    )
                    .submitLabel(.done)
                    .onSubmit {
                        vm.addTask(to: listsVM.selectedListID)
                        hideKeyboard()
                    }
                    .onChange(of: vm.newTaskText) { newValue in
                        let trimmed = newValue.drop(while: { $0 == " "})
                        
                        if newValue != trimmed {
                            vm.newTaskText = String(trimmed)
                        }
                    }
                
                if #available(iOS 26.0, *) {
                    Button {
                        let trimmed = vm.newTaskText.trimmingCharacters(in: .whitespaces)
                        
                        if trimmed.isEmpty {
                            isInputFocused = true
                        } else {
                            vm.addTask(to: listsVM.selectedListID)
                            hideKeyboard()
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(accent)
                        
                    }
                    .buttonStyle(.glass)
                    .padding(.leading)
                } else {
                    // Fallback on earlier versions
                }
            }
            
            .padding()
            
            // MARK: Empty state
            if vm.items.isEmpty {
                VStack {
                    Text("No tasks yet")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.tasks(for: listsVM.selectedListID)) { item in
                            TodoRowView(
                                item: item,
                                //accentColor: theme.currentColor.color,
                                isSelectionMode: isSelectionMode,
                                isSelected: selectedIDs.contains(item.id),
                                onToggleSelect: {
                                    toggleSelection(item.id)
                                },
                                onToggle: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        vm.toggleCompleted(item)
                                    }
                                },
                                onEdit: {
                                    editingItem = item
                                    editingText = item.title
                                },
                                onCopy: {
                                    UIPasteboard.general.string = item.title
                                },
                                onDelete: {
                                    if let index = vm.items.firstIndex(where: { $0.id == item.id }) {
                                        vm.items.remove(at: index)
                                    }
                                },
                                onDragStart: {
                                    draggedItem = item
                                    return NSItemProvider(object: item.id.uuidString as NSString)
                                },
                                onDrop: { currentItem in
                                    TodoDropDelegate(
                                        item: currentItem,
                                        items: $vm.items,
                                        draggedItem: $draggedItem
                                    )
                                }
                            )
                            .onDrop(
                                of: [.text],
                                delegate: TodoDropDelegate(
                                    item: item,
                                    items: $vm.items,
                                    draggedItem: $draggedItem
                                )
                            )
                            
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    
                }
                .scrollDismissesKeyboard(.interactively)
            } 
        }
        .alert(
            "Delete notes?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                vm.items.removeAll { selectedIDs.contains($0.id) }
                selectedIDs.removeAll()
                isSelectionMode = false
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        
        .alert("Edit Note", isPresented: Binding(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField("Title", text: $editingText)
            Button("Save") {
                if let item = editingItem {
                    vm.edit(itemID: item.id, newTitle: editingText)
                }
                editingItem = nil
            }
            Button("Cancel", role: .cancel) {
                editingItem = nil
            }
        }
        
        
    }
    
    private func toggleSelection(_ id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
    
    private func navigationTitle() -> String {

        switch vm.activeFilter {
        case .today:
            return "Today"
        case .completed:
            return "Completed"
        case .none:
            break
        }

        if let list = listsVM.lists.first(
            where: { $0.id == listsVM.selectedListID }
        ) {
            return list.title
        }

        return "To-Do"
    }
    
    
}


