import SwiftUI

extension SpendLevel {
    var color: Color {
        switch self {
        case .green: return Color(red: 0.19, green: 0.82, blue: 0.35)
        case .amber: return Color(red: 1.0, green: 0.62, blue: 0.04)
        case .red:   return Color(red: 1.0, green: 0.27, blue: 0.23)
        }
    }

    var breathePeriod: Double {
        self == .red ? 1.6 : 3.0
    }
}

/// A single small "living" dot — a rotating light sheen over a solid
/// color fill, plus a gentle breathing pulse. Used both as the real
/// menu bar icon and as the small dot inside the popover header, so
/// it always reads as one consistent, non-static indicator.
struct StatusDotView: View {
    let level: SpendLevel
    var size: CGFloat = 10

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let rotationDegrees = (t.truncatingRemainder(dividingBy: 5) / 5) * 360
            let breathe = 1 + 0.14 * sin(t * (2 * .pi) / level.breathePeriod)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [level.color, level.color.opacity(0.65)],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: size * 0.75
                        )
                    )

                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                .white.opacity(0.55),
                                .clear,
                                .white.opacity(0.2),
                                .clear,
                                .white.opacity(0.55)
                            ],
                            center: .center
                        )
                    )
                    .rotationEffect(.degrees(rotationDegrees))
                    .blendMode(.overlay)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .scaleEffect(breathe)
            .shadow(color: level.color.opacity(0.6), radius: size * 0.4)
        }
    }
}
