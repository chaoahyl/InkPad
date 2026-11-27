# 数据逻辑测试

不构建、安装或启动 iOS App。测试脚本把 `InkPad/Models`、`InkPad/Stores` 和 `Services/ExportLayout.swift` 的源文件拼在一起，临时去掉 Linux 上没有的 Combine（`import Combine`、`ObservableObject`、`@Published`），再接上 `ModelTests.swift`，用 Swift Foundation 执行 25 项检查。测的是正式代码本身，临时文件在结束后清理。

安装了 Swift 的环境：

```powershell
python Tests/run_model_tests.py
```

使用已有的 Ubuntu WSL Swift 工具链：

```powershell
python Tests/run_model_tests.py --wsl Ubuntu
```

覆盖：

- **纸张和作品信息**：三种纸张的名称和图标、新作品的默认值、`Artwork` 编码再解码不变、纸张按名字存。
- **作品保存**：新建的排在最前、标题编号、保存笔画数和笔画文件、保存后挪到最前、删除时笔画文件一起删、重新打开后作品和笔画都还在、JSON 损坏时当成空列表不崩溃。
- **导出尺寸**：笔画范围加留白后取整、按宽或按高缩放、小图不放大、空内容不除以 0。

画布、工具栏、相册、分享面板和页面交互需要在真机上验证。

## KXBuild 工具链的头文件目录

KXBuild 的 Linux Swift 工具链把 `os`、`dispatch` 等头文件目录改名为 `os_org`、`dispatch_org`（编 iOS App 时改用苹果 SDK 的头文件）。在 Linux / WSL 上直接运行 `python3 Tests/run_model_tests.py` 时，脚本会发现这些 `*_org` 目录，在本次测试的临时目录里建好同名软链接并自动加上 `-Xcc -I`，不修改工具链原文件。其他 Swift 工具链没有这些目录，脚本不做任何处理。
