import SwiftUI

struct SummerView: View {
    @Environment(ActivityStore.self) private var store
    @State private var addingEntry = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Robinson Ierapetra, Crete")
                            .font(.headline)
                        Text("28 June – 7 July · \(store.activities.count) entries")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Recent") {
                    ForEach(store.recent) { activity in
                        NavigationLink(value: activity) {
                            ActivityRow(activity: activity)
                        }
                    }
                }

                Section("Best days") {
                    ForEach(store.bestDays) { activity in
                        NavigationLink(value: activity) {
                            ActivityRow(activity: activity)
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
}
