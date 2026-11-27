import PencilKit
import SwiftUI

/// 签名页：写一个签名，导出透明背景 PNG，存到相册或分享
struct SignaturePage: View {
    @StateObject private var model = CanvasModel()
    @State private var preview: UIImage?
    @State private var sharing: ShareItem?
    @State private var message: String?
    @State private var saver = PhotoSaver()

    var body: some View {
        NavigationView {
            // 不放进 ScrollView：在签名区竖着画会被当成滚动
            VStack(spacing: 18) {
                signaturePad
                previewBox
                HStack(spacing: 12) {
                    actionButton("清空", symbol: "trash", action: model.clear)
                    actionButton("存到相册", symbol: "square.and.arrow.down", action: saveToPhotos)
                    actionButton("分享", symbol: "square.and.arrow.up", action: share)
                }
                .disabled(model.strokeCount == 0)
                Spacer()
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("签名")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onChange(of: model.strokeCount) { _ in
            preview = DrawingExporter.transparentImage(of: model.drawing)
        }
        .sheet(item: $sharing) { item in
            ShareSheet(items: item.items)
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("好", role: .cancel) {}
        }
    }

    /// 签名区：白底、一条签名线，上面叠透明的画布
    private var signaturePad: some View {
        ZStack(alignment: .bottomLeading) {
            Color.white
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("✕").font(.title3).foregroundColor(.secondary)
                Rectangle().fill(Color.secondary.opacity(0.4)).frame(height: 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
            CanvasView(model: model, ink: PKInkingTool(.pen, color: .black, width: 4), showsToolPicker: false)
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// 导出预览：放在灰白格子上，看得出背景是透明的
    private var previewBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("导出预览（透明背景 PNG）").font(.footnote).foregroundColor(.secondary)
            ZStack {
                Checkerboard()
                if let preview {
                    Image(uiImage: preview).resizable().scaledToFit().padding(8)
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if let preview {
                Text("\(Int(preview.size.width * preview.scale)) × \(Int(preview.size.height * preview.scale)) 像素")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
        }
    }

    private func actionButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol).font(.title3)
                Text(title).font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func saveToPhotos() {
        guard let preview else { return }
        saver.save(preview) { error in
            if let error {
                message = "没有存进去：\(error.localizedDescription)"
            } else {
                Haptics.success()
                message = "已存到相册"
            }
        }
    }

    /// 分享 PNG 文件而不是 UIImage，透明背景和文件名都能保留
    private func share() {
        guard let data = preview?.pngData() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("签名.png")
        do {
            try data.write(to: url, options: .atomic)
            sharing = ShareItem(items: [url])
        } catch {
            message = "导出失败：\(error.localizedDescription)"
        }
    }
}
