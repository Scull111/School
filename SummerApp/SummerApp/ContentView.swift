import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(ActivityStore.self) private var store
    @State private var filter = Filter.all
    @State private var addingEntry = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    summary
                    Picker("Show", selection: $filter) {
                        ForEach(Filter.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }

                ForEach(months, id: \.name) { month in
                    Section(month.name) {
                        ForEach(month.activities) { activity in
                            NavigationLink(value: activity) {
                                row(activity)
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
            .navigationTitle("Summer 26")
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

    private var summary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Robinson Ierapetra, Crete")
                .font(.headline)
            Text("28 June – 7 July · \(store.activities.count) entries · \(places) places")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func row(_ activity: Activity) -> some View {
        HStack(spacing: 12) {
            if let photo = activity.photos.first {
                PhotoImage(data: photo)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: activity.category.symbol)
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 44, height: 44)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                Text(activity.place)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(activity.date.shortDate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var places: Int {
        Set(store.activities.map(\.place)).count
    }

    private var months: [(name: String, activities: [Activity])] {
        let shown = store.activities
            .filter { filter.region == nil || $0.region == filter.region }
            .sorted { $0.date < $1.date }

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

struct PhotoImage: View {
    let data: Data

    var body: some View {
        if let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.secondary.opacity(0.2)
        }
    }
}
