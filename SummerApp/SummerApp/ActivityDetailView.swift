import SwiftUI

struct ActivityDetailView: View {
    @Environment(SummerStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let activity: Activity

    @State private var editing = false
    @State private var confirmingDelete = false

    private var current: Activity {
        store.current(activity) ?? activity
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                photos

                VStack(alignment: .leading, spacing: 6) {
                    Text(current.title)
                        .font(.display(32))
                        .foregroundStyle(Theme.ink)
                    Text("\(DateText.dayMonth(current.date)) · \(current.place) · \(current.category.rawValue)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.muted)
                }

                HStack(spacing: 10) {
                    RatingStars(rating: current.rating, size: 17)
                    if current.rating == 5 {
                        Text("One of the best days")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                }

                HStack(spacing: 8) {
                    Tag(text: current.category.rawValue, tint: current.category.tint)
                    Tag(text: current.region.rawValue, tint: Theme.aegean)
                }

                if !current.note.isEmpty {
                    Text(current.note)
                        .font(.system(size: 14))
                        .lineSpacing(4)
                        .foregroundStyle(Theme.ink.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .cardBackground(radius: 18)
                }

                facts
                deleteButton
            }
            .padding(20)
        }
        .background(Theme.sand)
        .navigationTitle(current.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { editing = true }
                    .foregroundStyle(Theme.clay)
            }
        }
        .sheet(isPresented: $editing) {
            ActivityEditor(activity: current)
        }
        .confirmationDialog("Delete this entry?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(current)
                dismiss()
            }
            Button("Keep it", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var photos: some View {
        Group {
            if current.photos.isEmpty {
                PhotoPlaceholder(height: 230)
            } else if current.photos.count == 1 {
                PhotoThumb(data: current.photos[0])
                    .frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                TabView {
                    ForEach(Array(current.photos.enumerated()), id: \.offset) { _, data in
                        PhotoThumb(data: data)
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
                .frame(height: 258)
                .tabViewStyle(.page)
            }
        }
    }

    private var facts: some View {
        VStack(spacing: 0) {
            FactRow(label: "Duration", value: current.duration.isEmpty ? "[DURATION]" : current.duration)
            Divider().overlay(Theme.line)
            FactRow(label: "With", value: current.company.isEmpty ? "[WITH WHOM]" : current.company)
            Divider().overlay(Theme.line)
            FactRow(label: "Weather", value: current.weather.isEmpty ? "[WEATHER]" : current.weather)
        }
        .cardBackground(radius: 18)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            confirmingDelete = true
        } label: {
            Label("Delete entry", systemImage: "trash")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.red)
        .cardBackground()
    }
}

struct FactRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct Tag: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(tint.opacity(0.12), in: Capsule())
    }
}
