import Foundation

public enum TerminalApplication: String, CaseIterable, Codable, Sendable, Identifiable {
    case terminal
    case iTerm
    case ghostty

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .terminal: return "Terminal"
        case .iTerm: return "iTerm2"
        case .ghostty: return "Ghostty"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .terminal: return "com.apple.Terminal"
        case .iTerm: return "com.googlecode.iterm2"
        case .ghostty: return "com.mitchellh.ghostty"
        }
    }
}

public enum EditorApplication: String, CaseIterable, Codable, Sendable, Identifiable {
    case visualStudioCode
    case cursor
    case zed
    case xcode

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .visualStudioCode: return "Visual Studio Code"
        case .cursor: return "Cursor"
        case .zed: return "Zed"
        case .xcode: return "Xcode"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .visualStudioCode: return "com.microsoft.VSCode"
        case .cursor: return "com.todesktop.230313mzl4w4u92"
        case .zed: return "dev.zed.Zed"
        case .xcode: return "com.apple.dt.Xcode"
        }
    }
}

public struct NewFileTemplate: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    public var title: String
    public var baseName: String
    public var fileExtension: String
    public var contents: String

    public init(id: String, title: String, baseName: String, fileExtension: String, contents: String) {
        self.id = id
        self.title = title
        self.baseName = baseName
        self.fileExtension = fileExtension
        self.contents = contents
    }

    public static let defaults: [NewFileTemplate] = [
        .init(id: "text", title: "文本文件", baseName: "未命名", fileExtension: "txt", contents: ""),
        .init(id: "markdown", title: "Markdown", baseName: "未命名", fileExtension: "md", contents: "# 标题\n"),
        .init(id: "json", title: "JSON", baseName: "未命名", fileExtension: "json", contents: "{\n  \n}\n")
    ]
}

public struct BlankRightKitSettings: Codable, Equatable, Sendable {
    public var enabledActions: Set<ActionID>
    public var orderedActions: [ActionID]
    public var groupIntoSubmenu: Bool
    public var preferredTerminal: TerminalApplication
    public var preferredEditor: EditorApplication
    public var templates: [NewFileTemplate]

    public init(
        enabledActions: Set<ActionID> = Set(ActionID.allCases),
        orderedActions: [ActionID] = ActionID.allCases,
        groupIntoSubmenu: Bool = true,
        preferredTerminal: TerminalApplication = .terminal,
        preferredEditor: EditorApplication = .visualStudioCode,
        templates: [NewFileTemplate] = NewFileTemplate.defaults
    ) {
        self.enabledActions = enabledActions
        self.orderedActions = orderedActions
        self.groupIntoSubmenu = groupIntoSubmenu
        self.preferredTerminal = preferredTerminal
        self.preferredEditor = preferredEditor
        self.templates = templates
    }

    public static let `default` = BlankRightKitSettings()

    public mutating func normalize() {
        let known = Set(ActionID.allCases)
        enabledActions.formIntersection(known)
        orderedActions = orderedActions.filter(known.contains)
        for action in ActionID.allCases where !orderedActions.contains(action) {
            orderedActions.append(action)
        }
    }
}
