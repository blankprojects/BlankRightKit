import CryptoKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

#if SWIFT_PACKAGE
import BlankRightKitCore
#endif

public struct FileActionService {
    private let fileManager: FileManager
    private let nameResolver: UniqueNameResolver

    public init(fileManager: FileManager = .default, nameResolver: UniqueNameResolver = .init()) {
        self.fileManager = fileManager
        self.nameResolver = nameResolver
    }

    public func createFile(for action: ActionID, context: ActionContext, settings: BlankRightKitSettings) throws -> ActionOutcome {
        guard let directory = context.destinationDirectory else {
            throw BlankRightKitActionError.missingDestination
        }

        let templateID: String
        switch action {
        case .newTextFile: templateID = "text"
        case .newMarkdownFile: templateID = "markdown"
        case .newJSONFile: templateID = "json"
        default: throw BlankRightKitActionError.templateNotFound
        }

        guard let template = settings.templates.first(where: { $0.id == templateID }) else {
            throw BlankRightKitActionError.templateNotFound
        }

        let url = nameResolver.availableURL(
            in: directory,
            baseName: template.baseName,
            fileExtension: template.fileExtension,
            fileManager: fileManager
        )

        do {
            let data = template.contents.data(using: .utf8) ?? Data()
            try data.write(to: url, options: .withoutOverwriting)
        } catch {
            throw BlankRightKitActionError.cannotCreate(url.lastPathComponent)
        }

        return ActionOutcome(message: "已创建 \(url.lastPathComponent)", createdURLs: [url])
    }

    public func createFolder(context: ActionContext) throws -> ActionOutcome {
        guard let directory = context.destinationDirectory else {
            throw BlankRightKitActionError.missingDestination
        }

        let url = nameResolver.availableURL(
            in: directory,
            baseName: "新建文件夹",
            fileManager: fileManager
        )

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            return ActionOutcome(message: "已创建 \(url.lastPathComponent)", createdURLs: [url])
        } catch {
            throw BlankRightKitActionError.cannotCreate(url.lastPathComponent)
        }
    }

    public func clipboardText(for action: ActionID, context: ActionContext) throws -> String {
        let urls = context.effectiveURLs
        guard !urls.isEmpty else { throw BlankRightKitActionError.missingSelection }

        switch action {
        case .copyPath:
            return urls.map(\.path).joined(separator: "\n")
        case .copyName:
            return urls.map(\.lastPathComponent).joined(separator: "\n")
        case .copyShellPath:
            return urls.map { shellEscaped($0.path) }.joined(separator: " ")
        default:
            throw BlankRightKitActionError.missingSelection
        }
    }

    public func calculateSHA256(context: ActionContext) throws -> ActionOutcome {
        let files = context.selectedRegularFiles
        guard !files.isEmpty else { throw BlankRightKitActionError.missingSelection }

        let pairs = try files.map { url -> (String, String) in
            (try sha256(of: url), url.lastPathComponent)
        }
        let text = pairs.count == 1
            ? pairs[0].0
            : pairs.map { "\($0.0)  \($0.1)" }.joined(separator: "\n")
        return ActionOutcome(message: "SHA-256 已复制", clipboardText: text)
    }

    public func convertImages(context: ActionContext, to type: UTType) throws -> ActionOutcome {
        let files = context.selectedRegularFiles
        guard !files.isEmpty else { throw BlankRightKitActionError.missingSelection }

        let outputExtension = type == .png ? "png" : "jpg"
        let outputs = try files.map { sourceURL -> URL in
            guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
                  CGImageSourceGetCount(source) > 0 else {
                throw BlankRightKitActionError.unsupportedImage(sourceURL.lastPathComponent)
            }

            let outputURL = nameResolver.availableURL(
                in: sourceURL.deletingLastPathComponent(),
                baseName: sourceURL.deletingPathExtension().lastPathComponent,
                fileExtension: outputExtension,
                fileManager: fileManager
            )

            do {
                // Reserve the chosen name atomically. ImageIO then writes to a
                // file owned by this operation instead of racing another writer.
                try Data().write(to: outputURL, options: .withoutOverwriting)
            } catch {
                throw BlankRightKitActionError.cannotCreate(outputURL.lastPathComponent)
            }

            guard let destination = CGImageDestinationCreateWithURL(
                outputURL as CFURL,
                type.identifier as CFString,
                1,
                nil
            ) else {
                try? fileManager.removeItem(at: outputURL)
                throw BlankRightKitActionError.imageConversionFailed(sourceURL.lastPathComponent)
            }

            let options: CFDictionary
            if type == .jpeg {
                options = [kCGImageDestinationLossyCompressionQuality: 0.88] as CFDictionary
            } else {
                options = [:] as CFDictionary
            }
            CGImageDestinationAddImageFromSource(destination, source, 0, options)

            guard CGImageDestinationFinalize(destination) else {
                try? fileManager.removeItem(at: outputURL)
                throw BlankRightKitActionError.imageConversionFailed(sourceURL.lastPathComponent)
            }
            return outputURL
        }

        return ActionOutcome(message: "已转换 \(outputs.count) 张图片", createdURLs: outputs)
    }

    public func sha256(of url: URL) throws -> String {
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            throw BlankRightKitActionError.cannotRead(url.lastPathComponent)
        }
        defer { try? handle.close() }

        var hasher = SHA256()
        do {
            while let data = try handle.read(upToCount: 1_048_576), !data.isEmpty {
                hasher.update(data: data)
            }
        } catch {
            throw BlankRightKitActionError.cannotRead(url.lastPathComponent)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    public func shellEscaped(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
