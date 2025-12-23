import Foundation

struct NetWorthCalculator {

    /// Calculates the future (inflation-adjusted) value of a single asset.
    static func futureValue(for asset: Asset) -> Double {

        // Convert INR to USD using the conversion rate 1 USD = 83 INR if asset is located in India
        let principal: Double
        if asset.location == .india {
            let usdValue = asset.currentValue / 83.0
            principal = max(0, usdValue)
        } else {
            principal = max(0, asset.currentValue)
        }

        let months = max(0, asset.investMonths)
        let n = Double(months)

        // Nominal annual interest rate (growth + yield)
        let yieldRate = asset.yieldRate == 0 ? 0 : asset.yieldRate
        let nominalAnnualRate = (asset.growthRate + yieldRate) / 100.0

        let monthlyContribution = max(0, asset.monthlyContribution)

        // No interest case
        if nominalAnnualRate == 0 {
            let fv = principal + monthlyContribution * n
            return applyInflationIfNeeded(fv, asset: asset)
        }

        // Monthly compounding
        let monthlyRate = nominalAnnualRate / 12.0
        let growthFactor = pow(1.0 + monthlyRate, n)

        // Annuity Due (deposit at beginning of month)
        let annuityDueFactor =
            ((growthFactor - 1.0) / monthlyRate) * (1.0 + monthlyRate)

        let nominalFV =
            principal * growthFactor +
            monthlyContribution * annuityDueFactor

        // Apply inflation discount to final value (if provided)
        return applyInflationIfNeeded(nominalFV, asset: asset)
    }

    /// Calculates the rounded total future value for an array of assets.
    static func calculateFutureValue(for assets: [Asset]) -> Double {
        let total = assets.reduce(0) { $0 + futureValue(for: $1) }
        return (total * 100).rounded() / 100
    }

    // MARK: - Inflation adjustment (internal only)

    private static func applyInflationIfNeeded(_ value: Double, asset: Asset) -> Double {
        guard let inflation = asset.inflation, inflation > 0 else {
            return value
        }

        let years = Double(asset.investMonths) / 12.0
        let inflationRate = inflation / 100.0

        // Real value after inflation
        return value / pow(1.0 + inflationRate, years)
    }
}
