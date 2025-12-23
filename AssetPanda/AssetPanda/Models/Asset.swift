import Foundation
import SwiftUI

enum AssetType: String, CaseIterable, Identifiable, Codable {
    case realEstate
    case stocks
    case cash
    case crypto
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .realEstate: return "Real Estate"
        case .stocks: return "Stocks"
        case .cash: return "Cash"
        case .crypto: return "Crypto"
        case .other: return "Other"
        }
    }
    
    var cardBackgroundColor: Color {
        switch self {
        case .realEstate: return Color.gray.opacity(0.1)
        case .stocks: return Color.blue.opacity(0.08)
        case .cash: return Color.green.opacity(0.08)
        case .crypto: return Color.orange.opacity(0.09)
        case .other: return Color.purple.opacity(0.09)
        }
    }
}

enum AssetLocation: String, CaseIterable, Identifiable, Codable {
    case usa
    case india

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .usa: return "USA"
        case .india: return "India"
        }
    }
}

/// Core model representing one asset entry in AssetPanda.
struct Asset: Identifiable, Codable, Equatable {
    var id: UUID
    var type: AssetType
    var location: AssetLocation
    var currentValue: Double      // dollars
    var growthRate: Double        // annual %, e.g. 4 for 4%
    var yieldRate: Double         // annual %, e.g. 1.5
    var investMonths: Int         // total months
    var inflation: Double?        // optional annual inflation %
    var monthlyContribution: Double // dollars

    init(
        id: UUID = UUID(),
        type: AssetType = .realEstate,
        location: AssetLocation = .usa,
        currentValue: Double = 0,
        growthRate: Double = 0,
        yieldRate: Double = 0,
        investMonths: Int = 0,
        inflation: Double? = nil,
        monthlyContribution: Double = 0
    ) {
        self.id = id
        self.type = type
        self.location = location
        self.currentValue = max(0, currentValue)
        self.growthRate = growthRate
        self.yieldRate = yieldRate
        self.investMonths = max(0, investMonths)
        self.inflation = inflation
        self.monthlyContribution = max(0, monthlyContribution)
    }
}

