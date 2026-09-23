import SwiftUI

struct StatsView: View {
    @Environment(ActivityStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Entries", value: "\(store.activities.count)")
                    LabeledContent("Places", value: "\(store.placeCount)")
                    LabeledContent("On Crete", value: "\(store.count(in: .crete))")
                    LabeledContent("At home", value: "\(store.count(in: .home))")
                }

                Section("By category") {
                    ForEach(Category.allCases, id: \.self) { category in
                        let count = store.count(of: category)
                        if count > 0 {
                            HStack {
                                Label(category.rawValue, systemImage: category.symbol)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let best = store.favourite {
                    Section("Best moment") {
                        NavigationLink(value: best) {
                            ActivityRow(activity: best)
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
        }
    }
}
