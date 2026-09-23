import SwiftUI

struct TimelineView: View {
    @Environment(ActivityStore.self) private var store
    @State private var filter = Filter.all
    @State private var addingEntry = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Show", selection: $filter) {
                        ForEach(Filter.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }

                ForEach(months, id: \.name) { month in
                    Section(month.name) {
                        ForEach(month.activities) { activity in
                            NavigationLink(value: activity) {
                                ActivityRow(activity: activity)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                store.delete(month.activities[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Timeline")
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
            .toolbar {
                Button {
                    addingEntry = true
                } label: {
                    Label("New entry", systemImage: "plus")
                }
            }
            .sheet(isPresented: $addingEntry) {
                ActivityFormView()
            }
        }
    }

    private var months: [(name: String, activities: [Activity])] {
        let shown = store.sorted.filter { filter.region == nil || $0.region == filter.region }

        var months: [(name: String, activities: [Activity])] = []
        for activity in shown {
            let name = activity.date.monthName
            if months.last?.name == name {
                months[months.count - 1].activities.append(activity)
            } else {
                months.append((name, [activity]))
            }
        }
        return months
    }
}
