import SwiftUI

struct EcoView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var auth: AuthService

    private var weekStart: Date { Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now }
    private var total: Double { store.savedKg() }
    private var trees: Int { Int((total / 21).rounded()) } // ca. 21 kg CO₂ pro Baum und Jahr

    /// Klassenwertung: Beispielwerte plus eigener Beitrag.
    private var ranking: [(name: String, kg: Double)] {
        var base: [String: Double] = ["8b": 41.2, "7a": 35.8, "9c": 28.4]
        if let c = auth.current?.className { base[c, default: 0] += total }
        return base.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dein Impact").font(.title2.bold()).foregroundStyle(Theme.green)
                        HStack(spacing: 10) {
                            stat("smoke", store.savedKg(since: weekStart), "kg CO₂ gespart diese Woche")
                            stat("leaf", total, "kg CO₂ gespart gesamt")
                            stat("car.2", Double(store.avoidedCarTrips), "Autofahrten vermieden", digits: 0)
                        }
                    }.card().background(Theme.greenSoft.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))

                    HStack(spacing: 14) {
                        Image(systemName: "tree.fill").font(.largeTitle).foregroundStyle(Theme.green)
                        Text("Entspricht \(trees) gepflanzten \(trees == 1 ? "Baum" : "Bäumen")")
                            .font(.title3.bold()).foregroundStyle(Theme.green)
                        Spacer()
                    }.padding(20).background(Theme.greenSoft, in: RoundedRectangle(cornerRadius: 20))

                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Schul-Rangliste").font(.headline)
                            ForEach(Array(ranking.enumerated()), id: \.offset) { i, r in
                                HStack {
                                    Text("\(i + 1).").bold(); Text(r.name).bold(); Spacer()
                                    Image(systemName: i == 0 ? "trophy.fill" : "medal.fill")
                                        .foregroundStyle([Color.yellow, .gray, .brown][min(i, 2)])
                                }.foregroundStyle(i == 0 ? Theme.green : .primary)
                                Divider()
                            }
                        }.card()
                        VStack {
                            Image(systemName: "leaf.circle.fill").font(.system(size: 56)).foregroundStyle(Theme.green)
                            Text(badge).font(.headline)
                        }.frame(maxWidth: .infinity).card()
                    }
                }.padding(16)
            }
            .navigationTitle("Eco-Dashboard")
        }
    }

    private var badge: String {
        switch total { case ..<5: "Eco Starter"; case ..<30: "Eco Rider"; default: "Eco Hero" }
    }

    private func stat(_ icon: String, _ value: Double, _ label: String, digits: Int = 1) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title2).foregroundStyle(Theme.green)
            Text(value.formatted(.number.precision(.fractionLength(digits)))).font(.title.bold()).foregroundStyle(Theme.green)
            Text(label).font(.caption.bold()).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(10).background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
