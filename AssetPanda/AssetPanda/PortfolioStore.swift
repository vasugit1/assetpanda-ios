import Foundation
import Combine
import SwiftUI

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

class PortfolioStore: ObservableObject {
    @Published private(set) var portfolios: [SavedPortfolio] = []
    
    func save(portfolio: SavedPortfolio) {
        portfolios.append(portfolio)
        // Optionally, save to disk for persistence
    }
    
    func containsPortfolio(with assets: [Asset]) -> Bool {
        portfolios.contains { $0.assets == assets }
    }
    
    func load() {
        // Optionally, implement disk loading here. For now, do nothing or reset.
        // portfolios = ...
    }
    
    func deletePortfolio(_ portfolio: SavedPortfolio) {
        if let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) {
            portfolios.remove(at: index)
        }
    }
}
