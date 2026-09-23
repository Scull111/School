import Foundation

@Observable
final class ActivityStore {
    var activities: [Activity] = []

    private let fileURL = URL.documentsDirectory.appending(path: "activities.json")

    init() {
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = saved
        } else {
            activities = Activity.samples
            save()
        }
    }

    func add(_ activity: Activity) {
        activities.append(activity)
        save()
    }

    func update(_ activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index] = activity
        save()
    }

    func delete(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(activities) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
