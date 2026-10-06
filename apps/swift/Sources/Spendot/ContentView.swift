import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ExpenseStore
    @State private var amountText = ""
    @State private var labelText = ""
    @State private var showError = false
    @State private var showSettings = false

    var body: some View {
        Group {
            if showSettings {
                SettingsView(showSettings: $showSettings)
            } else {
                mainView
            }
        }
        .frame(width: 340)
        .padding(18)
        .onAppear { store.refreshStreak() }
    }

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                HStack(spacing: 8) {
                    StatusDotView(level: store.level, size: 10)
                    Text("Spend Dot")
                        .font(.system(size: 15, weight: .semibold))
                }
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            badge

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(formatMoney(store.todaysTotal))
                    .font(.system(size: 28, weight: .bold))
                Text("spent")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("of \(formatMoney(store.state.budget)) daily budget")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            progressBar

            quickAddRow

            addForm

            Text("today's expenses")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)

            entriesList

            HStack {
                if store.state.streak > 0 {
                    Text("🔥 \(store.state.streak) day streak")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .keyboardShortcut("q")
            }
            .padding(.top, 4)
        }
    }

    private var badge: some View {
        HStack(spacing: 6) {
            Circle().fill(store.level.color).frame(width: 6, height: 6)
            Text(store.level.label)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(store.level.color.opacity(0.15))
        .foregroundStyle(store.level.color)
        .clipShape(Capsule())
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.06))
                RoundedRectangle(cornerRadius: 4)
                    .fill(store.level.color)
                    .frame(width: geo.size.width * store.progressFraction)
                    .animation(.easeOut(duration: 0.3), value: store.progressFraction)
            }
        }
        .frame(height: 6)
    }

    private var quickAddRow: some View {
        HStack(spacing: 8) {
            ForEach(store.state.quickAmounts, id: \.self) { amount in
                Button {
                    store.addExpense(amount: amount, label: "")
                } label: {
                    Text("+\(formatMoney(amount))")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
    }

    private var addForm: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                TextField("0.00", text: $amountText)
                    .frame(width: 70)
                HStack {
                TextField("e.g. coffee", text: $labelText)
                }
                Button {
                    submitExpense()
                } label: {
                    Image(systemName: "arrow.right")
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 26)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
            .textFieldStyle(.roundedBorder)

            // Always laid out (just hidden) so the popover height never changes
            // and pushes the expenses list out of view.
            Text("enter an amount first")
                .font(.system(size: 11))
                .foregroundStyle(.red)
                .opacity(showError ? 1 : 0)
        }
    }

    private var entriesList: some View {
        Group {
            if store.todaysEntries.isEmpty {
                Text("no expenses logged today")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(store.todaysEntries.reversed()) { entry in
                            entryRow(entry)
                        }
                    }
                }
                .frame(maxHeight: 130)
            }
        }
    }

    private func entryRow(_ entry: Expense) -> some View {
        HStack(spacing: 10) {
            Image(systemName: CategoryIcon.systemImage(for: entry.label))
                .font(.system(size: 12))
                .frame(width: 24, height: 24)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(entry.label.isEmpty ? "expense" : entry.label)
                .font(.system(size: 12))

            Spacer()

            Text(entry.createdAt, style: .time)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)

            Text(formatMoney(entry.amount))
                .font(.system(size: 12, weight: .medium))

            Button {
                store.removeExpense(id: entry.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func submitExpense() {
        guard let amount = Double(amountText), amount > 0 else {
            showError = true
            return
        }
        showError = false
        store.addExpense(amount: amount, label: labelText)
        amountText = ""
        labelText = ""
    }

    private func formatMoney(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "$%.0f", value)
            : String(format: "$%.2f", value)
    }
}
