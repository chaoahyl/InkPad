import SwiftUI

/// 网格里的一格：缩略图、标题、修改时间
struct ArtworkCell: View {
    @EnvironmentObject private var store: ArtworkStore
    let artwork: Artwork
    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Color.white
                if let thumbnail {
                    Image(uiImage: thumbnail).resizable().scaledToFit()
                }
            }
            .aspectRatio(3 / 4, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06)))

            HStack(spacing: 6) {
                Image(systemName: artwork.paper.symbol).font(.caption).foregroundColor(.secondary)
                Text(artwork.title).font(.subheadline.weight(.semibold))
            }
            Text(artwork.updatedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        // 作品改过（修改时间变了）才重新生成缩略图
        .task(id: artwork.updatedAt) {
            thumbnail = DrawingExporter.thumbnail(of: store.drawing(for: artwork.id), size: CGSize(width: 240, height: 320))
        }
    }
}
