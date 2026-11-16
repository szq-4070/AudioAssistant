# AudioAssistant 0.1.0

这是第一版可见界面验证工程：在目标 App 中添加“音频工具”悬浮入口，点击后打开 UIKit 页面；三个按钮会弹出占位提示，不会修改抖音原有录音或发送逻辑。

## 目标信息
- Bundle ID: `com.ss.iphone.ugc.Aweme`
- 主程序: `Aweme`
- 抖音版本: 40.8.0（用户提供）
- 最低部署目标暂设 iOS 15.0；实际编译 SDK 由 Theos 环境决定。

## 构建
需要安装 Theos、iOS SDK 和 clang 工具链。在 macOS/Linux Theos 环境中：
```sh
make clean package
```
生成的 deb 位于 `packages/`。提取其中的 `AudioAssistant.dylib` 和同名 plist，再通过 ESign 注入目标 IPA 并重新签名。

## 重要说明
- 这份源码尚未在用户设备或其目标 Theos 环境中编译验证。
- 本版本仅验证 Dylib 加载、入口显示、页面展示和按钮响应。
- 不包含本地文件选择、音频播放、音频编码或抖音消息发送。
- 如果入口未显示，优先查看注入是否成功、Dylib 是否进入主程序进程，以及设备系统版本与构建 SDK 的兼容性。
