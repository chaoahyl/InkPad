import PencilKit

/// 带系统工具栏的画布。
/// PKToolPicker 只跟着“第一响应者”显示，而视图要先进了窗口才能成为第一响应者，
/// 所以放在 didMoveToWindow 里做，不能在创建画布时就做。
final class ToolCanvasView: PKCanvasView {
    let toolPicker = PKToolPicker()
    var showsToolPicker = true

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, showsToolPicker else { return }
        toolPicker.addObserver(self)
        toolPicker.setVisible(true, forFirstResponder: self)
        becomeFirstResponder()
    }
}
