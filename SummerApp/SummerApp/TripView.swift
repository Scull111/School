import SwiftUI

struct TripView: View {
    @Environment(SummerStore.self) private var store
    let trip: Trip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                chips
                photos
                highlights
                note
            }
            .padding(20)
        }
        .background(Theme.sand)
        .navigationTitle("Trip")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.dateRange)
                .eyebrow()
                .foregroundStyle(Color.white.opacity(0.7))
            Text(trip.name)
                .font(.display(32))
                .foregroundStyle(.white)
            Text(trip.destination)
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Theme.deepSea, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var chips: some View {
        HStack(spacing: 8) {
            Chip(text: "\(trip.dayCount) days")
            Chip(text: "\(store.tripActivities.count) activities")
            Chip(text: "\(Set(store.tripActivities.map(\.place)).count) places")
        }
    }

    private var photos: some View {
        HStack(spacing: 10) {
            PhotoPlaceholder(height: 96)
            PhotoPlaceholder(height: 96)
            PhotoPlaceholder(height: 96)
        }
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Highlights")
            ForEach(store.highlights) { activity in
                NavigationLink(value: activity) {
                    ActivityRow(activity: activity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var note: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note")
                .eyebrow()
                .foregroundStyle(Theme.clay)
            Text(trip.note)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundStyle(Theme.ink.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardBackground(radius: 18)
    }
}

struct Chip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(Theme.card, in: Capsule())
            .overlay { Capsule().stroke(Theme.line, lineWidth: 1) }
    }
}
