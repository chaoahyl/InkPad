import Foundation

/// 一幅作品的信息。笔画本身单独存成文件，这里只记标题、纸张和时间
struct Artwork: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var paper: PaperStyle
    let createdAt: Date
    var updatedAt: Date
    var strokeCount: Int

    init(id: UUID = UUID(), title: String, paper: PaperStyle, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.paper = paper
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.strokeCount = 0
    }
}
