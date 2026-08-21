import Foundation

public struct MenuPlanner: Sendable {
    private static let imageExtensions: Set<String> = ["png", "jpg", "jpeg", "heic", "heif", "tif", "tiff", "gif", "bmp"]

    public init() {}

    public func visibleActions(settings: BlankRightKitSettings, context: ActionContext) -> [ActionID] {
        settings.orderedActions.filter { action in
            settings.enabledActions.contains(action) && isApplicable(action, to: context)
        }
    }

    public func actionsBySection(settings: BlankRightKitSettings, context: ActionContext) -> [(ActionSection, [ActionID])] {
        let visible = visibleActions(settings: settings, context: context)
        return ActionSection.allCases.compactMap { section in
            let actions = visible.filter { $0.section == section }
            return actions.isEmpty ? nil : (section, actions)
        }
    }

    public func isApplicable(_ action: ActionID, to context: ActionContext) -> Bool {
        switch action {
        case .newTextFile, .newMarkdownFile, .newJSONFile, .newFolder:
            return context.destinationDirectory != nil
        case .copyPath, .copyName, .copyShellPath:
            return !context.effectiveURLs.isEmpty
        case .openTerminal, .openEditor:
            return context.effectiveURLs.count == 1
        case .calculateSHA256:
            return !context.selectedRegularFiles.isEmpty
        case .imageToPNG, .imageToJPEG:
            let files = context.selectedRegularFiles
            return !files.isEmpty && files.allSatisfy { Self.imageExtensions.contains($0.pathExtension.lowercased()) }
        }
    }
}
