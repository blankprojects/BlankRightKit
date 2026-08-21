import SwiftUI

@main
struct RightKitApp: App {
    @StateObject private var preferences = PreferencesModel()

    var body: some Scene {
        WindowGroup {
            DashboardView(model: preferences)
                .frame(minWidth: 760, minHeight: 560)
        }
        .defaultSize(width: 880, height: 650)

        Settings {
            DashboardView(model: preferences)
                .frame(width: 820, height: 600)
        }
    }
}
