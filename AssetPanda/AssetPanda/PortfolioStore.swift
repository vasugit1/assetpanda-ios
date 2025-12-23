import Foundation
import Combine

// The `name` property represents the user-supplied or auto-generated portfolio label.
struct SavedPortfolio: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let assets: [Asset]
    let savedDate: Date

    init(id: UUID = UUID(), name: String, assets: [Asset], savedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.assets = assets
        self.savedDate = savedDate
    }
}

final class PortfolioStore: ObservableObject {

    // Keep setter private to avoid accidental external mutation (fixes “setter is inaccessible” issues)
    @Published private(set) var portfolios: [SavedPortfolio] = []

    private let fileName = "saved_portfolios.json"

    // Store in Application Support (best practice for app-internal persistent data)
    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    // MARK: - Public API used by ContentView / SavedPortfoliosView

    func save(portfolio: SavedPortfolio) {
        // newest first
        portfolios.insert(portfolio, at: 0)
        persist()
    }

    func deletePortfolio(_ portfolio: SavedPortfolio) {
        portfolios.removeAll { $0.id == portfolio.id }
        persist()
    }

    func containsPortfolio(with assets: [Asset]) -> Bool {
        portfolios.contains { $0.assets == assets }
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decoded = try decoder.decode([SavedPortfolio].self, from: data)

            DispatchQueue.main.async {
                self.portfolios = decoded
            }
        } catch {
            // No file yet (first run) or decode issue -> start empty
            DispatchQueue.main.async {
                self.portfolios = []
            }
        }
    }

    // MARK: - Persistence

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(portfolios)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("PortfolioStore persist failed: \(error)")
        }
    }
}
