import SwiftUI

struct SplashScreen: View {
        @State private var isActive = false
    
    var body: some View {
        if isActive {
           // ContentView(vm: TodoViewModel())
        } else {
            VStack {
                Image("NoteLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true
                }
            }
            
        }
    }
}

#Preview {
    SplashScreen()
}
