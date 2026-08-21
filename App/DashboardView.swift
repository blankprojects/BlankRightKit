import AppKit
import FinderSync
import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: PreferencesModel

    var body: some View {
        TabView {
            GeneralSettingsView(model: model)
                .tabItem { Label("功能", systemImage: "switch.2") }

            TemplateSettingsView(model: model)
                .tabItem { Label("模板", systemImage: "doc.text") }

            PrivacyView()
                .tabItem { Label("隐私", systemImage: "hand.raised") }

            AboutView(model: model)
                .tabItem { Label("关于", systemImage: "info.circle") }
        }
        .padding(20)
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var model: PreferencesModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HeaderView()
                ExtensionStatusCard()

                GroupBox("菜单样式") {
                    Toggle(
                        "把所有功能收进一个“RightKit”子菜单",
                        isOn: Binding(
                            get: { model.settings.groupIntoSubmenu },
                            set: model.setGroupIntoSubmenu
                        )
                    )
                    .padding(8)
                }

                ForEach(ActionSection.allCases) { section in
                    GroupBox(section.title) {
                        VStack(spacing: 0) {
                            let actions = model.settings.orderedActions.filter { $0.section == section }
                            ForEach(Array(actions.enumerated()), id: \.element) { index, action in
                                Toggle(
                                    isOn: Binding(
                                        get: { model.isEnabled(action) },
                                        set: { model.setEnabled($0, action: action) }
                                    )
                                ) {
                                    Label(action.title, systemImage: action.symbolName)
                                }
                                .padding(.vertical, 7)
                                if index < actions.count - 1 { Divider() }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }

                GroupBox("首选应用") {
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                        GridRow {
                            Label("终端", systemImage: "apple.terminal")
                            Picker("", selection: Binding(
                                get: { model.settings.preferredTerminal },
                                set: model.setTerminal
                            )) {
                                ForEach(TerminalApplication.allCases) { app in
                                    Text(app.title).tag(app)
                                }
                            }
                            .labelsHidden()
                        }
                        GridRow {
                            Label("编辑器", systemImage: "chevron.left.forwardslash.chevron.right")
                            Picker("", selection: Binding(
                                get: { model.settings.preferredEditor },
                                set: model.setEditor
                            )) {
                                ForEach(EditorApplication.allCases) { app in
                                    Text(app.title).tag(app)
                                }
                            }
                            .labelsHidden()
                        }
                    }
                    .padding(8)
                }

                if let error = model.saveError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
            .padding(4)
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "cursorarrow.click.2")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [.indigo, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 15)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text("RightKit")
                    .font(.largeTitle.bold())
                Text("开源、原生、只在本机运行的 Finder 右键工具箱")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

private struct ExtensionStatusCard: View {
    @State private var isEnabled = FIFinderSyncController.isExtensionEnabled

    var body: some View {
        GroupBox("Finder 扩展") {
            HStack(spacing: 12) {
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isEnabled ? Color.green : Color.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(isEnabled ? "扩展已启用" : "还需要启用扩展")
                        .fontWeight(.semibold)
                    Text("系统设置 → 通用 → 登录项与扩展 → Finder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(isEnabled ? "管理扩展" : "立即启用") {
                    FIFinderSyncController.showExtensionManagementInterface()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isEnabled = FIFinderSyncController.isExtensionEnabled
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(8)
        }
        .onAppear { isEnabled = FIFinderSyncController.isExtensionEnabled }
    }
}

private struct TemplateSettingsView: View {
    @ObservedObject var model: PreferencesModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("新建文件模板")
                    .font(.largeTitle.bold())
                Text("文件名冲突时会自动追加数字，任何已有文件都不会被覆盖。")
                    .foregroundStyle(.secondary)

                ForEach(model.settings.templates) { template in
                    GroupBox(template.title) {
                        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                            GridRow {
                                Text("默认文件名")
                                TextField("未命名", text: binding(for: template, keyPath: \.baseName))
                            }
                            GridRow {
                                Text("扩展名")
                                TextField("txt", text: binding(for: template, keyPath: \.fileExtension))
                            }
                            GridRow(alignment: .top) {
                                Text("初始内容")
                                TextEditor(text: binding(for: template, keyPath: \.contents))
                                    .font(.system(.body, design: .monospaced))
                                    .frame(minHeight: 80)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                            }
                        }
                        .padding(8)
                    }
                }
            }
            .padding(4)
        }
    }

    private func binding(for template: NewFileTemplate, keyPath: WritableKeyPath<NewFileTemplate, String>) -> Binding<String> {
        Binding(
            get: {
                model.settings.templates.first(where: { $0.id == template.id })?[keyPath: keyPath] ?? ""
            },
            set: { value in
                model.updateTemplate(id: template.id) { $0[keyPath: keyPath] = value }
            }
        )
    }
}

private struct PrivacyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("隐私与安全")
                .font(.largeTitle.bold())
            Label("没有网络权限", systemImage: "wifi.slash")
                .font(.title3.bold())
            Text("RightKit 不包含账户、广告、遥测或更新检查。文件名、路径和文件内容不会离开你的 Mac。")
                .foregroundStyle(.secondary)
            Label("没有高风险快捷操作", systemImage: "trash.slash")
                .font(.title3.bold())
            Text("MVP 刻意不提供永久删除、批量覆盖、修改系统权限等容易误触的操作。新建与转换总是使用无冲突文件名。")
                .foregroundStyle(.secondary)
            Label("使用 Apple 官方扩展机制", systemImage: "puzzlepiece.extension")
                .font(.title3.bold())
            Text("Finder 菜单由 Finder Sync 扩展提供，不注入 Finder 进程，不使用私有 API。")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(4)
    }
}

private struct AboutView: View {
    @ObservedObject var model: PreferencesModel

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "cursorarrow.click.2")
                .font(.system(size: 54))
                .foregroundStyle(.blue)
            Text("RightKit")
                .font(.largeTitle.bold())
            Text("版本 0.1.0 · MIT License")
                .foregroundStyle(.secondary)
            Text("为 macOS 13 及以上版本设计。")
            Button("恢复默认设置", role: .destructive) { model.reset() }
                .padding(.top, 8)
            Spacer()
        }
        .padding(.top, 40)
    }
}
