import Foundation

struct Expense: Codable, Identifiable, Equatable {
    let id: UUID
    var amount: Double
    var label: String
    var date: String       // "yyyy-MM-dd", used to bucket by day
    var createdAt: Date
}

struct AppState: Codable {
    var budget: Double = 60
    var threshold: Double = 70          // percent of budget that counts as "close to limit"
    var quickAmounts: [Double] = [5, 10, 20, 50]
    var entries: [Expense] = []
    var streak: Int = 0
    var lastStreakDate: String? = nil
}

enum SpendLevel: String {
    case green, amber, red

    var label: String {
        switch self {
        case .green: return "under budget"
        case .amber: return "close to limit"
        case .red: return "over budget"
        }
    }
}

enum CategoryIcon {
    static func systemImage(for label: String) -> String {
        let lower = label.lowercased()
        if ["coffee", "latte", "espresso", "cafe"].contains(where: lower.contains) {
            return "cup.and.saucer.fill"
        }
        if ["lunch", "dinner", "breakfast", "food", "restaurant", "meal"].contains(where: lower.contains) {
            return "fork.knife"
        }
        if ["grocery", "groceries", "supermarket"].contains(where: lower.contains) {
            return "cart.fill"
        }
        if ["snack", "candy", "chips"].contains(where: lower.contains) {
            return "popcorn.fill"
        }
        if ["gas", "fuel", "uber", "taxi", "transport", "bus", "train"].contains(where: lower.contains) {
            return "car.fill"
        }
        if ["movie", "game", "netflix", "spotify", "entertainment"].contains(where: lower.contains) {
            return "film.fill"
        }
        if ["shopping", "clothes", "amazon"].contains(where: lower.contains) {
            return "bag.fill"
        }
        return "creditcard.fill"
    }
}

func todayKey(_ date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.string(from: date)
}
