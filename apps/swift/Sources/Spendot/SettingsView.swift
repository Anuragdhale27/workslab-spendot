import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: ExpenseStore
    @Binding var showSettings: Bool

    @State private var budgetText = ""
    @State private var thresholdText = ""
    @State private var quickAmountTexts: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Settings")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Button {
                    showSettings = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Daily budget")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                HStack {
                    Text("$")
                    TextField("60", text: $budgetText)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Alert threshold")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                HStack {
                    TextField("70", text: $thresholdText)
                        .frame(width: 50)
                        .textFieldStyle(.roundedBorder)
                    Text("% of budget triggers \"close to limit\"")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Quick add amounts")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { i in
                        TextField("", text: binding(for: i))
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }

            Button {
                save()
            } label: {
                Text("save")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: 300)
        .onAppear {
            budgetText = String(format: "%.0f", store.state.budget)
            thresholdText = String(format: "%.0f", store.state.threshold)
            quickAmountTexts = store.state.quickAmounts.map { String(format: "%.0f", $0) }
        }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < quickAmountTexts.count ? quickAmountTexts[index] : "" },
            set: { newValue in
                if index < quickAmountTexts.count {
                    quickAmountTexts[index] = newValue
                }
            }
        )
    }

    private func save() {
        if let budget = Double(budgetText) {
            store.updateBudget(budget)
        }
        if let threshold = Double(thresholdText) {
            store.updateThreshold(threshold)
        }
        let amounts = quickAmountTexts.compactMap(Double.init)
        if amounts.count == 4 {
            store.updateQuickAmounts(amounts)
        }
        showSettings = false
    }
}
