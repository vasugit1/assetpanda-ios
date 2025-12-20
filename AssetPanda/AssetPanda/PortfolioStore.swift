import Foundation
import Combine
import SwiftUI

struct SavedPortfolio: Identifiable, Codable, Equatable {
    let id: UUID
    let assets: [Asset]
    let savedDate: Date
    
    init(id: UUID = UUID(), assets: [Asset], savedDate: Date = Date()) {
        self.id = id
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
    
    func load() {
        // Optionally, implement disk loading here. For now, do nothing or reset.
        // portfolios = ...
    }
}
