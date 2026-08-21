import Foundation

public struct ActionOutcome: Equatable {
    public var message: String
    public var createdURLs: [URL]
    public var clipboardText: String?

    public init(message: String, createdURLs: [URL] = [], clipboardText: String? = nil) {
        self.message = message
        self.createdURLs = createdURLs
        self.clipboardText = clipboardText
    }
}
