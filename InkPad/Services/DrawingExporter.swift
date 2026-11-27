import PencilKit
import UIKit

/// 把 PencilKit 的笔画变成图片
enum DrawingExporter {
    /// 签名用：透明背景，只截笔画周围
    static func transparentImage(of drawing: PKDrawing, padding: CGFloat = 16, scale: CGFloat = 3) -> UIImage? {
        guard !drawing.bounds.isEmpty else { return nil }
        let rect = ExportLayout.paddedRect(drawing.bounds, padding: padding)
        return lightImage(drawing, rect: rect, scale: scale)
    }

    /// 缩略图：白底，等比缩小放进 size
    static func thumbnail(of drawing: PKDrawing, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            guard !drawing.bounds.isEmpty else { return }
            let rect = ExportLayout.paddedRect(drawing.bounds, padding: 24)
            let scale = ExportLayout.fitScale(content: rect.size, into: size)
            let drawn = CGSize(width: rect.width * scale, height: rect.height * scale)
            let origin = CGPoint(x: (size.width - drawn.width) / 2, y: (size.height - drawn.height) / 2)
            lightImage(drawing, rect: rect, scale: format.scale).draw(in: CGRect(origin: origin, size: drawn))
        }
    }

    /// 深色模式下黑色墨水会被画成白色，导出时固定按浅色模式画
    private static func lightImage(_ drawing: PKDrawing, rect: CGRect, scale: CGFloat) -> UIImage {
        var image = UIImage()
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            image = drawing.image(from: rect, scale: scale)
        }
        return image
    }
}
