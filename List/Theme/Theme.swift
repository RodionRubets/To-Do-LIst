import SwiftUI

enum AppColor: String, CaseIterable, Identifiable {
    case blue, purple, orange, black, pink
    
    var id: String {self.rawValue}
    
    var color: Color {
        switch self {
        case .blue:
            return  .blue
        case .purple:
            return .purple
        case .orange:
            return .orange
        case .black:
            return .black
        case .pink:
            return .pink
        }
    }
}
