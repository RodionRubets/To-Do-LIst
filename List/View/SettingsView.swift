import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var theme: ThemeViewModel
    
    var body: some View {
        VStack {
            
            Form {
                Section(header: Text("Interface Color")) {
                    HStack {
                        ForEach(AppColor.allCases) { color in
                            Circle()
                                .fill(color.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(
                                            theme.currentColor == color ? 1 : 0
                                        ), lineWidth: 3)
                                )
                                .onTapGesture {
                                    theme.setColor(color)
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Problem?")) {
                    Button(action: {
                        openEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .font(.title2)
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
            }
            .background(Color.white)
            .scrollContentBackground(.hidden)
            
//            Rectangle()
//                .fill(Color.black.opacity(0.15))
//                .frame(height: 1)
//            
//            Text("Version: 1.0.0")
//                .font(.caption)
//                .bold()
//                .padding(.top, 18)
        }
        .navigationTitle("Settings")
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
    SettingsView(theme: ThemeViewModel())
}
