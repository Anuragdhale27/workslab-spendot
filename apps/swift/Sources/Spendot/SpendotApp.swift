import SwiftUI

@main
struct SpendotApp: App {
    @StateObject private var store = ExpenseStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
        } label: {
            StatusDotView(level: store.level, size: 12)
        }
        .menuBarExtraStyle(.window)
    }
}
