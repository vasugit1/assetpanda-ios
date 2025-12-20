import XCTest
@testable import AssetPanda

final class NetWorthCalculatorTests: XCTestCase {
    func testSingleAssetFutureValue() {
        // $10,000, growth 4%, yield 1%, 24 months → 10000 * (1.05^2)
        let asset = Asset(
            currentValue: 10000,
            growthRate: 4,
            yieldRate: 1,
            investMonths: 24
        )
        let expected = 10000 * pow(1.05, 2.0)
        let actual = NetWorthCalculator.futureValue(for: asset)
        XCTAssertEqual(actual, expected, accuracy: 0.01)
    }
    func testMultipleAssetsFutureValueSum() {
        let asset1 = Asset(currentValue: 5000, growthRate: 3, yieldRate: 2, investMonths: 12) // 5000 * 1.05^1
        let asset2 = Asset(currentValue: 12000, growthRate: 6, yieldRate: 0, investMonths: 36) // 12000 * 1.06^3
        let assets = [asset1, asset2]
        let expected1 = NetWorthCalculator.futureValue(for: asset1)
        let expected2 = NetWorthCalculator.futureValue(for: asset2)
        let sum = expected1 + expected2
        let roundedSum = (sum * 100).rounded() / 100
        let actual = NetWorthCalculator.calculateFutureValue(for: assets)
        XCTAssertEqual(actual, roundedSum, accuracy: 0.01)
    }
}

