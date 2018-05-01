import Cocoa

class StatusButton: NSButton {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.cornerRadius = dirtyRect.width / 2
    }
}
