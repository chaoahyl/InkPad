import PencilKit
import SwiftUI
import UIKit

/// UIKit 写的画板页。画布是 UIKit；纸张背景和浮动工具条是 SwiftUI，
/// 用 UIHostingController 当子控制器放进来
final class DrawingViewController: UIViewController, PKCanvasViewDelegate {
    let model = CanvasModel()
    var onDone: ((PKDrawing) -> Void)?

    private let canvas = ToolCanvasView()
    private let paper: PaperStyle
    private let initialDrawing: PKDrawing

    init(drawing: PKDrawing, paper: PaperStyle) {
        self.initialDrawing = drawing
        self.paper = paper
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white

        // 1. 纸张背景：SwiftUI
        let background = UIHostingController(rootView: PaperBackground(style: paper))
        embed(background)
        pin(background.view, to: view)

        // 2. 画布：UIKit
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawing = initialDrawing
        canvas.delegate = self
        view.addSubview(canvas)
        pin(canvas, to: view)
        model.canvas = canvas

        // 3. 浮动工具条：SwiftUI，只占顶部一条
        let toolbar = UIHostingController(rootView: FloatingToolbar(model: model) { [weak self] in
            self?.finish()
        })
        toolbar.view.backgroundColor = .clear
        embed(toolbar)
        toolbar.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbar.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        model.refresh()
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        model.refresh()
    }

    private func finish() {
        onDone?(canvas.drawing)
    }

    /// 子控制器三步：addChild → 加视图 → didMove(toParent:)
    private func embed(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    private func pin(_ subview: UIView, to container: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: container.topAnchor),
            subview.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }
}
