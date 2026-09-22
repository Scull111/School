import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoPlaceholder(height: 230)

                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.title)
                        .font(.display(32))
                        .foregroundStyle(Theme.ink)
                    Text("\(DateText.dayMonth(activity.date)) · \(activity.place) · \(activity.category.rawValue)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                }

                HStack(spacing: 10) {
                    RatingStars(rating: activity.rating, size: 17)
                    if activity.rating == 5 {
                        Text("Bester Tag der Reise")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                }

                HStack(spacing: 8) {
                    Tag(text: activity.category.rawValue, tint: activity.category.tint)
                    Tag(text: activity.region.rawValue, tint: Theme.aegean)
                }

                Text(activity.note)
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.ink.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .cardBackground(radius: 18)

                facts
            }
            .padding(20)
        }
        .background(Theme.sand)
        .navigationTitle(activity.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var facts: some View {
        VStack(spacing: 0) {
            FactRow(label: "Dauer", value: activity.duration.isEmpty ? "[DAUER]" : activity.duration)
            Divider().overlay(Theme.line)
            FactRow(label: "Mit", value: activity.company)
            Divider().overlay(Theme.line)
            FactRow(label: "Wetter", value: activity.weather.isEmpty ? "[WETTER]" : activity.weather)
        }
        .cardBackground(radius: 18)
    }
}

struct FactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct Tag: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(tint.opacity(0.12), in: Capsule())
    }
}
