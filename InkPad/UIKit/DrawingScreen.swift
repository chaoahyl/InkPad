import PencilKit
import SwiftUI

/// 把 UIKit 的画板页放回 SwiftUI
struct DrawingScreen: UIViewControllerRepresentable {
    let paper: PaperStyle
    let drawing: PKDrawing
    var onDone: (PKDrawing) -> Void

    func makeUIViewController(context: Context) -> DrawingViewController {
        let controller = DrawingViewController(drawing: drawing, paper: paper)
        controller.onDone = onDone
        return controller
    }

    func updateUIViewController(_ controller: DrawingViewController, context: Context) {
        controller.onDone = onDone
    }
}
