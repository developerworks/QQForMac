import Cocoa

protocol LoginUserItemDelegate {
    func loginUserItem(_ item: LoginUserItem, with sender: NSButton)
}

class LoginUserItem: NSCollectionViewItem {
    // CollectionView中的图片按钮
    @IBOutlet weak var imageButton: LoginImageButton!
    @IBOutlet weak var closeButton: NSButton!
    
    var delegate: LoginUserItemDelegate?
    
    // 用户模型
    // 初始化的时候给图片按钮设置图片
    var model: LoginUserItemModel! {
        didSet {
            imageButton.image = NSImage(named: NSImage.Name(model.avatarName))
        }
    }
    
    typealias UserBlock = (_ sender: Any) -> Void
    var block: UserBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [
            .activeInActiveApp, .mouseEnteredAndExited], owner: self, userInfo: nil
        )
        view.addTrackingArea(trackingArea)
    }
    
    @IBAction func onClickLoginImageButton(_ sender: LoginImageButton) {
        if let b = block{
            b(sender)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: NSButton) {
        if let delegate = self.delegate {
            delegate.loginUserItem(self, with: sender)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        self.closeButton.isHidden = false
    }
    override func mouseExited(with event: NSEvent) {
        self.closeButton.isHidden = true
    }
}
