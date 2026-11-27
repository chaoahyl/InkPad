import SwiftUI

/// 灰白格子：透明图片放在上面，一眼就能看出哪里是透明的
struct Checkerboard: View {
    var square: CGFloat = 10

    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / square))
            let rows = Int(ceil(size.height / square))
            for row in 0..<rows {
                for column in 0..<columns where (row + column).isMultiple(of: 2) {
                    let rect = CGRect(x: CGFloat(column) * square, y: CGFloat(row) * square, width: square, height: square)
                    context.fill(Path(rect), with: .color(Color(white: 0.88)))
                }
            }
        }
        .background(Color.white)
    }
}
