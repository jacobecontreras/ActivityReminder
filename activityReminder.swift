import AppKit
import Foundation

class ReminderApp: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var timer: Timer?
    var remainingSeconds: Int = 0
    var activeInterval: TimeInterval?
    
    let intervals: [(label: String, seconds: TimeInterval)] = [
        ("15 min", 15 * 60),
        ("30 min", 30 * 60),
        ("45 min", 45 * 60),
        ("1 hr", 60 * 60),
        ("1.5 hr", 90 * 60),
        ("2 hr", 120 * 60),
        ("4 hr", 240 * 60)
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Uses variable length to let status bar item size itself
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateButton(title: nil)
        constructMenu()
    }

    func updateButton(title: String?) {
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Reminder")
            button.imagePosition = .imageLeading // Ensure image on the left of the countdown
            if let title = title {
                button.title = title
            } else {
                button.title = ""
            }
        }
    }

    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Set Interval:", action: nil, keyEquivalent: ""))
        
        for interval in intervals {
            let item = NSMenuItem(title: interval.label, action: #selector(setInterval(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = interval.seconds
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let stopItem = NSMenuItem(title: "Stop Timer", action: #selector(stopTimer), keyEquivalent: "s")
        stopItem.target = self
        menu.addItem(stopItem)
        
        let testItem = NSMenuItem(title: "Test Popup", action: #selector(triggerAlert), keyEquivalent: "t")
        testItem.target = self
        menu.addItem(testItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
    }

    @objc func setInterval(_ sender: NSMenuItem) {
        guard let seconds = sender.representedObject as? TimeInterval else { return }
        
        stopTimer()
        activeInterval = seconds
        remainingSeconds = Int(seconds)
        
        // Update menu checkmarks
        for item in statusBarItem.menu?.items ?? [] {
            item.state = (item == sender) ? .on : .off
        }
        
        startTimer()
        print("Timer set for \(sender.title)")
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func tick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateButton(title: formatTime(seconds: remainingSeconds))
        } else {
            triggerAlert()
            if let interval = activeInterval {
                remainingSeconds = Int(interval) // Reset for repeat
            }
        }
    }

    func formatTime(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }

    @objc func stopTimer() {
        timer?.invalidate()
        timer = nil
        remainingSeconds = 0
        activeInterval = nil
        updateButton(title: nil)
        
        // Clear checkmarks
        for item in statusBarItem.menu?.items ?? [] {
            item.state = .off
        }
        print("Timer stopped")
    }

    @objc func triggerAlert() {
        DispatchQueue.main.async {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 180),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            
            window.title = "Activity Reminder"
            window.center()
            window.level = .floating
            window.isReleasedWhenClosed = false
            
            let container = NSView(frame: window.contentView!.bounds)
            
            let label = NSTextField(labelWithString: "Time to take a break or move around!")
            label.font = NSFont.systemFont(ofSize: 16, weight: .regular)
            label.alignment = .center
            label.frame = NSRect(x: 20, y: 85, width: 310, height: 50)
            
            let button = NSButton(title: "OK", target: self, action: #selector(self.dismissAlert(_:)))
            button.frame = NSRect(x: 125, y: 30, width: 100, height: 32)
            button.bezelStyle = .rounded
            button.keyEquivalent = "\r"
            button.tag = 100
            
            container.addSubview(label)
            container.addSubview(button)
            window.contentView = container
            
            NSApp.activate(ignoringOtherApps: true)
            NSApp.runModal(for: window)
            window.close()
        }
    }

    @objc func dismissAlert(_ sender: NSButton) {
        NSApp.stopModal()
    }
}

// Global setup to run as a script
let app = NSApplication.shared
let delegate = ReminderApp()
app.delegate = delegate
app.run()
