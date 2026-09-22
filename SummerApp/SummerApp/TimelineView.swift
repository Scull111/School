import SwiftUI

struct TimelineView: View {
    @Environment(SummerStore.self) private var store
    @State private var filter = TimelineFilter.all
    @State private var editing: Activity?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.monthGroups(in: filter.region)) { group in
                    Text(group.name)
                        .eyebrow()
                        .foregroundStyle(Theme.muted)
                        .listRowInsets(EdgeInsets(top: 18, leading: 20, bottom: 2, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    ForEach(group.activities) { activity in
                        NavigationLink(value: activity) {
                            ActivityRow(activity: activity, showsDay: true, showsChevron: false)
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.delete(activity)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                editing = activity
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Theme.aegean)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.sand)
            .safeAreaInset(edge: .top, spacing: 0) { head }
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
            .sheet(item: $editing) { ActivityEditor(activity: $0) }
        }
    }

    private var head: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Timeline")
                    .font(.display(34))
                    .foregroundStyle(Theme.ink)
                Text("\(store.activities(in: filter.region).count) entries · swipe a row to edit or delete")
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
