import SwiftUI
import UIKit

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
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
