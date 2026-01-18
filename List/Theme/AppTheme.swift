import SwiftUI

enum AppTheme {

    static func accentColor(for scheme: ColorScheme) -> Color {
        switch scheme {
        case .dark:
            return .orange
        default:
            return .orange
        }
    }
}
