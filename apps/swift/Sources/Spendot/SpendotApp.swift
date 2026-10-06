import SwiftUI
import AppKit

// MenuBarExtra snapshots its label to a static image, so animated/blended
// views render blank. Draw a plain, non-template colored dot instead.
private func menuBarDot(_ level: SpendLevel) -> NSImage {
    let img = NSImage(size: NSSize(width: 14, height: 14), flipped: false) { rect in
        NSColor(level.color).setFill()
        NSBezierPath(ovalIn: rect.insetBy(dx: 2, dy: 2)).fill()
        return true
    }
    img.isTemplate = false
    return img
}

@main
struct SpendotApp: App {
    @StateObject private var store = ExpenseStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
        } label: {
            Image(nsImage: menuBarDot(store.level))
        }
        .menuBarExtraStyle(.window)
    }
}
