import Foundation
import Testing
@testable import RightKitCore

@Suite("Unique file naming")
struct UniqueNameResolverTests {
    @Test("Existing names receive a numeric suffix")
    func suffix() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let first = root.appendingPathComponent("未命名.txt")
        FileManager.default.createFile(atPath: first.path, contents: Data())

        let resolved = UniqueNameResolver().availableURL(in: root, baseName: "未命名", fileExtension: "txt")
        #expect(resolved.lastPathComponent == "未命名 2.txt")
    }

    @Test("Dotfiles keep their leading dot")
    func dotfile() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let resolved = UniqueNameResolver().availableURL(
            in: root,
            baseName: "",
            fileExtension: ".env"
        )
        #expect(resolved.lastPathComponent == ".env")
    }

    @Test("Template names cannot escape the destination directory")
    func traversalIsSanitized() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let resolved = UniqueNameResolver().availableURL(
            in: root,
            baseName: "../outside",
            fileExtension: "../txt"
        )
        #expect(resolved.deletingLastPathComponent() == root)
        #expect(!resolved.lastPathComponent.contains("/"))
    }
}
