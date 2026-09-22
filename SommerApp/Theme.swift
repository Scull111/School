import SwiftUI

enum Theme {
    static let sand = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let card = Color.white
    static let ink = Color(red: 0.09, green: 0.15, blue: 0.18)
    static let muted = Color(red: 0.31, green: 0.38, blue: 0.41)
    static let aegean = Color(red: 0.06, green: 0.42, blue: 0.52)
    static let deepSea = Color(red: 0.04, green: 0.31, blue: 0.38)
    static let clay = Color(red: 0.66, green: 0.31, blue: 0.12)
    static let line = Color(red: 0.94, green: 0.91, blue: 0.85)
    static let placeholder = Color(red: 0.95, green: 0.92, blue: 0.87)
}

extension Font {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }
}

struct CardBackground: ViewModifier {
    var radius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(Theme.card, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Theme.line, lineWidth: 1)
            }
    }
}

extension View {
    func cardBackground(radius: CGFloat = 16) -> some View {
        modifier(CardBackground(radius: radius))
    }

    func eyebrow() -> some View {
        font(.system(size: 11, weight: .bold))
            .textCase(.uppercase)
            .kerning(1.6)
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.display(20))
            .foregroundStyle(Theme.ink)
    }
}

struct PhotoPlaceholder: View {
    var height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Theme.placeholder)
            .frame(height: height)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Theme.line, style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
            }
            .overlay {
                Text("[DEIN FOTO]")
                    .font(.system(size: 11, weight: .semibold))
                    .kerning(0.8)
                    .foregroundStyle(Theme.muted)
            }
    }
}

struct RatingStars: View {
    let rating: Int
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { value in
                Image(systemName: value <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(value <= rating ? Theme.clay : Theme.line)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Bewertung \(rating) von 5")
    }
}
