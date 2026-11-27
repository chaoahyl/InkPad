import PencilKit
import SwiftUI

/// 作品页：两列网格，右上角新建，点开继续画，长按删除
struct GalleryPage: View {
    @EnvironmentObject private var store: ArtworkStore
    @State private var editing: Artwork?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationView {
            Group {
                if store.artworks.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.artworks) { artwork in
                                Button { editing = artwork } label: {
                                    ArtworkCell(artwork: artwork)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) { store.delete(artwork.id) } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("作品")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(PaperStyle.allCases) { paper in
                            Button { editing = store.create(paper: paper) } label: {
                                Label(paper.title, systemImage: paper.symbol)
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新建")
                }
            }
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(item: $editing) { artwork in
            DrawingScreen(paper: artwork.paper, drawing: store.drawing(for: artwork.id)) { drawing in
                finish(artwork, drawing: drawing)
            }
            .ignoresSafeArea()
        }
    }

    /// 关闭画板时保存；新建了但一笔没画的，直接删掉
    private func finish(_ artwork: Artwork, drawing: PKDrawing) {
        if drawing.strokes.isEmpty && artwork.strokeCount == 0 {
            store.delete(artwork.id)
        } else {
            store.saveDrawing(drawing.dataRepresentation(), strokeCount: drawing.strokes.count, for: artwork.id)
        }
        editing = nil
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "scribble.variable")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("还没有作品").font(.headline)
            Text("点右上角的 + 新建一幅").font(.subheadline).foregroundColor(.secondary)
        }
    }
}

extension ArtworkStore {
    /// 读出笔画；文件不存在或读不出来就给一张空白的
    func drawing(for id: UUID) -> PKDrawing {
        guard let data = drawingData(for: id), let drawing = try? PKDrawing(data: data) else { return PKDrawing() }
        return drawing
    }
}
