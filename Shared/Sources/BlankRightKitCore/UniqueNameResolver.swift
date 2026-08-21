import Foundation

public struct UniqueNameResolver: Sendable {
    public init() {}

    public func availableURL(
        in directory: URL,
        baseName: String,
        fileExtension: String? = nil,
        fileManager: FileManager = .default
    ) -> URL {
        let cleanExtension = sanitize(
            fileExtension?.trimmingCharacters(in: CharacterSet(charactersIn: ".")) ?? ""
        )
        var cleanBaseName = sanitize(baseName)
        if cleanBaseName == "." || cleanBaseName == ".." || (cleanBaseName.isEmpty && cleanExtension.isEmpty) {
            cleanBaseName = "未命名"
        }

        for index in 1...10_000 {
            let suffix = index == 1 ? "" : " \(index)"
            let name: String
            if cleanBaseName.isEmpty, !cleanExtension.isEmpty {
                name = ".\(cleanExtension)\(suffix)"
            } else if cleanExtension.isEmpty {
                name = "\(cleanBaseName)\(suffix)"
            } else {
                name = "\(cleanBaseName)\(suffix).\(cleanExtension)"
            }

            let candidate = directory.appendingPathComponent(name, isDirectory: false)
            if !fileManager.fileExists(atPath: candidate.path) {
                return candidate
            }
        }

        let fallbackName = cleanExtension.isEmpty
            ? UUID().uuidString
            : "\(UUID().uuidString).\(cleanExtension)"
        return directory.appendingPathComponent(fallbackName)
    }

    private func sanitize(_ value: String) -> String {
        value
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "\0", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
