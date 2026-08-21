import Foundation

public struct ActionContext: Equatable, Sendable {
    public let targetedURL: URL?
    public let selectedURLs: [URL]
    public let isContainerMenu: Bool

    public init(targetedURL: URL?, selectedURLs: [URL], isContainerMenu: Bool) {
        self.targetedURL = targetedURL
        self.selectedURLs = selectedURLs
        self.isContainerMenu = isContainerMenu
    }

    public var effectiveURLs: [URL] {
        if !selectedURLs.isEmpty { return selectedURLs }
        if let targetedURL { return [targetedURL] }
        return []
    }

    public var destinationDirectory: URL? {
        if isContainerMenu { return targetedURL }
        guard selectedURLs.count == 1, let selected = selectedURLs.first else { return nil }

        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: selected.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return selected
        }
        return selected.deletingLastPathComponent()
    }

    public var selectedRegularFiles: [URL] {
        selectedURLs.filter { url in
            var isDirectory: ObjCBool = false
            return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && !isDirectory.boolValue
        }
    }
}
