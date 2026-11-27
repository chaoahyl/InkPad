import SwiftUI
import UIKit

/// 系统分享面板。iOS 16 以后 SwiftUI 有 ShareLink，我们要支持 iOS 15，所以包 UIKit 的
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// 给 .sheet(item:) 用：每次分享都是一个新的 id
struct ShareItem: Identifiable {
    let id = UUID()
    let items: [Any]
}
