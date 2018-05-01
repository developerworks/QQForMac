import Cocoa

//import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var accountTextField: LoginAccountTextField!
    @IBOutlet weak var passwordTextField: LoginPasswordTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var iconArrowButton: IconArrowButton!
    @IBOutlet weak var qrViewButton: NSButton!
    @IBOutlet weak var qrCodeRefresher: NSImageView!
    @IBOutlet weak var collectionView: NSCollectionView!
    // 扫码登录
    @IBOutlet var loginQrView: NSView!
    // MARK: 子窗口相对父窗口在Y轴上的偏移量
    var currentOffsetY: CGFloat = 10
    let animateDuration: TimeInterval = 0.28
    //    var audioPlayer: AVAudioPlayer!
    var sound: NSSound!
    // 用户账号图标原始位置
    var originalPos: NSRect! = nil
    var targetPos: NSRect!
    // 用于过渡动画的临时 LoginImageButton 对象
    lazy var transitionItem: LoginImageButton = {
        let button = LoginImageButton()
        button.target = self
        button.action = #selector(self.handleTransition(button:))
        button.isBordered = false
        return button
    }()
    // 用户头像图片名称
//    var users = [
//        "avatar",
////        "avatar01",
////        "avatar02",
////        "avatar03",
//        "avatar04",
//    ]
    var users = Array<LoginUserItemModel>()

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
        window.contentViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            .instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "optionsViewController")
            ) as! OptionsViewController
        window.backgroundColor = .white
        return window
    }()

    var transitionItemIsAdded: Bool = false
    
    var statusBtn: StatusButton = {
        let button = StatusButton()
        button.image = #imageLiteral(resourceName: "point-online-normal")
        return button
    }()

    // MARK: 视图初始化
    //////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initResources()
        self.registerObservers()
        self.setLayerAttributes()
        qrCodeRefresher.isHidden = true
        self.initClassMembers()

    }

    // MARK: 初始化资源
    private func initResources() {
        sound = NSSound(named: NSSound.Name("settingViewSound.wav"))!
        //        if false {
        //            let url = Bundle.main.url(forResource: "settingViewSound", withExtension: "wav")
        //            do {
        //                audioPlayer = try AVAudioPlayer(contentsOf: url!)
        //                audioPlayer.prepareToPlay()
        //                // 播放
        //                //            audioPlayer.play()
        //            } catch let error as NSError {
        //                print(error.debugDescription)
        //            }
        //        }
        // 注册 LoginUserItem
        self.collectionView.register(
            NSNib.init(nibNamed: NSNib.Name.init(rawValue: "LoginUserItem"), bundle: nil),
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("LoginUserItem")
        )
    }

    // MARK: 初始化类成员
    private func initClassMembers() {
        self.targetPos = NSMakeRect(self.view.frame.width / 2, 0, 100, 100)
        //        self.users = [
        //            LoginUserItemModel(avatarName: "avatar"),
        //            LoginUserItemModel(avatarName: "avatar04")
        //        ]
        let names = [
            "avatar",
            "avatar04"
        ]
        for name in names {
            self.users.append(LoginUserItemModel(avatarName: name))
        }
    }

    // MARK: 设置各种View的属性
    private func setLayerAttributes() {
        self.view.layer?.shadowRadius = 1 // HALF of blur
        self.view.layer?.shadowOffset = CGSize(width: 0, height: 2) // Spread x, y
        self.view.layer?.masksToBounds = false
        self.loginQrView.wantsLayer = true
        self.loginQrView.layer?.backgroundColor = NSColor.white.cgColor
    }

    // MARK: 视图准备显示
    override func viewWillAppear() {
        super.viewWillAppear()
        var indexPath = IndexPath(item: 0, section: 0)
        let firstItem = collectionView.item(at: indexPath)
        self.originalPos = self.view.convert((firstItem?.view.frame)!, from: self.collectionView)
        //        self.transitionItem.frame = self.originalPos
        self.transitionItem.image = NSImage(named: NSImage.Name(self.users[indexPath.item].avatarName))
        self.transitionItem.imageScaling = .scaleProportionallyDown
        self.transitionItem.frame = self.view.convert(self.targetPos, to: self.collectionView)
        self.collectionView.isHidden = true
        self.view.addSubview(self.transitionItem)

    }

    // MARK: 视图已显示
    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func registerObservers() {
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
        // MARK: 当父窗口移动的时候, 更新子窗口的坐标位置
        NotificationCenter.default.addObserver(
            forName: NSWindow.willMoveNotification, object: nil, queue: OperationQueue.main
        ) { (notification) in
            if self.iconArrowButton.state == .off {
                self.optionsWindow.animator().setFrame(self.makeRect(offsetY: self.currentOffsetY), display: true)
                self.view.window?.animator().addChildWindow(self.optionsWindow, ordered: NSWindow.OrderingMode.below)
            }
        }
        //        NotificationCenter.default.addObserver(
        //            self, selector: #selector(self.changeChildWindowPos(notification:)),
        //            name: NSWindow.willMoveNotification, object: nil
        //        )
    }

    @objc func changeChildWindowPos(notification: Notification) {
        self.optionsWindow.animator().setFrame(self.makeRect(offsetY: self.currentOffsetY), display: true)
        self.view.window?.animator().addChildWindow(self.optionsWindow, ordered: NSWindow.OrderingMode.below)
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
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = self.animateDuration
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            if sender.state == .on {
                self.optionsWindow.animator().setFrame(self.makeRect(offsetY: -75), display: true)
                // 添加到父窗口
                self.view.window?.animator().addChildWindow(self.optionsWindow, ordered: .below)
            } else {
                // 设置子窗口的位置, 并从父窗口中删除
                self.optionsWindow.animator().setFrame(self.makeRect(offsetY: 22), display: false)
                self.view.window?.animator().removeChildWindow(self.optionsWindow)
                self.optionsWindow.hasShadow = false
            }
        }) {
            if sender.state == .on {
                self.optionsWindow.hasShadow = true
            }
            self.sound.play()
            //            self.audioPlayer.play()
        }
    }

    @IBAction func openQrcodeLoginView(_ sender: NSButton) {
        sender.isHidden = true
        // 把二维码识图添加到窗口
        view.addSubview(self.loginQrView)
    }

    @IBAction func backToLogin(_ sender: NSButton) {
        qrViewButton.isHidden = false
        loginQrView.removeFromSuperview()
    }

    // MARK: 点击 LoginUserItem 放大
    func handleItem(_ item: LoginUserItem, with indexPath: IndexPath) {
        self.originalPos = self.view.convert(item.view.frame, from: collectionView)
        // 把 LoginUserItem 复制给临时的用于动画的过渡 LoginUserItem
        self.transitionItem.frame = self.originalPos
        // 动态设置图片
        self.transitionItem.image = NSImage(named: NSImage.Name(users[indexPath.item].avatarName))
        // 隐藏CollectionView
        self.collectionView.isHidden = true
        self.transitionItem.isHidden = false
        // 把过渡 LoginImageButton 添加到 View 中
        if self.transitionItemIsAdded == false {
            self.view.addSubview(self.transitionItem)
            self.transitionItemIsAdded = true
        }
        // 运行动画
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            self.transitionItem.animator().frame = self.view.convert(self.targetPos, to: self.collectionView)
        }, completionHandler: {
        })
    }

    // MARK: 缩小
    @objc func handleTransition(button: LoginImageButton) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            self.transitionItem.animator().frame = self.originalPos
        }, completionHandler: {
            self.transitionItem.isHidden = true
            //            self.transitionItem.removeFromSuperview()
            self.collectionView.isHidden = false
        })
    }
}

// FIXME: 实现 NSCollectionViewDataSource
extension ViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("LoginUserItem"), for: indexPath
            ) as! LoginUserItem
        item.model = self.users[indexPath.item]
        item.block = { (sender) -> Void in
            self.handleItem(item, with: indexPath)
        }
        item.delegate = self
        return item
    }
}


extension ViewController: LoginUserItemDelegate {
    private func addItem(_ item: LoginUserItem) {
        let pos = IndexPath(item: self.users.count - 1 , section: 0)
        collectionView.insertItems(at: [pos])
    }
    private func deleteItem(_ item: LoginUserItem) {
        // 获取Item的IndexPath
        // 通过IndexPath删除一个Item
        let indexPath = collectionView.indexPath(for: item)
        self.users.remove(at: (indexPath?.item)!)
        collectionView.deleteItems(at: [indexPath!])
    }
    func loginUserItem(_ item: LoginUserItem, with sender: NSButton) {
        self.deleteItem(item)
        collectionView.reloadData()
    }
}



