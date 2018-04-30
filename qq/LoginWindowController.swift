import Cocoa

class LoginWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        // 隐藏窗口按钮
        self.window?.standardWindowButton(.closeButton)?.isHidden = true
        self.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true
        // 背景可拖动
        self.window?.isMovableByWindowBackground = true
        // 背景色
        self.window?.backgroundColor = .white
    }
}
