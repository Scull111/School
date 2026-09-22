import SwiftUI

struct TimelineView: View {
    @Environment(SummerStore.self) private var store
    @State private var filter = TimelineFilter.alle

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(store.monthGroups(in: filter.region)) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(group.name)
                                .eyebrow()
                                .foregroundStyle(Theme.muted)
                            ForEach(group.activities) { activity in
                                NavigationLink(value: activity) {
                                    ActivityRow(activity: activity, showsDay: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .background(Theme.sand)
            .safeAreaInset(edge: .top, spacing: 0) { head }
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
        }
    }

    private var head: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Timeline")
                    .font(.display(34))
                    .foregroundStyle(Theme.ink)
                Text("\(store.activities(in: filter.region).count) Einträge von Juni bis August")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.muted)
            }

            HStack(spacing: 8) {
                ForEach(TimelineFilter.allCases) { option in
                    Button(option.rawValue) { filter = option }
                        .buttonStyle(FilterChipStyle(selected: option == filter))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(Theme.sand)
    }
}

struct FilterChipStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(selected ? Color.white : Theme.muted)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .background(selected ? Theme.clay : Theme.card, in: Capsule())
            .overlay { Capsule().stroke(selected ? Theme.clay : Theme.line, lineWidth: 1) }
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
