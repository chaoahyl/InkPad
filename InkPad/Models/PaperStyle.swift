import Foundation

/// 纸张背景：画布本身是透明的，背后用 SwiftUI 画横线或方格
enum PaperStyle: String, Codable, CaseIterable, Identifiable {
    case blank, lined, grid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blank: return "空白"
        case .lined: return "横线"
        case .grid: return "方格"
        }
    }

    var symbol: String {
        switch self {
        case .blank: return "doc"
        case .lined: return "text.justify"
        case .grid: return "squareshape.split.3x3"
        }
    }
}
