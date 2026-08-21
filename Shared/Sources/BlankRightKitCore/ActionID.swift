import Foundation

public enum ActionID: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case newTextFile
    case newMarkdownFile
    case newJSONFile
    case newFolder
    case copyPath
    case copyName
    case copyShellPath
    case openTerminal
    case openEditor
    case calculateSHA256
    case imageToPNG
    case imageToJPEG

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .newTextFile: return "新建文本文件"
        case .newMarkdownFile: return "新建 Markdown"
        case .newJSONFile: return "新建 JSON"
        case .newFolder: return "新建文件夹"
        case .copyPath: return "复制完整路径"
        case .copyName: return "复制文件名"
        case .copyShellPath: return "复制 Shell 路径"
        case .openTerminal: return "在终端打开"
        case .openEditor: return "在编辑器打开"
        case .calculateSHA256: return "计算 SHA-256"
        case .imageToPNG: return "转换为 PNG"
        case .imageToJPEG: return "转换为 JPEG"
        }
    }

    public var symbolName: String {
        switch self {
        case .newTextFile: return "doc.badge.plus"
        case .newMarkdownFile: return "text.document"
        case .newJSONFile: return "curlybraces.square"
        case .newFolder: return "folder.badge.plus"
        case .copyPath: return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .copyName: return "doc.on.doc"
        case .copyShellPath: return "terminal"
        case .openTerminal: return "apple.terminal"
        case .openEditor: return "chevron.left.forwardslash.chevron.right"
        case .calculateSHA256: return "number"
        case .imageToPNG, .imageToJPEG: return "photo.badge.arrow.down"
        }
    }

    public var section: ActionSection {
        switch self {
        case .newTextFile, .newMarkdownFile, .newJSONFile, .newFolder:
            return .create
        case .copyPath, .copyName, .copyShellPath:
            return .copy
        case .openTerminal, .openEditor:
            return .open
        case .calculateSHA256, .imageToPNG, .imageToJPEG:
            return .tools
        }
    }
}

public enum ActionSection: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case create
    case copy
    case open
    case tools

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .create: return "新建"
        case .copy: return "复制"
        case .open: return "打开"
        case .tools: return "工具"
        }
    }
}
