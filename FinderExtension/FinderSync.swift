import AppKit
import FinderSync

@objc(FinderSync)
final class FinderSync: FIFinderSync {
    private let settingsStore = SettingsStore()
    private let planner = MenuPlanner()
    private let executor = SystemActionExecutor()
    private var latestContext = ActionContext(targetedURL: nil, selectedURLs: [], isContainerMenu: false)

    override init() {
        super.init()

        // Registering the root makes the menu available throughout local Finder
        // locations. Finder/File Provider can still suppress extensions in some
        // managed cloud folders; that is a system limitation.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/", isDirectory: true)]
    }

    override var toolbarItemName: String { "BlankRightKit" }

    override var toolbarItemToolTip: String { "BlankRightKit 文件工具" }

    override var toolbarItemImage: NSImage {
        NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "BlankRightKit")
            ?? NSImage(size: NSSize(width: 18, height: 18))
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let controller = FIFinderSyncController.default()
        let selectedURLs = controller.selectedItemURLs() ?? []
        let isContainer = menuKind == .contextualMenuForContainer
            || (selectedURLs.isEmpty && menuKind == .toolbarItemMenu)
        let context = ActionContext(
            targetedURL: controller.targetedURL(),
            selectedURLs: selectedURLs,
            isContainerMenu: isContainer
        )
        latestContext = context

        let settings = settingsStore.load()
        let sections = planner.actionsBySection(settings: settings, context: context)
        guard !sections.isEmpty else { return nil }

        let actionMenu = buildActionMenu(sections: sections)
        guard settings.groupIntoSubmenu else { return actionMenu }

        let outerMenu = NSMenu(title: "")
        let rootItem = NSMenuItem(title: "BlankRightKit", action: nil, keyEquivalent: "")
        rootItem.image = NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "BlankRightKit")
        rootItem.submenu = actionMenu
        outerMenu.addItem(rootItem)
        return outerMenu
    }

    private func buildActionMenu(sections: [(ActionSection, [ActionID])]) -> NSMenu {
        let menu = NSMenu(title: "BlankRightKit")
        for (sectionIndex, section) in sections.enumerated() {
            if sectionIndex > 0 { menu.addItem(.separator()) }
            for action in section.1 {
                let item = NSMenuItem(title: action.title, action: #selector(performAction(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = action.rawValue
                item.image = NSImage(systemSymbolName: action.symbolName, accessibilityDescription: action.title)
                menu.addItem(item)
            }
        }
        return menu
    }

    @objc private func performAction(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let action = ActionID(rawValue: rawValue) else {
            NSSound.beep()
            return
        }

        // Apple only guarantees selection URLs while creating the menu and while
        // executing one of its actions, so refresh them here.
        let controller = FIFinderSyncController.default()
        let refreshed = ActionContext(
            targetedURL: controller.targetedURL() ?? latestContext.targetedURL,
            selectedURLs: controller.selectedItemURLs() ?? latestContext.selectedURLs,
            isContainerMenu: latestContext.isContainerMenu
        )

        do {
            _ = try executor.execute(action, context: refreshed, settings: settingsStore.load())
        } catch {
            NSSound.beep()
            NSLog("BlankRightKit action failed: %@", error.localizedDescription)
        }
    }
}
