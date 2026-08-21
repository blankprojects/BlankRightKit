import AppKit
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let instanceID = UUID().uuidString
    private let settingsStore = SettingsStore()
    private let planner = MenuPlanner()
    private lazy var executor = SystemActionExecutor(
        asynchronousFailureHandler: { [weak self] displayName, error in
            self?.handleAsynchronousOpenFailure(displayName: displayName, error: error)
        }
    )
    private var latestContext = ActionContext(targetedURL: nil, selectedURLs: [], isContainerMenu: false)

    override init() {
        super.init()

        brkTrace(
            "BRKTRACE init instance=%@ pid=%d bundle=%@ version=%@ build=%@",
            instanceID,
            ProcessInfo.processInfo.processIdentifier,
            Bundle.main.bundlePath,
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown",
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        )

        // Registering the root makes the menu available throughout local Finder
        // locations. Finder/File Provider can still suppress extensions in some
        // managed cloud folders; that is a system limitation.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/", isDirectory: true)]
        brkTrace("BRKTRACE directories registered instance=%@ paths=/ trace=%@", instanceID, BRKTraceLogger.shared.fileURL.path)
    }

    deinit {
        brkTrace("BRKTRACE deinit instance=%@", instanceID)
    }

    override var toolbarItemName: String { "BlankRightKit" }

    override var toolbarItemToolTip: String { "BlankRightKit 文件工具" }

    override var toolbarItemImage: NSImage {
        NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "BlankRightKit")
            ?? NSImage(size: NSSize(width: 18, height: 18))
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let controller = FIFinderSyncController.default()
        let targetedURL = controller.targetedURL()
        let selectedURLs = controller.selectedItemURLs() ?? []
        let isContainer = menuKind == .contextualMenuForContainer
            || (selectedURLs.isEmpty && menuKind == .toolbarItemMenu)
        let context = ActionContext(
            targetedURL: targetedURL,
            selectedURLs: selectedURLs,
            isContainerMenu: isContainer
        )
        latestContext = context

        let settings = settingsStore.load()
        let sections = planner.actionsBySection(settings: settings, context: context)
        brkTrace(
            "BRKTRACE menu requested instance=%@ kind=%@ target=%@ selectedCount=%d selected=%@ isContainer=%d enabledCount=%d groupedSetting=%d",
            instanceID,
            menuKindName(menuKind),
            targetedURL?.path ?? "nil",
            selectedURLs.count,
            selectedURLs.map(\.path).joined(separator: " | "),
            isContainer ? 1 : 0,
            settings.enabledActions.count,
            settings.groupIntoSubmenu ? 1 : 0
        )

        guard !sections.isEmpty else {
            brkTrace("BRKTRACE menu suppressed instance=%@ reason=no-applicable-actions", instanceID)
            return nil
        }

        let actionMenu = buildActionMenu(sections: sections)
        if settings.groupIntoSubmenu {
            let outerMenu = NSMenu(title: "")
            let rootItem = NSMenuItem(title: "BlankRightKit", action: nil, keyEquivalent: "")
            rootItem.image = NSImage(
                systemSymbolName: "cursorarrow.click.2",
                accessibilityDescription: "BlankRightKit"
            )
            rootItem.submenu = actionMenu
            outerMenu.addItem(rootItem)
            brkTrace(
                "BRKTRACE menu returned instance=%@ layout=submenu outerItemCount=%d actionItemCount=%d routing=independent-selectors",
                instanceID,
                outerMenu.items.count,
                actionMenu.items.count
            )
            return outerMenu
        }

        brkTrace(
            "BRKTRACE menu returned instance=%@ layout=flat itemCount=%d routing=independent-selectors",
            instanceID,
            actionMenu.items.count
        )
        return actionMenu
    }

    private func buildActionMenu(sections: [(ActionSection, [ActionID])]) -> NSMenu {
        let menu = NSMenu(title: "BlankRightKit")
        for (sectionIndex, section) in sections.enumerated() {
            if sectionIndex > 0 { menu.addItem(.separator()) }
            for action in section.1 {
                // Finder serializes extension menus across an XPC boundary.
                // Follow Apple's Finder Sync template and route each item by
                // selector; representedObject and an explicit target are not
                // guaranteed to survive that round trip.
                let item = NSMenuItem(title: action.title, action: selector(for: action), keyEquivalent: "")
                item.image = NSImage(systemSymbolName: action.symbolName, accessibilityDescription: action.title)
                menu.addItem(item)
                brkTrace(
                    "BRKTRACE menu item instance=%@ action=%@ title=%@ selector=%@",
                    instanceID,
                    action.rawValue,
                    action.title,
                    NSStringFromSelector(selector(for: action))
                )
            }
        }
        return menu
    }

    private func selector(for action: ActionID) -> Selector {
        switch action {
        case .newTextFile: return #selector(newTextFile(_:))
        case .newMarkdownFile: return #selector(newMarkdownFile(_:))
        case .newJSONFile: return #selector(newJSONFile(_:))
        case .newFolder: return #selector(newFolder(_:))
        case .copyPath: return #selector(copyPath(_:))
        case .copyName: return #selector(copyName(_:))
        case .copyShellPath: return #selector(copyShellPath(_:))
        case .openTerminal: return #selector(openTerminal(_:))
        case .openEditor: return #selector(openEditor(_:))
        case .calculateSHA256: return #selector(calculateSHA256(_:))
        case .imageToPNG: return #selector(imageToPNG(_:))
        case .imageToJPEG: return #selector(imageToJPEG(_:))
        }
    }

    @IBAction func newTextFile(_ sender: AnyObject?) { click(.newTextFile, sender: sender) }
    @IBAction func newMarkdownFile(_ sender: AnyObject?) { click(.newMarkdownFile, sender: sender) }
    @IBAction func newJSONFile(_ sender: AnyObject?) { click(.newJSONFile, sender: sender) }
    @IBAction func newFolder(_ sender: AnyObject?) { click(.newFolder, sender: sender) }
    @IBAction func copyPath(_ sender: AnyObject?) { click(.copyPath, sender: sender) }
    @IBAction func copyName(_ sender: AnyObject?) { click(.copyName, sender: sender) }
    @IBAction func copyShellPath(_ sender: AnyObject?) { click(.copyShellPath, sender: sender) }
    @IBAction func openTerminal(_ sender: AnyObject?) { click(.openTerminal, sender: sender) }
    @IBAction func openEditor(_ sender: AnyObject?) { click(.openEditor, sender: sender) }
    @IBAction func calculateSHA256(_ sender: AnyObject?) { click(.calculateSHA256, sender: sender) }
    @IBAction func imageToPNG(_ sender: AnyObject?) { click(.imageToPNG, sender: sender) }
    @IBAction func imageToJPEG(_ sender: AnyObject?) { click(.imageToJPEG, sender: sender) }

    private func click(_ action: ActionID, sender: AnyObject?) {
        let item = sender as? NSMenuItem
        brkTrace(
            "BRKTRACE click received instance=%@ action=%@ senderType=%@ senderTitle=%@",
            instanceID,
            action.rawValue,
            sender.map { String(describing: type(of: $0)) } ?? "nil",
            item?.title ?? "nil"
        )
        perform(action)
    }

    private func perform(_ action: ActionID) {
        // Apple only guarantees selection URLs while creating the menu and while
        // executing one of its actions, so refresh them here.
        let controller = FIFinderSyncController.default()
        let liveTarget = controller.targetedURL()
        let liveSelection = controller.selectedItemURLs()
        let refreshed = ActionContext(
            targetedURL: liveTarget ?? latestContext.targetedURL,
            selectedURLs: liveSelection ?? latestContext.selectedURLs,
            isContainerMenu: latestContext.isContainerMenu
        )
        brkTrace(
            "BRKTRACE action context instance=%@ action=%@ liveTarget=%@ effectiveTarget=%@ liveSelectedCount=%d effectiveSelectedCount=%d effectiveSelected=%@ destination=%@",
            instanceID,
            action.rawValue,
            liveTarget?.path ?? "nil",
            refreshed.targetedURL?.path ?? "nil",
            liveSelection?.count ?? -1,
            refreshed.selectedURLs.count,
            refreshed.selectedURLs.map(\.path).joined(separator: " | "),
            refreshed.destinationDirectory?.path ?? "nil"
        )

        do {
            let outcome = try executor.execute(action, context: refreshed, settings: settingsStore.load())
            brkTrace(
                "BRKTRACE action succeeded instance=%@ action=%@ message=%@ createdCount=%d created=%@ clipboardLength=%d",
                instanceID,
                action.rawValue,
                outcome.message,
                outcome.createdURLs.count,
                outcome.createdURLs.map(\.path).joined(separator: " | "),
                outcome.clipboardText?.count ?? 0
            )
        } catch {
            NSSound.beep()
            brkTrace(
                "BRKTRACE action failed instance=%@ action=%@ errorType=%@ localized=%@ detail=%@",
                instanceID,
                action.rawValue,
                String(describing: type(of: error)),
                error.localizedDescription,
                String(reflecting: error)
            )
            presentFailure(
                title: "无法执行“\(action.title)”",
                message: error.localizedDescription,
                path: refreshed.destinationDirectory?.path ?? refreshed.effectiveURLs.first?.path
            )
        }
    }

    private func handleAsynchronousOpenFailure(displayName: String, error: Error) {
        brkTrace(
            "BRKTRACE open failed instance=%@ application=%@ errorType=%@ localized=%@ detail=%@",
            instanceID,
            displayName,
            String(describing: type(of: error)),
            error.localizedDescription,
            String(reflecting: error)
        )
        presentFailure(
            title: "无法在 \(displayName) 中打开",
            message: error.localizedDescription,
            path: latestContext.effectiveURLs.first?.path
        )
    }

    private func presentFailure(title: String, message: String, path: String?) {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = title
            alert.informativeText = [message, path].compactMap { $0 }.joined(separator: "\n\n")
            alert.addButton(withTitle: "好")
            alert.runModal()
        }
    }

    private func menuKindName(_ kind: FIMenuKind) -> String {
        switch kind {
        case .contextualMenuForItems: return "contextualMenuForItems"
        case .contextualMenuForContainer: return "contextualMenuForContainer"
        case .contextualMenuForSidebar: return "contextualMenuForSidebar"
        case .toolbarItemMenu: return "toolbarItemMenu"
        @unknown default: return "unknown(\(kind.rawValue))"
        }
    }
}
