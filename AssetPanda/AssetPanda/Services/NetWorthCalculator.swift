import Foundation

struct NetWorthCalculator {
    /// Calculates the future value of a single asset using the provided formula.
    static func futureValue(for asset: Asset) -> Double {
        // Convert INR to USD using the conversion rate 1 USD = 83 INR if asset is located in India
        let principal: Double
        if asset.location == .india {
            let usdValue = asset.currentValue / 83.0
            principal = max(0, usdValue)
        } else {
            principal = max(0, asset.currentValue)
        }
        let years = Double(max(0, asset.investMonths)) / 12.0
        // If yieldRate is 0 or unset (treated as 0), use 0 in calculation
        let yieldRate = asset.yieldRate == 0 ? 0 : asset.yieldRate
        var effectiveRate = (asset.growthRate + yieldRate) / 100.0
        if let inflation = asset.inflation {
            effectiveRate -= inflation / 100.0
        }
        let fv = principal * pow(1.0 + effectiveRate, years)
        return fv
    }
    /// Calculates the rounded total future value for an array of assets.
    static func calculateFutureValue(for assets: [Asset]) -> Double {
        let total = assets.reduce(0) { $0 + futureValue(for: $1) }
        return (total * 100).rounded() / 100
    }
}

