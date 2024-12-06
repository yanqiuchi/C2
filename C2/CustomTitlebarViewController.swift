//
//  CustomTitlebarViewController.swift
//  C2
//
//  Created by chengxin on 2023/8/10.
//

import Cocoa

class CustomTitlebarViewController: NSTitlebarAccessoryViewController {

    override func loadView() {
        let customTitlebarView = NSView(
            frame: NSRect(x: 0, y: 0, width: 200, height: 5))
        customTitlebarView.wantsLayer = true
        customTitlebarView.layer?.backgroundColor =
            NSColor(white: 1.0, alpha: 0.8).cgColor
        self.view = customTitlebarView
    }
}
