//
//  LoginAccountTextField.swift
//  qq
//
//  Created by hezhiqiang on 2018/4/30.
//  Copyright © 2018年 Totorotec. All rights reserved.
//

import Cocoa

class LoginAccountTextField: NSTextField, NSTextFieldDelegate {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.delegate = self
//        self.placeholderString = NSLocalizedString("account_placeholder", comment: "")
    }
    
    override func mouseDown(with event: NSEvent) {
        self.currentEditor()?.selectAll(nil)
        self.placeholderString = ""
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.placeholderString = Constants.accountPlaceHolder
    }
}
