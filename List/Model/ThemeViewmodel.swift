import SwiftUI

class ThemeViewModel: ObservableObject {
    @AppStorage("appColor") var savedColor: String = AppColor.blue.rawValue
    
    var currentColor: AppColor {
        AppColor(rawValue: savedColor) ?? .blue
    }
    
    func setColor(_ color: AppColor) {
        savedColor = color.rawValue
    }
}
