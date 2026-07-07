import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 31

    @Published var items: [PunchItem] = []
    @Published var enabledCategories: Set<String> = ["All"]

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("punchlist", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PunchItem].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }

    func canAddMore(isPro: Bool) -> Bool {
        isPro || items.count < Self.freeLimit
    }

    @discardableResult
    func add(_ item: PunchItem, isPro: Bool) -> Bool {
        guard canAddMore(isPro: isPro) else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: PunchItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    static func seedData() -> [PunchItem] {
        [
            PunchItem(title: "Fix trim in hallway", location: "Hallway", status: "Open"),
            PunchItem(title: "Repaint scuff on door", location: "Bedroom 2", status: "In Progress"),
            PunchItem(title: "Reseal tub caulking", location: "Bathroom", status: "Fixed"),
            PunchItem(title: "Adjust cabinet hinge", location: "Kitchen", status: "Open")
        ]
    }
}
