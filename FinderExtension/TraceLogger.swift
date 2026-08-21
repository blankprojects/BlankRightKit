import Darwin
import Foundation

/// A deliberately simple append-only trace used while Finder owns the UI.
/// Finder/XPC can omit extension NSLog entries from `log show`, so every event
/// is also written to the extension's own sandbox container for diagnostics.
func brkTrace(_ format: String, _ arguments: CVarArg...) {
    let message = String(format: format, arguments: arguments)
    NSLog("%@", message)
    BRKTraceLogger.shared.append(message)
}

final class BRKTraceLogger {
    static let shared = BRKTraceLogger()

    let fileURL: URL

    private init() {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let directory = applicationSupport.appendingPathComponent("BlankRightKit", isDirectory: true)
        fileURL = directory.appendingPathComponent("trace.log", isDirectory: false)
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
    }

    func append(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "\(timestamp) pid=\(ProcessInfo.processInfo.processIdentifier) \(message)\n"
        let descriptor = Darwin.open(
            fileURL.path,
            O_WRONLY | O_CREAT | O_APPEND,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else { return }
        defer { Darwin.close(descriptor) }

        line.utf8CString.withUnsafeBytes { bytes in
            guard let address = bytes.baseAddress else { return }
            _ = Darwin.write(descriptor, address, max(0, bytes.count - 1))
        }
    }
}
