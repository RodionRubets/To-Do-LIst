import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Problem?")) {
                    Button(action: {
                        openEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.title2)
                                .foregroundColor(Color.blue)
                            Text("You can report a problem!")
                                .foregroundColor(.black)
                                .font(.body)
                                
                        }
                    }
                    
                    
                    

                }
                
                
                
                Section(header: Text("Version")) {
                    Text("1.0.0")
                        .font(.body)
                        .bold()
                }
                
                Section(header: Text("Developer")) {
                    Text("Rodion Rubets")
                        .font(.body)
                        .bold()
                
                }
            }
            .background(Color.white)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                              HStack(spacing: 3) {
                                  Image(systemName: "gearshape.fill")
                                      .foregroundColor(.secondary)

                                  Text("Settings")
                                      .font(.headline)
                              }
                          }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button() {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.turn.up.left")
                    }
                    .font(.custom(String("🔄"), size: 22))
                    
                }
            }
        }
    }
}

func openEmail() {
    let email = "rodion.rubets@gmail.com"
    let subject = "Feedback for To-Do App"
    let body = "Hi Rodion, \n\nI want to share some"
    let emailURL = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    
    if let url = URL(string: emailURL!) {
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsView()
}
