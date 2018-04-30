import Cocoa

class IconArrowButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(trackingArea)
        self.self.image = NSImage(named: NSImage.Name("Icon-arrow-normal"))
    }

    override func mouseEntered(with event: NSEvent) {
        
        self.image = NSImage(named: NSImage.Name("Icon-arrow-hover"))
    }

    override func mouseExited(with event: NSEvent) {
        
        self.image = NSImage(named: NSImage.Name("Icon-arrow-normal"))
        
    }
}
