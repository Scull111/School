import UIKit

enum PhotoStore {
    private static let cache = NSCache<NSString, UIImage>()
    private static let limit: CGFloat = 1600

    private static var folder: URL {
        let url = URL.documentsDirectory.appending(path: "Photos")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func save(_ data: Data) -> String? {
        guard let original = UIImage(data: data) else { return nil }
        let image = downscaled(original)
        guard let jpeg = image.jpegData(compressionQuality: 0.8) else { return nil }

        let name = UUID().uuidString + ".jpg"
        guard (try? jpeg.write(to: folder.appending(path: name), options: .atomic)) != nil else { return nil }

        cache.setObject(image, forKey: name as NSString)
        return name
    }

    static func image(_ name: String) -> UIImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        guard let image = UIImage(contentsOfFile: folder.appending(path: name).path()) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }

    static func delete(_ name: String) {
        cache.removeObject(forKey: name as NSString)
        try? FileManager.default.removeItem(at: folder.appending(path: name))
    }

    static func prune(keeping names: Set<String>) {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: folder.path())) ?? []
        for file in files where !names.contains(file) {
            delete(file)
        }
    }

    private static func downscaled(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > limit else { return image }

        let scale = limit / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        return UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
