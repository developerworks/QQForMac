import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var accountTextField: LoginAccountTextField!
    @IBOutlet weak var passwordTextField: LoginPasswordTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var IconArrowButton: IconArrowButton!

    // MARK: 子窗口相对父窗口在Y轴上的偏移量
    var currentOffsetY: CGFloat = 0
    let animateDuration: TimeInterval = 0.25
    var audioPlayer: AVAudioPlayer!

    // 子窗口延迟初始化
    lazy var optionsWindow: NSWindow = {
        // 定位
        let window = NSWindow(
            contentRect: self.makeRect(offsetY: self.currentOffsetY, h: 100),
            styleMask: .titled,
            backing: NSWindow.BackingStoreType.buffered,
            defer: true
        )
        window.hasShadow = false
        // 设置内容
        window.contentViewController = NSStoryboard(name: NSStoryboard.Name.init("Main"), bundle: nil)
            .instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier.init(rawValue: "optionsViewController")
            ) as! OptionsViewController
        return window
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "settingViewSound", withExtension: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
            // 播放
//            audioPlayer.play()
        } catch let error as NSError {
            print(error.debugDescription)
        }
        // MARK: 监听账号和密码的输入过程, 检测是否为空, 用于修改登录箭头按钮的状态
        NotificationCenter.default.addObserver(
            forName: NSText.didChangeNotification,
            object: nil, queue: OperationQueue.main
        ) { (notification) in
            if !self.accountTextField.stringValue.isEmpty, !self.passwordTextField.stringValue.isEmpty {
                self.loginButton.isEnabled = true
            } else {
                self.loginButton.isEnabled = false
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.registerObservers()
    }
    
    private func registerObservers() {
        // MARK: 当父窗口移动的时候, 更新子窗口的坐标位置
        //        NotificationCenter.default.addObserver(
        //            forName: NSWindow.willMoveNotification, object: nil, queue: OperationQueue.main
        //        ) { (notification) in
        //            self.optionsWindow.animator()
        //                .setFrame(self.makeRect(offsetY: self.currentOffsetY), display: true)
        //            self.view.window?.animator()
        //                .addChildWindow(self.optionsWindow, ordered: NSWindow.OrderingMode.below)
        //        }
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.changeChildWindowPos(notification:)),
            name: NSWindow.willMoveNotification, object: nil
        )
    }

    @objc func changeChildWindowPos(notification: Notification) {
        self.optionsWindow.animator()
            .setFrame(self.makeRect(offsetY: self.currentOffsetY), display: true)
        self.view.window?.animator()
            .addChildWindow(self.optionsWindow, ordered: NSWindow.OrderingMode.below)
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    private func makeRect(_ offsetY: CGFloat, h: CGFloat = 100) -> NSRect {
        self.currentOffsetY = offsetY
        return NSMakeRect(
            (self.view.window?.frame.origin.x)!,
            (self.view.window?.frame.origin.y)! + offsetY,
            (self.view.window?.frame.size.width)!,
            100
        )
    }

    private func makeRect(offsetY: CGFloat, h: CGFloat = 100) -> NSRect {
        self.currentOffsetY = offsetY
        return makeRect(offsetY, h: h)
    }


    // MARK: 终止应用程序
    @IBAction func terminate(_ sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }

    // MARK: 登录
    @IBAction func handleLogin(_ sender: NSButton) {
    }

    // MARK: 登录选项
    // TODO: 1. 下拉后显示阴影, 2. 上拉前首先消除阴影
    @IBAction func openOrCloseLoginOptions(_ sender: IconArrowButton) {
        audioPlayer.play()
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = self.animateDuration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            if sender.state == .on {
                self.optionsWindow.animator().setFrame(self.makeRect(offsetY: -78), display: true)
                // 添加到父窗口
                self.view.window?.animator().addChildWindow(self.optionsWindow, ordered: .below)
            } else {
                // 设置子窗口的位置, 并从父窗口中删除
                self.optionsWindow.hasShadow = false
                self.optionsWindow.animator().setFrame(self.makeRect(offsetY: 22), display: false)
                self.view.window?.animator().removeChildWindow(self.optionsWindow)
            }
        }) {
            if sender.state == .on {
                self.optionsWindow.hasShadow = true
            }
        }
    }
}
