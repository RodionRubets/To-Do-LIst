import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView: View {
    
    @StateObject var vm = TodoViewModel()
    @State private var showAlert = false
    @State private var goSettings = false
    @StateObject var theme = ThemeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Top input field
                HStack {
                    TextField("Enter your text", text: $vm.newTaskText)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 0.1))
                        
                    
                    Button(action: {
                        vm.addTask()
                        hideKeyboard()
                    }) {
                        Image(systemName: "plus.app.fill")
                            .font(.title2)
                            .foregroundColor(theme.currentColor.color)
                    }
                }
                .padding()
                
                // MARK: - To-do list
                List {
                    ForEach(vm.items) { item in
                        HStack {
                            Button(action: { vm.toggleCompleted(item) }) {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(theme.currentColor.color)
                            }
                            
                            Text(item.title)
                                .strikethrough(item.isDone)
                                .foregroundColor(item.isDone ? Color(red: 0.49, green: 0.54, blue: 0.71) : .primary)
                            
                            Spacer()
                        }
                        .padding(8)
                        .cornerRadius(8)
                    }
                    .onDelete(perform: vm.deleteCompletedTasks)
                }
                .listStyle(PlainListStyle())              
                .scrollContentBackground(.hidden)
                .background(Color.white)
                
                Spacer()
                
                // MARK: - Bottom bar
                HStack {
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .font(.title2)
                    .alert("Hi", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("It's a simple app to manage your to-do list. I hope you will like it!")
                    }
                    .foregroundColor(theme.currentColor.color)
                    
                    Text("Created by: Rodion Rubets")
                        .font(.caption)
                        .foregroundColor(.black)
                        .bold()
                        .padding()
                
                    Button {
                        goSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .font(.title2)
                    .foregroundColor(theme.currentColor.color)
                    
                }
                
                NavigationLink("", destination: SettingsView(theme: theme), isActive: $goSettings)
                    .hidden()
            }
        
            .navigationTitle("To-do List")
            .onAppear {
                vm.loadItems()
            }
        }
    }
}

#Preview {
    ContentView()
}
