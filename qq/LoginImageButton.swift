import Cocoa

class LoginImageButton: NSButton {
    let mouseEnteredColor = NSColor(red: 0.44, green: 0.84, blue: 0.95, alpha: 1.0)
    let mouseLeavedColor = NSColor(red: 113 / 255, green: 203 / 255, blue: 243 / 255, alpha: 1.0)
    let defaultColor = NSColor(red: 0.72, green: 0.75, blue: 0.77, alpha: 1.0)
    let borderWidth: CGFloat = 1
    let mouseEnteredWidth: CGFloat = 2

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        layer?.cornerRadius = dirtyRect.width / 2
        imageScaling = .scaleProportionallyDown
        let trackingArea = NSTrackingArea(rect: self.bounds, options: [
            .mouseEnteredAndExited,
            .activeInActiveApp
        ], owner: self, userInfo: nil)
        
        self.addTrackingArea(trackingArea)
        
        changeColor(color: defaultColor, with: borderWidth)
    }

    // FIXME: 判断鼠标是否在跟踪区内, 如果在, 就不修改颜色, 如果不在则修改
    override func mouseEntered(with event: NSEvent) {
        changeColor(color: mouseEnteredColor, with: mouseEnteredWidth)
    }

    override func mouseExited(with event: NSEvent) {
        changeColor(color: defaultColor, with: borderWidth)
    }

    func changeColor(color: NSColor, with width: CGFloat) {
        layer?.borderColor = color.cgColor
        layer?.borderWidth = width
    }
}
