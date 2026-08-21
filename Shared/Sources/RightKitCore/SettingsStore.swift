import Foundation

public final class SettingsStore {
    public static let appGroupIdentifier = "group.io.github.rightkit"
    private static let settingsKey = "RightKit.settings.v1"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(defaults: UserDefaults? = UserDefaults(suiteName: SettingsStore.appGroupIdentifier)) {
        self.defaults = defaults ?? .standard
    }

    public func load() -> RightKitSettings {
        guard let data = defaults.data(forKey: Self.settingsKey),
              var settings = try? decoder.decode(RightKitSettings.self, from: data) else {
            return .default
        }
        settings.normalize()
        return settings
    }

    public func save(_ settings: RightKitSettings) throws {
        var normalized = settings
        normalized.normalize()
        let data = try encoder.encode(normalized)
        defaults.set(data, forKey: Self.settingsKey)
    }

    public func reset() {
        defaults.removeObject(forKey: Self.settingsKey)
    }
}
