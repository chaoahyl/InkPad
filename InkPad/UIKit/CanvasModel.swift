import PencilKit
import SwiftUI

/// SwiftUI 和画布之间的桥：SwiftUI 的按钮调它，画布的变化也写回它
final class CanvasModel: ObservableObject {
    @Published private(set) var strokeCount = 0
    @Published private(set) var canUndo = false
    @Published private(set) var canRedo = false

    weak var canvas: PKCanvasView?

    var drawing: PKDrawing { canvas?.drawing ?? PKDrawing() }

    /// 撤销、重做用的是画布自己的 undoManager，它来自 UIKit 的响应链
    func undo() {
        canvas?.undoManager?.undo()
        refresh()
    }

    func redo() {
        canvas?.undoManager?.redo()
        refresh()
    }

    /// 清空也要能撤销：把旧的笔画登记到 undoManager
    func clear() {
        setDrawing(PKDrawing())
    }

    private func setDrawing(_ new: PKDrawing) {
        guard let canvas else { return }
        let old = canvas.drawing
        canvas.undoManager?.registerUndo(withTarget: self) { $0.setDrawing(old) }
        canvas.drawing = new
        refresh()
    }

    func refresh() {
        guard let canvas else { return }
        strokeCount = canvas.drawing.strokes.count
        canUndo = canvas.undoManager?.canUndo ?? false
        canRedo = canvas.undoManager?.canRedo ?? false
    }
}
