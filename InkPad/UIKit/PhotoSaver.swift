import UIKit

/// 存相册用的是老式回调：target 加 selector，所以要继承 NSObject，回调方法加 @objc
final class PhotoSaver: NSObject {
    private var completion: ((Error?) -> Void)?

    func save(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    /// 参数顺序是固定的：图片、错误、contextInfo
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?(error)
        completion = nil
    }
}
