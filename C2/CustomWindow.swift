//
//  CustomWindow.swift
//  C2
//
//  Created by chengxin on 2023/8/10.
//

import Cocoa
import SwiftUI

class CustomWindow: NSWindow {
    
    var titlebarTrackingArea: NSTrackingArea?
    
    private var contentLayoutRectObservation: NSKeyValueObservation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupWindow()
    }
    
    func setupVisualEffectBackground() {
        self.contentView?.subviews.forEach { $0.removeFromSuperview() }
        let visualEffectView = NSVisualEffectView(frame: self.contentView!.bounds)
        visualEffectView.material = .popover
        visualEffectView.state = .active
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.alphaValue = 0.8
        self.contentView?.addSubview(visualEffectView)
        let hostingView = NSHostingView(rootView: ConfigView())
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(hostingView)
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.setupWindow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWindow() {
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        self.backgroundColor = NSColor.clear
        updateTitlebarTrackingArea()
        setupVisualEffectBackground()
        hideButtons()
    }
    
    func adjustTitlebarOpacityLater(_ opacity: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.adjustTitlebarOpacity(opacity)
        }
    }
    
    func adjustTitlebarOpacity(_ opacity: CGFloat) {
        if let titlebarView = standardWindowButton(.closeButton)?.superview?.superview as? NSVisualEffectView {
            titlebarView.alphaValue = opacity
        }
    }
    
    func updateTitlebarTrackingArea() {
        guard let titlebarContainerView = standardWindowButton(.closeButton)?.superview else { return }
        
        if let existingArea = titlebarTrackingArea {
            titlebarContainerView.removeTrackingArea(existingArea)
        }
        
        titlebarTrackingArea = NSTrackingArea(rect: titlebarContainerView.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        titlebarContainerView.addTrackingArea(titlebarTrackingArea!)
    }
    
    func setupTitlebarTrackingArea() {
        guard let titlebarContainerView = standardWindowButton(.closeButton)?.superview else { return }
        titlebarTrackingArea = NSTrackingArea(rect: titlebarContainerView.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        titlebarContainerView.addTrackingArea(titlebarTrackingArea!)
    }
    
    func hideButtons() {
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    func showButtons() {
        standardWindowButton(.closeButton)?.isHidden = false
        standardWindowButton(.miniaturizeButton)?.isHidden = false
        standardWindowButton(.zoomButton)?.isHidden = false
    }
    
    override func mouseEntered(with event: NSEvent) {
        showButtons()
    }
    
    override func mouseExited(with event: NSEvent) {
        hideButtons()
    }
}
