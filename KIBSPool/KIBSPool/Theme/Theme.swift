import SwiftUI

enum Theme {
    static let green = Color(red: 0.10, green: 0.55, blue: 0.20)
    static let greenSoft = Color(red: 0.88, green: 0.95, blue: 0.88)
    static let card = Color(.secondarySystemGroupedBackground)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(Theme.green.opacity(configuration.isPressed ? 0.8 : 1),
                        in: RoundedRectangle(cornerRadius: 16))
    }
}

struct Chip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12).padding(.vertical, 4)
            .foregroundStyle(Theme.green)
            .background(Theme.greenSoft, in: Capsule())
    }
}
