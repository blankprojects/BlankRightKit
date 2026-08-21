import Foundation
import Testing
@testable import BlankRightKitCore

@Suite("Settings persistence")
struct SettingsStoreTests {
    @Test("Settings round-trip as JSON")
    func roundTrip() throws {
        let suiteName = "BlankRightKitTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(defaults: defaults)
        var settings = BlankRightKitSettings.default
        settings.enabledActions.remove(.imageToJPEG)
        settings.preferredTerminal = .ghostty
        settings.groupIntoSubmenu = false

        try store.save(settings)
        #expect(store.load() == settings)
    }

    @Test("App and extension can share a JSON settings file")
    func fileRoundTrip() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BlankRightKitTests-\(UUID().uuidString)", isDirectory: true)
        let url = directory.appendingPathComponent("settings.json")
        defer { try? FileManager.default.removeItem(at: directory) }

        let writer = SettingsStore(storageURL: url)
        let reader = SettingsStore(storageURL: url)
        var settings = BlankRightKitSettings.default
        settings.preferredEditor = .zed
        settings.groupIntoSubmenu = false

        try writer.save(settings)

        #expect(reader.load() == settings)
        #expect((try? Data(contentsOf: url)) != nil)
    }
}
