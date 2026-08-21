import Foundation
import Testing
@testable import RightKitCore

@Suite("Settings persistence")
struct SettingsStoreTests {
    @Test("Settings round-trip as JSON")
    func roundTrip() throws {
        let suiteName = "RightKitTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(defaults: defaults)
        var settings = RightKitSettings.default
        settings.enabledActions.remove(.imageToJPEG)
        settings.preferredTerminal = .ghostty
        settings.groupIntoSubmenu = false

        try store.save(settings)
        #expect(store.load() == settings)
    }
}
