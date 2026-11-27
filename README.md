# InkPad 随手画

原生 SwiftUI + UIKit 混编的签名板和涂鸦 App，用 PencilKit 画画，最低支持 iOS 15。

- **作品**：作品网格，新建时选空白、横线或方格纸；点开继续画，长按删除；关掉 App 再打开还在。
- **画板**：系统工具栏（笔、马克笔、橡皮擦、套索、颜色），顶部浮动工具条可以撤销、重做、清空，显示画了几笔。
- **签名**：在签名线上写名字，导出透明背景的 PNG，存到相册或用系统面板分享。

作品保存在使用者设备的本地文件夹里（作品信息存 JSON，笔画存 PencilKit 的 `PKDrawing` 数据），不上传任何数据。

## SwiftUI 与 UIKit 怎么配合

| 方向 | 位置 | 做法 |
| --- | --- | --- |
| UIKit 里用 SwiftUI | `SceneDelegate.swift` | App 从 UIKit 启动，用 `UIHostingController` 包住 SwiftUI 的 `ContentView`，当作窗口的根控制器；`ArtworkStore` 在这里创建并注入 |
| SwiftUI 里用 UIKit | `UIKit/CanvasView.swift` | `UIViewRepresentable` 包装 PencilKit 的 `PKCanvasView`；笔画变化通过 delegate → Coordinator → 闭包回到 SwiftUI |
| UIKit 的第一响应者 | `UIKit/ToolCanvasView.swift` | 画布进入窗口后（`didMoveToWindow`）成为第一响应者，系统工具栏 `PKToolPicker` 才会显示 |
| 两边共用的状态 | `UIKit/CanvasModel.swift` | `ObservableObject`，SwiftUI 的按钮通过它调用 UIKit 画布的撤销、重做和清空 |
| SwiftUI 里用 UIKit | `UIKit/ShareSheet.swift` | `UIViewControllerRepresentable` 包装系统分享面板 `UIActivityViewController` |
| 老式 UIKit 回调 | `UIKit/PhotoSaver.swift` | `UIImageWriteToSavedPhotosAlbum` 的 target + `@objc` selector 回调 |
| UIKit 里用 SwiftUI | `UIKit/DrawingViewController.swift` | UIKit 写的画板页，纸张背景和浮动工具条是 SwiftUI 视图，用 `UIHostingController` 作为子控制器嵌进去（`addChild` → 加视图 → `didMove(toParent:)`） |
| SwiftUI 里用 UIKit | `UIKit/DrawingScreen.swift` | `UIViewControllerRepresentable` 把这个 UIKit 画板页放回 SwiftUI 的作品页 |

## 权限

| 权限 | 用途 |
| --- | --- |
| 添加照片 `NSPhotoLibraryAddUsageDescription` | 把签名和作品存到相册 |

工程用 KXBuild 的「iOS 应用（Swift · UIKit）」模板新建，去掉了 `Main.storyboard` 和 `ViewController.swift`。显示名、开发语言（简体中文）、竖屏和权限说明由构建设置生成。

## 开发环境与个人配置

工程使用 [KXBuild](https://kxbuild.net/) 开发。阅读源码和运行数据逻辑测试不需要填写作者的账号；构建、签名和真机运行时，使用者需要自行准备工具许可及适用的签名材料。

### 1. 安装工具

按 KXBuild 官网说明安装工具，并完成自己的许可配置。根目录的 `buildServer.json` 和 `AGENTS.md` 由编辑器插件生成，包含本机路径，已排除在 Git 之外；克隆项目后由自己的编辑器环境重新生成。

### 2. 配置应用标识与开发者团队

将示例复制为本机配置文件：

```powershell
Copy-Item Config/signing.example.json Config/signing.local.json
```

修改 `Config/signing.local.json` 中的 `com.example.inkpad` 和 `YOUR_TEAM_ID`，分别填写自己可用的 Bundle ID 和 Apple Developer Team ID。Debug、Release 两组配置都需要替换，并与自己的描述文件匹配。

```powershell
kxbuild project settings dump InkPad.xcodeproj --ops Config/signing.local.json --json
kxbuild project settings apply InkPad.xcodeproj --ops Config/signing.local.json --json
```

`dump --ops` 只预览不写入，`apply` 会更新本地工程文件。不要手动编辑 `project.pbxproj`。原项目标识 `so.phonegame.inkpad` 不能当成使用者自己的签名授权。

### 3. 准备自己的签名材料

在本机创建 `keychain/`，放入自己导出的 `.p12` 证书和匹配 Bundle ID 的 `.mobileprovision` 描述文件，再复制密码示例：

```powershell
New-Item -ItemType Directory -Path keychain -Force
Copy-Item Config/password.properties.example keychain/password.properties
```

编辑 `keychain/password.properties`，填写自己的证书文件名及密码。`keychain/`、本机签名配置、证书和私钥都已加入忽略规则，不要在仓库、Issue、截图或日志中公开。

### 4. 构建与真机运行

```powershell
kxbuild build InkPad.xcodeproj --json --no-ipa
kxbuild run InkPad.xcodeproj --json
```

真机运行需要使用者自己的已信任设备与开发签名。

## 代码组织

`AppDelegate.swift` 是程序入口；`SceneDelegate.swift` 创建作品存储，并用 `UIHostingController` 显示 SwiftUI 界面；`ContentView.swift` 是「作品 / 签名」两个页面的底部导航。

| 目录 | 职责 |
| --- | --- |
| `InkPad/Models` | 纸张样式 `PaperStyle`、作品信息 `Artwork` |
| `InkPad/Stores` | `ArtworkStore`：作品的新建、保存、删除和本地读写 |
| `InkPad/Services` | 导出尺寸计算 `ExportLayout`、透明 PNG 和缩略图导出 `DrawingExporter`、震动反馈 |
| `InkPad/UIKit` | PencilKit 画布、UIKit 画板页及各个 UIKit 包装 |
| `InkPad/Views/Gallery` | 作品网格和作品格子 |
| `InkPad/Views/Signature` | 签名页 |
| `InkPad/Views/Components` | 纸张背景、浮动工具条、透明格子背景等共用组件 |

`InkPad` 是同步文件夹，新增的 Swift 文件会自动纳入 target。测试代码在 target 之外。

## 视频教程

这个项目配有 B 站视频系列「随手画实战」（5 集），一步一步用 KXBuild 从新建项目做到完成。

## 验证

数据逻辑测试不构建 App，直接在 Linux / WSL 上用 Swift 运行，见 [Tests/README.md](Tests/README.md)。
