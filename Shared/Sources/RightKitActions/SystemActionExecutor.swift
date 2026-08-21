import AppKit
import Foundation
import UniformTypeIdentifiers

#if SWIFT_PACKAGE
import RightKitCore
#endif

public final class SystemActionExecutor {
    private let service: FileActionService
    private let workspace: NSWorkspace

    public init(service: FileActionService = .init(), workspace: NSWorkspace = .shared) {
        self.service = service
        self.workspace = workspace
    }

    public func execute(
        _ action: ActionID,
        context: ActionContext,
        settings: RightKitSettings
    ) throws -> ActionOutcome {
        let outcome: ActionOutcome

        switch action {
        case .newTextFile, .newMarkdownFile, .newJSONFile:
            outcome = try service.createFile(for: action, context: context, settings: settings)
        case .newFolder:
            outcome = try service.createFolder(context: context)
        case .copyPath, .copyName, .copyShellPath:
            let text = try service.clipboardText(for: action, context: context)
            outcome = ActionOutcome(message: "已复制", clipboardText: text)
        case .openTerminal:
            try open(context: context, bundleIdentifier: settings.preferredTerminal.bundleIdentifier, displayName: settings.preferredTerminal.title, useParentForFiles: true)
            outcome = ActionOutcome(message: "已在 \(settings.preferredTerminal.title) 打开")
        case .openEditor:
            try open(context: context, bundleIdentifier: settings.preferredEditor.bundleIdentifier, displayName: settings.preferredEditor.title, useParentForFiles: false)
            outcome = ActionOutcome(message: "已在 \(settings.preferredEditor.title) 打开")
        case .calculateSHA256:
            outcome = try service.calculateSHA256(context: context)
        case .imageToPNG:
            outcome = try service.convertImages(context: context, to: .png)
        case .imageToJPEG:
            outcome = try service.convertImages(context: context, to: .jpeg)
        }

        if let text = outcome.clipboardText {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
        }
        if !outcome.createdURLs.isEmpty {
            workspace.activateFileViewerSelecting(outcome.createdURLs)
        }
        return outcome
    }

    private func open(
        context: ActionContext,
        bundleIdentifier: String,
        displayName: String,
        useParentForFiles: Bool
    ) throws {
        guard var target = context.effectiveURLs.first else {
            throw RightKitActionError.missingSelection
        }

        if useParentForFiles {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: target.path, isDirectory: &isDirectory), !isDirectory.boolValue {
                target = target.deletingLastPathComponent()
            }
        }

        guard let applicationURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            throw RightKitActionError.applicationNotInstalled(displayName)
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        workspace.open(
            [target],
            withApplicationAt: applicationURL,
            configuration: configuration,
            completionHandler: nil
        )
    }
}
