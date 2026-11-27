import Foundation
#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// 导出图片时的尺寸计算。只用 Foundation，所以能在 Linux 上直接跑测试
enum ExportLayout {
    /// 笔画范围四周留白，再取整到整数点
    static func paddedRect(_ bounds: CGRect, padding: CGFloat) -> CGRect {
        bounds.insetBy(dx: -padding, dy: -padding).integral
    }

    /// 把内容等比缩小放进 box，只缩不放
    static func fitScale(content: CGSize, into box: CGSize) -> CGFloat {
        guard content.width > 0, content.height > 0 else { return 1 }
        return min(box.width / content.width, box.height / content.height, 1)
    }
}
