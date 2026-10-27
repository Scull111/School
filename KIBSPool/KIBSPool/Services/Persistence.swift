import Foundation

/// Local-only JSON storage in Application Support. Nothing leaves the device.
enum Persistence {
    static func url(_ name: String) -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(name)
    }

    static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        return try? dec.decode(type, from: data)
    }

    static func save<T: Encodable>(_ value: T, to url: URL) {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        guard let data = try? enc.encode(value) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    static func delete(_ name: String) { try? FileManager.default.removeItem(at: url(name)) }
}
