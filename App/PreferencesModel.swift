import Foundation

@MainActor
final class PreferencesModel: ObservableObject {
    @Published private(set) var settings: RightKitSettings
    @Published private(set) var saveError: String?

    private let store: SettingsStore

    init(store: SettingsStore = SettingsStore()) {
        self.store = store
        self.settings = store.load()
    }

    func isEnabled(_ action: ActionID) -> Bool {
        settings.enabledActions.contains(action)
    }

    func setEnabled(_ enabled: Bool, action: ActionID) {
        update { settings in
            if enabled {
                settings.enabledActions.insert(action)
            } else {
                settings.enabledActions.remove(action)
            }
        }
    }

    func setGroupIntoSubmenu(_ value: Bool) {
        update { $0.groupIntoSubmenu = value }
    }

    func setTerminal(_ value: TerminalApplication) {
        update { $0.preferredTerminal = value }
    }

    func setEditor(_ value: EditorApplication) {
        update { $0.preferredEditor = value }
    }

    func updateTemplate(id: String, mutate: (inout NewFileTemplate) -> Void) {
        update { settings in
            guard let index = settings.templates.firstIndex(where: { $0.id == id }) else { return }
            mutate(&settings.templates[index])
        }
    }

    func reset() {
        store.reset()
        settings = .default
        saveError = nil
    }

    private func update(_ mutate: (inout RightKitSettings) -> Void) {
        var copy = settings
        mutate(&copy)
        settings = copy
        do {
            try store.save(copy)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }
}
