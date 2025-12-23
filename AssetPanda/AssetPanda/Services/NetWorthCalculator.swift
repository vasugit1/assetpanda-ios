import Foundation

// Put AmortizationRow in the model layer so both NetWorthCalculator + ContentView can use it.
struct AmortizationRow: Identifiable {
    let id = UUID()
    let month: Int
    let contribution: Double     // total principal added across assets that month
    let interest: Double         // total interest earned across assets that month
    let endingTotal: Double      // total portfolio value after that month
}

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

        let n = max(0, asset.investMonths)

        // If yieldRate is 0 or unset (treated as 0), use 0 in calculation
        let yieldRate = asset.yieldRate == 0 ? 0 : asset.yieldRate

        var effectiveRate = (asset.growthRate + yieldRate) / 100.0

        // If inflation is provided, subtract it (real return)
        if let inflation = asset.inflation {
            effectiveRate -= inflation / 100.0
        }

        let r = effectiveRate
        let M = asset.monthlyContribution

        if r == 0 {
            return principal + M * Double(n)
        } else {
            let monthlyRate = r / 12.0
            let fv = principal * pow(1.0 + monthlyRate, Double(n))
                + M * ((pow(1.0 + monthlyRate, Double(n)) - 1) / monthlyRate)
            return fv
        }
    }

    /// Calculates the rounded total future value for an array of assets.
    static func calculateFutureValue(for assets: [Asset]) -> Double {
        let total = assets.reduce(0) { $0 + futureValue(for: $1) }
        return (total * 100).rounded() / 100
    }

    /// Combined portfolio amortization (one schedule for ALL assets merged).
    /// Each asset grows + contributes only for its own investMonths; then it stops (consistent with your FV model).
    static func portfolioAmortizationSchedule(for assets: [Asset]) -> [AmortizationRow] {

        let maxMonths = assets.map { max(0, $0.investMonths) }.max() ?? 0
        if maxMonths == 0 { return [] }

        // Per-asset running balances
        var balances: [UUID: Double] = [:]
        balances.reserveCapacity(assets.count)

        // Initialize principal per asset using same India->USD logic
        for a in assets {
            let principal: Double
            if a.location == .india {
                principal = max(0, a.currentValue / 83.0)
            } else {
                principal = max(0, a.currentValue)
            }
            balances[a.id] = principal
        }

        var rows: [AmortizationRow] = []
        rows.reserveCapacity(maxMonths)

        for month in 1...maxMonths {

            var monthContributionTotal: Double = 0
            var monthInterestTotal: Double = 0
            var endingTotal: Double = 0

            for a in assets {
                let horizon = max(0, a.investMonths)
                var balance = balances[a.id] ?? 0

                if month <= horizon {
                    let contribution = max(0, a.monthlyContribution)

                    let yieldRate = a.yieldRate == 0 ? 0 : a.yieldRate
                    var effectiveRate = (a.growthRate + yieldRate) / 100.0
                    if let inflation = a.inflation {
                        effectiveRate -= inflation / 100.0
                    }

                    let monthlyRate = effectiveRate / 12.0
                    let interest = (monthlyRate == 0) ? 0 : (balance * monthlyRate)

                    monthContributionTotal += contribution
                    monthInterestTotal += interest

                    balance = balance + interest + contribution
                    balances[a.id] = balance
                }

                endingTotal += (balances[a.id] ?? 0)
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
