// 在 Linux 上直接跑：python3 Tests/run_model_tests.py
// 只测不依赖 UIKit / PencilKit 的部分：作品信息、本地保存、导出尺寸计算
import Foundation

var passed = 0
var failed = 0

func check(_ condition: Bool, _ name: String, line: Int = #line) {
    if condition {
        passed += 1
    } else {
        failed += 1
        print("✗ \(name)（第 \(line) 行）")
    }
}

func tempFolder() -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("InkPadTests-\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

// MARK: - PaperStyle / Artwork

check(PaperStyle.allCases.count == 3, "三种纸张")
check(PaperStyle.blank.title == "空白" && PaperStyle.lined.title == "横线" && PaperStyle.grid.title == "方格", "纸张名称")
check(Set(PaperStyle.allCases.map(\.symbol)).count == 3, "纸张图标不重复")

let t0 = Date(timeIntervalSinceReferenceDate: 800_000_000)
let art = Artwork(title: "作品 1", paper: .grid, createdAt: t0)
check(art.updatedAt == t0 && art.strokeCount == 0, "新作品：修改时间等于创建时间，0 笔")

do {
    let data = try JSONEncoder().encode(art)
    let back = try JSONDecoder().decode(Artwork.self, from: data)
    check(back == art, "Artwork 编码再解码不变")
    check(String(data: data, encoding: .utf8)!.contains("\"paper\":\"grid\""), "纸张按名字存")
} catch {
    check(false, "Artwork 编码：\(error)")
}

// MARK: - ArtworkStore

do {
    let folder = tempFolder()
    let store = ArtworkStore(folder: folder)
    check(store.artworks.isEmpty, "空文件夹：没有作品")
    check(store.nextTitle() == "作品 1", "第一个标题")

    let a = store.create(paper: .blank, now: t0)
    let b = store.create(paper: .lined, now: t0.addingTimeInterval(10))
    let c = store.create(paper: .grid, now: t0.addingTimeInterval(20))
    check(store.artworks.map(\.title) == ["作品 3", "作品 2", "作品 1"], "新建的排在最前")
    check(store.drawingData(for: a.id) == nil, "还没画：没有笔画文件")

    store.saveDrawing(Data([1, 2, 3]), strokeCount: 7, for: a.id, now: t0.addingTimeInterval(30))
    check(store.artworks.first?.id == a.id, "刚保存的挪到最前")
    check(store.artworks.first?.strokeCount == 7, "保存笔画数")
    check(store.drawingData(for: a.id) == Data([1, 2, 3]), "笔画文件写进去了")

    store.saveDrawing(Data([9]), strokeCount: 1, for: UUID(), now: t0)
    check(store.artworks.count == 3, "保存不存在的作品：什么都不做")

    store.delete(b.id)
    check(store.artworks.map(\.id) == [a.id, c.id], "删除一个")
    check(store.nextTitle() == "作品 4", "删掉中间的不重号")

    store.saveDrawing(Data([4, 5]), strokeCount: 2, for: c.id, now: t0.addingTimeInterval(40))
    store.delete(c.id)
    check(!FileManager.default.fileExists(atPath: store.drawingURL(for: c.id).path), "删除时笔画文件也删掉")

    let reopened = ArtworkStore(folder: folder)
    check(reopened.artworks == store.artworks, "重新打开：作品还在，顺序不变")
    check(reopened.drawingData(for: a.id) == Data([1, 2, 3]), "重新打开：笔画还在")
}

do {
    let folder = tempFolder()
    try? Data("坏掉的 JSON".utf8).write(to: folder.appendingPathComponent("artworks.json"))
    check(ArtworkStore(folder: folder).artworks.isEmpty, "JSON 坏了：当成空列表，不崩溃")
}

// MARK: - ExportLayout

let padded = ExportLayout.paddedRect(CGRect(x: 10.4, y: 20.6, width: 100, height: 50), padding: 16)
check(padded == CGRect(x: -6, y: 4, width: 133, height: 83), "留白后取整：\(padded)")
check(ExportLayout.fitScale(content: CGSize(width: 480, height: 320), into: CGSize(width: 240, height: 320)) == 0.5, "宽的图按宽缩")
check(ExportLayout.fitScale(content: CGSize(width: 100, height: 640), into: CGSize(width: 240, height: 320)) == 0.5, "高的图按高缩")
check(ExportLayout.fitScale(content: CGSize(width: 50, height: 50), into: CGSize(width: 240, height: 320)) == 1, "小图不放大")
check(ExportLayout.fitScale(content: .zero, into: CGSize(width: 240, height: 320)) == 1, "空内容不除以 0")

print(failed == 0 ? "全部通过：\(passed) 项" : "失败 \(failed) 项，通过 \(passed) 项")
exit(failed == 0 ? 0 : 1)
