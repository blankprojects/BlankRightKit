import Foundation

public final class SettingsStore {
    private static let settingsKey = "BlankRightKit.settings.v1"
    public static let defaultStorageURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/BlankRightKit", isDirectory: true)
        .appendingPathComponent("settings.json", isDirectory: false)

    private let defaults: UserDefaults?
    private let storageURL: URL?
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        defaults: UserDefaults? = nil,
        storageURL: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.defaults = defaults
        self.storageURL = defaults == nil ? (storageURL ?? Self.defaultStorageURL) : nil
        self.fileManager = fileManager
    }

    public func load() -> BlankRightKitSettings {
        let data: Data?
        if let defaults {
            data = defaults.data(forKey: Self.settingsKey)
        } else if let storageURL {
            data = try? Data(contentsOf: storageURL)
        } else {
            data = nil
        }

        guard let data,
              var settings = try? decoder.decode(BlankRightKitSettings.self, from: data) else {
            return .default
        }
        settings.normalize()
        return settings
    }

    public func save(_ settings: BlankRightKitSettings) throws {
        var normalized = settings
        normalized.normalize()
        let data = try encoder.encode(normalized)

        if let defaults {
            defaults.set(data, forKey: Self.settingsKey)
            return
        }

        guard let storageURL else { return }
        try fileManager.createDirectory(
            at: storageURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        try data.write(to: storageURL, options: .atomic)
        try? fileManager.setAttributes([.posixPermissions: 0o600], ofItemAtPath: storageURL.path)
    }

    public func reset() {
        if let defaults {
            defaults.removeObject(forKey: Self.settingsKey)
        } else if let storageURL {
            try? fileManager.removeItem(at: storageURL)
        }
    }
}
