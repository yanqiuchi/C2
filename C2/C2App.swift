//
//  C2App.swift
//  C2
//
//  Created by chengxin on 2023/8/10.
//

import SwiftUI
import UserNotifications

@main
struct C2App: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate,
    UNUserNotificationCenterDelegate
{

    var configWindow: NSWindow?

    var statusBar: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        updateStatusBarMenu()
        requestNotificationPermission()
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateStatusBarMenu),
            name: Notification.Name("UpdateStatusBarNotification"), object: nil)
        UNUserNotificationCenter.current().delegate = self
    }

    @objc func updateStatusBarMenu() {
        let items = DataManager.shared.loadItems() ?? []

        let menu = NSMenu()

        // 对于每个 G2FAItem，创建一个新的菜单项并为其添加点击事件
        for item in items {
            let menuItem = NSMenuItem(
                title: item.label, action: #selector(labelMenuItemClicked(_:)),
                keyEquivalent: "")
            menuItem.representedObject = item
            menu.addItem(menuItem)
        }

        // 添加 Config 和 Exit 菜单项
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "Config", action: #selector(showConfig),
            keyEquivalent: "")
        menu.addItem(
            withTitle: "Exit", action: #selector(exitApp), keyEquivalent: "")

        statusBar?.menu = menu
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            if granted {
                print("Notification Permission Granted")
            } else {
                print("Notification Permission Denied")
            }
        }
    }

    func setupStatusBar() {
        statusBar = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength)
        if let button = statusBar?.button {
            button.image = NSImage(named: "loadingTemplate")
            let menu = NSMenu()
            menu.addItem(
                withTitle: "Config", action: #selector(showConfig),
                keyEquivalent: "")
            menu.addItem(
                withTitle: "Exit", action: #selector(exitApp), keyEquivalent: ""
            )
            statusBar?.menu = menu
        }
    }

    func windowDidResize(_ notification: Notification) {
        if let customWindow = notification.object as? CustomWindow {
            customWindow.updateTitlebarTrackingArea()
        }
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == configWindow
        {
            configWindow = nil
        }
    }

    @objc func showConfig() {
        if let existingWindow = configWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        configWindow = CustomWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configWindow?.delegate = self
        configWindow?.isReleasedWhenClosed = false
        configWindow?.center()
        configWindow?.setFrameAutosaveName("Config Window")
        configWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func labelMenuItemClicked(_ sender: NSMenuItem) {
        if let item = sender.representedObject as? G2FAItem {
            let code = DataManager.shared.getCode(secret: item.secret)
            print("Generated code for \(item.label): \(code)")

            // Copy code to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(code, forType: .string)
            // Send out a system notification
            sendNotification(
                with: "Code Generated",
                body: "Code for \(item.label) has been copied to clipboard.")
        }
    }

    func sendNotification(with title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }

    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
