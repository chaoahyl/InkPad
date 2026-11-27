import SwiftUI

/// 画板页顶部的浮动工具条。它是 SwiftUI 写的，被 UIKit 的 DrawingViewController 嵌进去
struct FloatingToolbar: View {
    @ObservedObject var model: CanvasModel
    var onDone: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 18) {
            if let onDone {
                Button(action: onDone) {
                    Text("完成").font(.headline)
                }
            }
            Spacer()
            Text("\(model.strokeCount) 笔")
                .font(.subheadline.monospacedDigit())
                .foregroundColor(.secondary)
            Spacer()
            toolButton("arrow.uturn.backward", label: "撤销", enabled: model.canUndo, action: model.undo)
            toolButton("arrow.uturn.forward", label: "重做", enabled: model.canRedo, action: model.redo)
            toolButton("trash", label: "清空", enabled: model.strokeCount > 0, action: model.clear)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        .padding(.horizontal, 12)
        .padding(.top, 6)
    }

    private func toolButton(_ symbol: String, label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 18, weight: .semibold))
        }
        .disabled(!enabled)
        .accessibilityLabel(label)
    }
}
