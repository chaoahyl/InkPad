import Combine
import Foundation

/// 作品列表和本地保存：信息存成一个 JSON，每幅画的笔画存成一个 .drawing 文件
final class ArtworkStore: ObservableObject {
    @Published private(set) var artworks: [Artwork] = []

    private let folder: URL
    private var indexURL: URL { folder.appendingPathComponent("artworks.json") }

    init(folder: URL? = nil) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.folder = folder ?? documents.appendingPathComponent("Artworks", isDirectory: true)
        try? FileManager.default.createDirectory(at: self.folder, withIntermediateDirectories: true)
        load()
    }

    func drawingURL(for id: UUID) -> URL {
        folder.appendingPathComponent("\(id.uuidString).drawing")
    }

    /// 新建一幅空白作品，排在最前面
    @discardableResult
    func create(paper: PaperStyle, now: Date = Date()) -> Artwork {
        let artwork = Artwork(title: nextTitle(), paper: paper, createdAt: now)
        artworks.insert(artwork, at: 0)
        saveIndex()
        return artwork
    }

    func drawingData(for id: UUID) -> Data? {
        try? Data(contentsOf: drawingURL(for: id))
    }

    /// 保存笔画。刚改过的作品挪到最前面
    func saveDrawing(_ data: Data, strokeCount: Int, for id: UUID, now: Date = Date()) {
        guard let index = artworks.firstIndex(where: { $0.id == id }) else { return }
        try? data.write(to: drawingURL(for: id), options: .atomic)
        var artwork = artworks.remove(at: index)
        artwork.updatedAt = now
        artwork.strokeCount = strokeCount
        artworks.insert(artwork, at: 0)
        saveIndex()
    }

    func delete(_ id: UUID) {
        artworks.removeAll { $0.id == id }
        try? FileManager.default.removeItem(at: drawingURL(for: id))
        saveIndex()
    }

    /// “作品 1”“作品 2”……删掉中间的也不会重号
    func nextTitle() -> String {
        let numbers = artworks.compactMap { Int($0.title.replacingOccurrences(of: "作品 ", with: "")) }
        return "作品 \((numbers.max() ?? 0) + 1)"
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let list = try? JSONDecoder().decode([Artwork].self, from: data) else { return }
        artworks = list.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func saveIndex() {
        guard let data = try? JSONEncoder().encode(artworks) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }
}
