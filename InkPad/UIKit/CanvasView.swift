import PencilKit
import SwiftUI

/// 把 UIKit 的 PKCanvasView 包成 SwiftUI 视图
struct CanvasView: UIViewRepresentable {
    let model: CanvasModel
    var drawing = PKDrawing()
    var ink = PKInkingTool(.pen, color: .black, width: 5)
    var showsToolPicker = true

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> ToolCanvasView {
        let canvas = ToolCanvasView()
        canvas.drawingPolicy = .anyInput          // 手指也能画
        canvas.tool = ink
        canvas.backgroundColor = .clear           // 透明，背后的纸张由 SwiftUI 来画
        canvas.isOpaque = false
        canvas.overrideUserInterfaceStyle = .light
        canvas.contentInsetAdjustmentBehavior = .never   // 画布是 UIScrollView，不要让导航栏把内容往下推
        canvas.showsToolPicker = showsToolPicker
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        model.canvas = canvas
        DispatchQueue.main.async { model.refresh() }
        return canvas
    }

    func updateUIView(_ canvas: ToolCanvasView, context: Context) {}

    /// 画布的 delegate 回调由 Coordinator 接住，再交给 SwiftUI
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        let model: CanvasModel

        init(model: CanvasModel) {
            self.model = model
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            model.refresh()
        }
    }
}
