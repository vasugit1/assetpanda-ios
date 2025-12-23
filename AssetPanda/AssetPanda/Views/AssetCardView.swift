import SwiftUI
import Foundation

private extension AssetType {
    var textFieldBackgroundColor: Color {
        switch self {
        case .realEstate: return Color.gray.opacity(0.11)
        case .stocks: return Color.blue.opacity(0.1)
        case .cash: return Color.green.opacity(0.1)
        case .crypto: return Color.orange.opacity(0.1)
        case .other: return Color.purple.opacity(0.1)
        }
    }
}

extension View {
    func hideKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
#endif
    }
}

struct AssetCardView: View {
    @Binding var asset: Asset

    @State private var currentValueString: String = ""
    @State private var monthlyContributionString: String = ""
    @State private var growthRateString: String = ""
    @State private var yieldRateString: String = ""
    @State private var investMonthsString: String = ""
    @State private var inflationString: String = ""

    var onRemove: (() -> Void)? = nil

    // MARK: - Sync UI strings from model
    private func updateFieldsFromAsset() {
        currentValueString = asset.currentValue == 0 ? "" : String(format: "%.2f", asset.currentValue)
        monthlyContributionString = asset.monthlyContribution == 0 ? "" : String(format: "%.2f", asset.monthlyContribution)
        growthRateString = asset.growthRate == 0 ? "" : String(format: "%.2f", asset.growthRate)
        yieldRateString = asset.yieldRate == 0 ? "" : String(format: "%.2f", asset.yieldRate)
        investMonthsString = asset.investMonths == 0 ? "" : "\(asset.investMonths)"
        inflationString = asset.inflation.map { String(format: "%.2f", $0) } ?? ""
    }

    // MARK: - Commit helpers
    private func commitCurrentValue() {
        if let value = Double(currentValueString) {
            asset.currentValue = max(0, value)
        } else if currentValueString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.currentValue = 0
        }
    }

    private func commitMonthlyContribution() {
        if let value = Double(monthlyContributionString) {
            asset.monthlyContribution = max(0, value)
        } else if monthlyContributionString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.monthlyContribution = 0
        }
    }

    private func commitGrowthRate() {
        if let value = Double(growthRateString) {
            asset.growthRate = value
        } else if growthRateString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.growthRate = 0
        }
    }

    private func commitYieldRate() {
        if let value = Double(yieldRateString) {
            asset.yieldRate = value
        } else if yieldRateString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.yieldRate = 0
        }
    }

    private func commitInvestMonths() {
        if let value = Int(investMonthsString) {
            asset.investMonths = max(0, value)
        } else if investMonthsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.investMonths = 0
        }
    }

    private func commitInflation() {
        if let value = Double(inflationString) {
            asset.inflation = value
        } else if inflationString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.inflation = nil
        }
    }

    // MARK: - Init
    public init(asset: Binding<Asset>, onRemove: (() -> Void)? = nil) {
        self._asset = asset
        self.onRemove = onRemove

        _currentValueString = State(initialValue: asset.wrappedValue.currentValue == 0 ? "" : String(format: "%.2f", asset.wrappedValue.currentValue))
        _monthlyContributionString = State(initialValue: asset.wrappedValue.monthlyContribution == 0 ? "" : String(format: "%.2f", asset.wrappedValue.monthlyContribution))
        _growthRateString = State(initialValue: asset.wrappedValue.growthRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.growthRate))
        _yieldRateString = State(initialValue: asset.wrappedValue.yieldRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.yieldRate))
        _investMonthsString = State(initialValue: asset.wrappedValue.investMonths == 0 ? "" : "\(asset.wrappedValue.investMonths)")
        _inflationString = State(initialValue: asset.wrappedValue.inflation.map { String(format: "%.2f", $0) } ?? "")
    }

    var body: some View {
        VStack(spacing: 14) {

            // MARK: - Header row (Type + Currency + Remove)
            HStack(spacing: 8) {

                // Asset type picker should flex + truncate (not wrap)
                Picker("Type", selection: $asset.type) {
                    ForEach(AssetType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(2)

                // Currency selector fixed width
                Picker("Currency", selection: $asset.location) {
                    ForEach(AssetLocation.allCases) { location in
                        Text(location == .usa ? "USD" : "INR").tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 110, height: 28)
                .layoutPriority(1)

                // Remove button fixed width
                if onRemove != nil {
                    Button {
                        onRemove?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove Asset")
                    .layoutPriority(3)
                }
            }

            // MARK: - Fields
            TextField("Enter current value", text: $currentValueString)
                .keyboardType(.decimalPad)
                .onChange(of: currentValueString) { commitCurrentValue() }
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(asset.type.textFieldBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                )

            TextField("Monthly Contribution", text: $monthlyContributionString)
                .keyboardType(.decimalPad)
                .onChange(of: monthlyContributionString) { commitMonthlyContribution() }
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(asset.type.textFieldBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                )

            TextField("Annual growth rate (%)", text: $growthRateString)
                .keyboardType(.decimalPad)
                .onChange(of: growthRateString) { commitGrowthRate() }
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(asset.type.textFieldBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                )

            HStack(spacing: 10) {
                TextField("Annual yield (%) (optional)", text: $yieldRateString)
                    .keyboardType(.decimalPad)
                    .onChange(of: yieldRateString) { commitYieldRate() }
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(asset.type.textFieldBackgroundColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                    )

                TextField("Inflation (%) (optional)", text: $inflationString)
                    .keyboardType(.decimalPad)
                    .onChange(of: inflationString) { commitInflation() }
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(asset.type.textFieldBackgroundColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                    )
            }

            TextField("Investment months", text: $investMonthsString)
                .keyboardType(.numberPad)
                .onChange(of: investMonthsString) { commitInvestMonths() }
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(asset.type.textFieldBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
                )
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(asset.type.cardBackgroundColor)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.secondary, lineWidth: 1)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
        .onAppear { updateFieldsFromAsset() }
        .onChange(of: asset.id) { _, _ in
            updateFieldsFromAsset()
        }
        .padding(.horizontal)
    }
}
