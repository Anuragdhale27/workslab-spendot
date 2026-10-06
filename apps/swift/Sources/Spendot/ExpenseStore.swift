import Foundation
import SwiftUI

@MainActor
final class ExpenseStore: ObservableObject {
    @Published var state: AppState {
        didSet { save() }
    }

    private let fileURL: URL

    init() {
        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Spendot", isDirectory: true)

        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        self.fileURL = supportDir.appendingPathComponent("data.json")

        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode(AppState.self, from: data) {
            self.state = decoded
        } else {
            self.state = AppState()
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        // Recreate the folder each time: it may have been deleted while running.
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        do { try data.write(to: fileURL, options: .atomic) }
        catch { NSLog("Spendot: save failed: \(error)") }
    }

    // ---------------- derived values ----------------

    var todaysEntries: [Expense] {
        let today = todayKey()
        return state.entries.filter { $0.date == today }
    }

    var todaysTotal: Double {
        todaysEntries.reduce(0) { $0 + $1.amount }
    }

    var level: SpendLevel {
        guard state.budget > 0 else { return .green }
        let ratio = todaysTotal / state.budget
        if ratio >= 1 { return .red }
        if ratio >= state.threshold / 100 { return .amber }
        return .green
    }

    var progressFraction: Double {
        guard state.budget > 0 else { return 0 }
        return min(1, todaysTotal / state.budget)
    }

    // ---------------- actions ----------------

    func addExpense(amount: Double, label: String) {
        guard amount > 0 else { return }
        let entry = Expense(
            id: UUID(),
            amount: (amount * 100).rounded() / 100,
            label: label.trimmingCharacters(in: .whitespacesAndNewlines),
            date: todayKey(),
            createdAt: Date()
        )
        state.entries.append(entry)
    }

    func removeExpense(id: UUID) {
        state.entries.removeAll { $0.id == id }
    }

    func updateBudget(_ value: Double) {
        guard value > 0 else { return }
        state.budget = value.rounded()
    }

    func updateThreshold(_ value: Double) {
        guard value > 0, value <= 100 else { return }
        state.threshold = value.rounded()
    }

    func updateQuickAmounts(_ amounts: [Double]) {
        guard amounts.count == 4, amounts.allSatisfy({ $0 > 0 }) else { return }
        state.quickAmounts = amounts
    }

    // Call once per day, e.g. when the menu opens. Checks whether
    // yesterday finished under budget and extends the streak.
    func refreshStreak() {
        let today = todayKey()
        if state.lastStreakDate == today { return }

        let yesterday = todayKey(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        let yesterdayTotal = state.entries
            .filter { $0.date == yesterday }
            .reduce(0) { $0 + $1.amount }

        if state.lastStreakDate == yesterday, yesterdayTotal > 0, yesterdayTotal <= state.budget {
            state.streak += 1
        } else if state.lastStreakDate != nil {
            state.streak = 0
        }
        state.lastStreakDate = today
    }
}
