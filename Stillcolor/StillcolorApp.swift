//
//  StillcolorApp.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 25/02/2024.
//  Modified by GMMDMDIDEMS on 12/09/2024.
//

import SwiftUI
import LaunchAtLogin

@main
struct StillcolorApp: App {
    @AppStorage("disableDithering") var disableDithering: Bool = true
    @AppStorage("disableUniformity2D") var disableUniformity2D: Bool = false
    
    var detector = ScreenDetector();
    var statusBarItem: NSStatusItem?
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        detector.addObservers()
        Stillcolor.enableDisableDithering(disableDithering)
        Stillcolor.enableDisableUniformity2D(disableUniformity2D)
    }
    
    var body: some Scene {
        Settings{
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    @AppStorage("disableDithering") var disableDithering: Bool = true

    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: disableDithering ? "livephoto.slash" : "livephoto", accessibilityDescription: nil)
        }

        constructMenu()
    }

    private func constructMenu() {
        let menu = NSMenu()

        let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        let hostingView = NSHostingController(rootView: MenuView())
        hostingView.view.frame = NSRect(x: 0, y: 0, width: 300, height: 125)
        menuItem.view = hostingView.view

        menu.addItem(menuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Stillcolor", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

struct MenuView: View {
    @AppStorage("disableDithering") var disableDithering: Bool = true
    @AppStorage("disableUniformity2D") var disableUniformity2D: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $disableDithering) {
                Text("Disable Dithering")
            }
            .onChange(of: disableDithering) { newValue in
                Stillcolor.enableDisableDithering(newValue)
            }

            Toggle(isOn: $disableUniformity2D) {
                Text("Disable uniformity2D")
            }
            .onChange(of: disableUniformity2D) { newValue in
                Stillcolor.enableDisableUniformity2D(newValue)
            }

            Text("(Experimental) Stop built-in display from using lower brightness levels around the edges")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 20)

            Divider()

            LaunchAtLogin.Toggle()
        }
        .padding()
        .frame(width: 300)
    }
}
