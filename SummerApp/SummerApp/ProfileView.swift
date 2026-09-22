import SwiftUI

struct ProfileView: View {
    @Environment(SummerStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Summer in numbers")
                            .eyebrow()
                            .foregroundStyle(Theme.clay)
                        Text("[YOUR NAME]")
                            .font(.display(34))
                            .foregroundStyle(Theme.ink)
                    }

                    HStack(spacing: 10) {
                        StatTile(value: "\(store.activities.count)", label: "Activities")
                        StatTile(value: "\(store.trip.dayCount)", label: "Days away")
                        StatTile(value: "\(store.placeCount)", label: "Places")
                    }

                    if let favourite = store.favourite {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(text: "Best moment")
                            NavigationLink(value: favourite) {
                                ActivityRow(activity: favourite)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionTitle(text: "By category")
                        ForEach(Category.allCases) { category in
                            let count = store.activities.filter { $0.category == category }.count
                            if count > 0 {
                                HStack {
                                    Image(systemName: category.symbol)
                                        .font(.system(size: 15))
                                        .foregroundStyle(category.tint)
                                        .frame(width: 24)
                                    Text(category.rawValue)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Theme.ink)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Theme.muted)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .cardBackground()
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Theme.sand)
            .navigationDestination(for: Activity.self) { ActivityDetailView(activity: $0) }
        }
    }
}
