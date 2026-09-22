import SwiftUI

struct ActivityRow: View {
    let activity: Activity
    var showsDay = false

    var body: some View {
        HStack(spacing: 12) {
            if showsDay {
                VStack(spacing: 4) {
                    Text(DateText.day(activity.date))
                        .font(.display(17))
                        .foregroundStyle(Theme.ink)
                    Circle()
                        .fill(activity.category.tint)
                        .frame(width: 8, height: 8)
                }
                .frame(width: 34)
            } else {
                Image(systemName: activity.category.symbol)
                    .font(.system(size: 18))
                    .foregroundStyle(activity.category.tint)
                    .frame(width: 42, height: 42)
                    .background(activity.category.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.muted.opacity(0.6))
        }
        .padding(10)
        .frame(minHeight: 56)
        .cardBackground()
    }

    private var subtitle: String {
        showsDay ? activity.place : "\(activity.place) · \(DateText.dayMonth(activity.date))"
    }
}
