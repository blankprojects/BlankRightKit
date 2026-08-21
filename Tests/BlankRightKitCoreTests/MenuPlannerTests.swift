import Foundation
import Testing
@testable import BlankRightKitCore

@Suite("Menu planning")
struct MenuPlannerTests {
    @Test("Container menus expose creation but not file-only tools")
    func containerMenu() {
        let directory = FileManager.default.temporaryDirectory
        let context = ActionContext(targetedURL: directory, selectedURLs: [], isContainerMenu: true)
        let actions = MenuPlanner().visibleActions(settings: .default, context: context)

        #expect(actions.contains(.newTextFile))
        #expect(actions.contains(.copyPath))
        #expect(!actions.contains(.calculateSHA256))
        #expect(!actions.contains(.imageToPNG))
    }

    @Test("Action order and disabled state are respected")
    func orderAndVisibility() {
        var settings = BlankRightKitSettings.default
        settings.orderedActions = [.copyName, .copyPath, .newFolder]
        settings.enabledActions.remove(.copyPath)

        let context = ActionContext(
            targetedURL: FileManager.default.temporaryDirectory,
            selectedURLs: [],
            isContainerMenu: true
        )
        let actions = MenuPlanner().visibleActions(settings: settings, context: context)

        #expect(actions == [.copyName, .newFolder])
    }
}
