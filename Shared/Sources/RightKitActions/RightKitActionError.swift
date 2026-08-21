import Foundation

public enum RightKitActionError: LocalizedError, Equatable {
    case missingDestination
    case missingSelection
    case templateNotFound
    case cannotCreate(String)
    case cannotRead(String)
    case applicationNotInstalled(String)
    case unsupportedImage(String)
    case imageConversionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .missingDestination:
            return "找不到目标文件夹。"
        case .missingSelection:
            return "没有可处理的选中项目。"
        case .templateNotFound:
            return "找不到对应的新建文件模板。"
        case .cannotCreate(let name):
            return "无法创建“\(name)”。"
        case .cannotRead(let name):
            return "无法读取“\(name)”。"
        case .applicationNotInstalled(let name):
            return "未安装 \(name)，请在 RightKit 设置中更换应用。"
        case .unsupportedImage(let name):
            return "“\(name)”不是受支持的图片。"
        case .imageConversionFailed(let name):
            return "转换“\(name)”失败。"
        }
    }
}
