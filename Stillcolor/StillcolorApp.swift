//
//  StillcolorApp.swift
//  Stillcolor
//
//  Created by Abdullah Arif on 25/02/2024.
//  Modified by GMMDMDIDEMS on 12/09/2024.
//

import SwiftUI
import LaunchAtLogin

// Delegate protocol to update menu bar icon
// https://developer.apple.com/documentation/swift/using-delegates-to-customize-object-behavior
protocol AppStateDelegate: AnyObject {
    func updateStatusItemImage()
}

// Singleton for managing application-wide state
// https://developer.apple.com/documentation/swift/managing-a-shared-resource-using-a-singleton
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var disableDithering: Bool {
        didSet {
            UserDefaults.standard.set(disableDithering, forKey: "disableDithering")
            Stillcolor.enableDisableDithering(disableDithering)
            // Update menu bar icon
            delegate?.updateStatusItemImage()
        }
    }
    
    @Published var disableUniformity2D: Bool {
        didSet {
            UserDefaults.standard.set(disableUniformity2D, forKey: "disableUniformity2D")
            Stillcolor.enableDisableUniformity2D(disableUniformity2D)
        }
    }
    
    weak var delegate: AppStateDelegate?
    
    private init() {
        self.disableDithering = UserDefaults.standard.bool(forKey: "disableDithering")
        self.disableUniformity2D = UserDefaults.standard.bool(forKey: "disableUniformity2D")
    }
}

@main
struct StillcolorApp: App {
    var detector = ScreenDetector()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        detector.addObservers()
        Stillcolor.enableDisableDithering(AppState.shared.disableDithering)
        Stillcolor.enableDisableUniformity2D(AppState.shared.disableUniformity2D)
        AppState.shared.delegate = appDelegate
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// https://developer.apple.com/documentation/swift/using-delegates-to-customize-object-behavior
class AppDelegate: NSObject, NSApplicationDelegate, AppStateDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemImage()
        constructMenu()
    }
    
    func updateStatusItemImage() {
        if let button = statusItem?.button {
            let imageName = AppState.shared.disableDithering ? "livephoto.slash" : "livephoto"
            button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        }
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        
        let menuItem = NSMenuItem()
        let hostingView = NSHostingController(rootView: MenuView())
        // Change width to 295 to improve item alignment
        hostingView.view.frame = NSRect(x: 0, y: 0, width: 295, height: 110)
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
    @ObservedObject var appState = AppState.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $appState.disableDithering) {
                Text("Disable Dithering")
            }
            
            Toggle(isOn: $appState.disableUniformity2D) {
                Text("Disable Uniformity2D")
            }
            
            Text("(Experimental) Stop built-in display from using lower brightness levels around the edges")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, -6) // reduce vertical space
                .padding(.leading, 20)
            
            Divider()
            
            LaunchAtLogin.Toggle()
        }
        .padding()
        .frame(width: 300)
    }
}
