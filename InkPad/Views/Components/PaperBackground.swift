import SwiftUI

/// 纸张背景：白底，加横线或方格。画布是透明的，叠在它上面
struct PaperBackground: View {
    var style: PaperStyle
    var spacing: CGFloat = 32

    var body: some View {
        Canvas { context, size in
            var path = Path()
            if style != .blank {
                for y in stride(from: spacing * 3, to: size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            if style == .grid {
                for x in stride(from: spacing / 2, to: size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
            }
            context.stroke(path, with: .color(Color.blue.opacity(0.16)), lineWidth: 1)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}
