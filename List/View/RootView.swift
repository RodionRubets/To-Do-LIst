import SwiftUI

struct RootView: View {

    @StateObject private var todoVM = TodoViewModel()
    @StateObject private var listsVM = TodoListsViewModel()

    @State private var isTodoSelectionMode = false
    @State private var isShowSideMenu = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var accent: Color {
        AppTheme.accentColor(for: colorScheme)
    }


    enum Tab {
        case todo
        case notes
    }

    var body: some View {
        ZStack {
            TabView {
                
                NavigationStack {
                    ContentView(
                        vm: todoVM,
                        isSelectionMode: $isTodoSelectionMode,
                        showMenu: $isShowSideMenu
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
                
                .tabItem {
                    Label("To-Do", systemImage: "checklist")
                }
                .toolbar(isTodoSelectionMode || isShowSideMenu ? .hidden : .visible, for: .tabBar)
                .animation(.spring(response: 0.35, dampingFraction: 0.85),
                           value: isTodoSelectionMode)
                
                
                
                .tag(Tab.todo)
                
                NavigationStack {
                    NotesListView()
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(Tab.notes)
            }
            .tint(accent)
            .onAppear {
                todoVM.loadItems()
                
                todoVM.migrateTasksIfNeeded(
                    allTasksID: TodoListsViewModel.allTasksID
                )
            }
            
            
        }
        
    }
    
}

#Preview {
    RootView()
}
