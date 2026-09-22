import SwiftUI

struct SummerView: View {
    @Environment(SummerStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    tripCard
                    stats
                    recent
                }
                .padding(20)
            }
            .background(Theme.sand)
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
            .navigationDestination(for: Trip.self) { TripView(trip: $0) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Mein Sommer")
                .eyebrow()
                .foregroundStyle(Theme.clay)
            Text("Sommer 26")
                .font(.display(42))
                .foregroundStyle(Theme.ink)
            Text("Kreta · Ierapetra · zuhause")
                .font(.system(size: 14))
                .foregroundStyle(Theme.muted)
        }
    }

    private var tripCard: some View {
        NavigationLink(value: store.trip) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Die Reise")
                        .eyebrow()
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text(store.trip.name)
                        .font(.display(30))
                        .foregroundStyle(.white)
                    Text("\(store.trip.destination) · \(store.trip.dateRange)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.8))
                }

                Label("Reise ansehen", systemImage: "arrow.right")
                    .labelStyle(.trailingIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Theme.clay, in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Theme.deepSea, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(alignment: .topTrailing) { sun }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var sun: some View {
        ZStack {
            Circle().stroke(Theme.clay, lineWidth: 2).frame(width: 72, height: 72)
            Circle().stroke(Theme.clay, lineWidth: 1).frame(width: 108, height: 108)
        }
        .opacity(0.5)
        .offset(x: 30, y: -30)
    }

    private var stats: some View {
        HStack(spacing: 10) {
            StatTile(value: "\(store.activities.count)", label: "Aktivitäten")
            StatTile(value: "\(store.trip.dayCount)", label: "Tage Kreta")
            StatTile(value: "\(store.placeCount)", label: "Orte")
        }
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(text: "Zuletzt gemacht")
            ForEach(store.recent) { activity in
                NavigationLink(value: activity) {
                    ActivityRow(activity: activity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.display(24))
                .foregroundStyle(Theme.ink)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .cardBackground()
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 7) {
            configuration.title
            configuration.icon.font(.system(size: 12, weight: .bold))
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}
