import Foundation

// Shared model used by ContentView amortization table
struct AmortizationRow: Identifiable {
    let id = UUID()
    let month: Int
    let contribution: Double
    let interest: Double
    let endingTotal: Double
}

struct NetWorthCalculator {

    /// Calculates the future value of a single asset.
    static func futureValue(for asset: Asset) -> Double {

        // Convert INR to USD if needed
        let principal: Double
        if asset.location == .india {
            principal = max(0, asset.currentValue / 83.0)
        } else {
            principal = max(0, asset.currentValue)
        }

        let months = max(0, asset.investMonths)
        let monthlyContribution = max(0, asset.monthlyContribution)

        let yieldRate = asset.yieldRate == 0 ? 0 : asset.yieldRate
        var effectiveRate = (asset.growthRate + yieldRate) / 100.0
        if let inflation = asset.inflation {
            effectiveRate -= inflation / 100.0
        }

        if effectiveRate == 0 {
            return principal + monthlyContribution * Double(months)
        } else {
            let monthlyRate = effectiveRate / 12.0
            return principal * pow(1 + monthlyRate, Double(months))
                + monthlyContribution * ((pow(1 + monthlyRate, Double(months)) - 1) / monthlyRate)
        }
    }

    /// Calculates total future value across all assets
    static func calculateFutureValue(for assets: [Asset]) -> Double {
        let total = assets.reduce(0) { $0 + futureValue(for: $1) }
        return (total * 100).rounded() / 100
    }

    /// ✅ Combined amortization schedule for ALL assets
    /// Includes Month 0 (starting balances)
    static func portfolioAmortizationSchedule(for assets: [Asset]) -> [AmortizationRow] {

        let maxMonths = assets.map { max(0, $0.investMonths) }.max() ?? 0
        if maxMonths == 0 { return [] }

        // Track running balances per asset
        var balances: [UUID: Double] = [:]
        balances.reserveCapacity(assets.count)

        // Initialize starting principal per asset
        for asset in assets {
            let principal: Double
            if asset.location == .india {
                principal = max(0, asset.currentValue / 83.0)
            } else {
                principal = max(0, asset.currentValue)
            }
            balances[asset.id] = principal
        }

        var rows: [AmortizationRow] = []
        rows.reserveCapacity(maxMonths + 1)

        // ===== Month 0 (starting balances) =====
        let startingTotal = balances.values.reduce(0, +)
        rows.append(
            AmortizationRow(
                month: 0,
                contribution: 0,
                interest: 0,
                endingTotal: startingTotal
            )
        )

        // ===== Months 1...N =====
        for month in 1...maxMonths {

            var monthContributionTotal: Double = 0
            var monthInterestTotal: Double = 0
            var endingTotal: Double = 0

            for asset in assets {
                let horizon = max(0, asset.investMonths)
                var balance = balances[asset.id] ?? 0

                if month <= horizon {

                    let contribution = max(0, asset.monthlyContribution)
                    let yieldRate = asset.yieldRate == 0 ? 0 : asset.yieldRate

                    var effectiveRate = (asset.growthRate + yieldRate) / 100.0
                    if let inflation = asset.inflation {
                        effectiveRate -= inflation / 100.0
                    }

                    let monthlyRate = effectiveRate / 12.0
                    let interest = (monthlyRate == 0) ? 0 : (balance * monthlyRate)

                    monthContributionTotal += contribution
                    monthInterestTotal += interest

                    balance = balance + interest + contribution
                    balances[asset.id] = balance
                }

                endingTotal += (balances[asset.id] ?? 0)
            }

            rows.append(
                AmortizationRow(
                    month: month,
                    contribution: monthContributionTotal,
                    interest: monthInterestTotal,
                    endingTotal: endingTotal
                )
            )
        }

        return rows
    }
}
