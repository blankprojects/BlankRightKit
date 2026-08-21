import Foundation
import Testing
import UniformTypeIdentifiers
@testable import RightKitActions
@testable import RightKitCore

@Suite("File actions")
struct FileActionServiceTests {
    @Test("Creating a template preserves its contents and avoids overwriting")
    func createTemplate() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let context = ActionContext(targetedURL: root, selectedURLs: [], isContainerMenu: true)
        let service = FileActionService()
        let first = try service.createFile(for: .newMarkdownFile, context: context, settings: .default)
        let second = try service.createFile(for: .newMarkdownFile, context: context, settings: .default)

        #expect(first.createdURLs[0].lastPathComponent == "未命名.md")
        #expect(second.createdURLs[0].lastPathComponent == "未命名 2.md")
        #expect(try String(contentsOf: first.createdURLs[0], encoding: .utf8) == "# 标题\n")
    }

    @Test("Shell paths are safely single-quoted")
    func shellEscaping() {
        let service = FileActionService()
        #expect(service.shellEscaped("/tmp/a b's.txt") == "'/tmp/a b'\\''s.txt'")
    }

    @Test("SHA-256 is streamed and returned in lowercase hex")
    func hash() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("hello".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        let hash = try FileActionService().sha256(of: url)
        #expect(hash == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    @Test("Image conversion writes a new file without replacing the source")
    func imageConversion() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let png = try #require(Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9Z0bYAAAAASUVORK5CYII="))
        let source = root.appendingPathComponent("pixel.png")
        try png.write(to: source)
        let context = ActionContext(targetedURL: source, selectedURLs: [source], isContainerMenu: false)

        let result = try FileActionService().convertImages(context: context, to: .jpeg)
        let output = try #require(result.createdURLs.first)
        #expect(output.lastPathComponent == "pixel.jpg")
        #expect(FileManager.default.fileExists(atPath: source.path))
        #expect(FileManager.default.fileExists(atPath: output.path))
    }
}
