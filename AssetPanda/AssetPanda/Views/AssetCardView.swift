import SwiftUI
import Foundation

extension View {
    func hideKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
    
    private func updateFieldsFromAsset() {
        currentValueString = asset.currentValue == 0 ? "" : String(format: "%.2f", asset.currentValue)
        monthlyContributionString = asset.monthlyContribution == 0 ? "" : String(format: "%.2f", asset.monthlyContribution)
        growthRateString = asset.growthRate == 0 ? "" : String(format: "%.2f", asset.growthRate)
        yieldRateString = asset.yieldRate == 0 ? "" : String(format: "%.2f", asset.yieldRate)
        investMonthsString = asset.investMonths == 0 ? "" : "\(asset.investMonths)"
        if let inflation = asset.inflation {
            inflationString = String(format: "%.2f", inflation)
        } else {
            inflationString = ""
        }
    }

    private func commitCurrentValue() {
        if let value = Double(currentValueString) {
            asset.currentValue = max(0, value)
        }
    }
    private func commitMonthlyContribution() {
        if let value = Double(monthlyContributionString) {
            asset.monthlyContribution = max(0, value)
        } else {
            asset.monthlyContribution = 0
        }
    }
    private func commitGrowthRate() {
        if let value = Double(growthRateString) {
            asset.growthRate = value
        }
    }
    private func commitYieldRate() {
        if let value = Double(yieldRateString) {
            asset.yieldRate = value
        } else {
            asset.yieldRate = 0
        }
    }
    private func commitInvestMonths() {
        if let value = Int(investMonthsString) {
            asset.investMonths = max(0, value)
        }
    }
    private func commitInflation() {
        if let value = Double(inflationString) {
            asset.inflation = value
        } else {
            asset.inflation = nil
        }
    }

    public init(asset: Binding<Asset>, onRemove: (() -> Void)? = nil) {
        self._asset = asset
        self.onRemove = onRemove
        // set initial values with empty string if zero
        _currentValueString = State(initialValue: asset.wrappedValue.currentValue == 0 ? "" : String(format: "%.2f", asset.wrappedValue.currentValue))
        _monthlyContributionString = State(initialValue: asset.wrappedValue.monthlyContribution == 0 ? "" : String(format: "%.2f", asset.wrappedValue.monthlyContribution))
        _growthRateString = State(initialValue: asset.wrappedValue.growthRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.growthRate))
        _yieldRateString = State(initialValue: asset.wrappedValue.yieldRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.yieldRate))
        _investMonthsString = State(initialValue: asset.wrappedValue.investMonths == 0 ? "" : "\(asset.wrappedValue.investMonths)")
        if let inflation = asset.wrappedValue.inflation {
            _inflationString = State(initialValue: String(format: "%.2f", inflation))
        } else {
            _inflationString = State(initialValue: "")
        }
        updateFieldsFromAsset()
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Picker("Type", selection: $asset.type) {
                    ForEach(AssetType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
                
                if onRemove != nil {
                    Button {
                        onRemove?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Remove Asset")
                }
            }

            // Current Value row with location picker
            HStack(spacing: 12) {
                TextField("Enter current value", text: $currentValueString, onCommit: commitCurrentValue)
                    .keyboardType(.decimalPad)
                    .onChange(of: currentValueString) { commitCurrentValue() }
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .layoutPriority(1)
                
                Picker("Location", selection: $asset.location) {
                    ForEach(AssetLocation.allCases) { location in
                        Text(location == .usa ? "USD" : "INR").tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            
            // Monthly Contribution row below Current Value
            TextField("Monthly Contribution", text: $monthlyContributionString, onCommit: commitMonthlyContribution)
                .keyboardType(.decimalPad)
                .onChange(of: monthlyContributionString) { commitMonthlyContribution() }
                .textFieldStyle(.roundedBorder)

            TextField("Annual growth rate (%)", text: $growthRateString, onCommit: commitGrowthRate)
                .keyboardType(.decimalPad)
                .onChange(of: growthRateString) { commitGrowthRate() }
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField("Annual yield (%) (optional)", text: $yieldRateString, onCommit: commitYieldRate)
                    .keyboardType(.decimalPad)
                    .onChange(of: yieldRateString) { commitYieldRate() }
                    .textFieldStyle(.roundedBorder)

                TextField("Inflation (%) (optional)", text: $inflationString, onCommit: commitInflation)
                    .keyboardType(.decimalPad)
                    .onChange(of: inflationString) { commitInflation() }
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Investment months", text: $investMonthsString, onCommit: commitInvestMonths)
                .keyboardType(.numberPad)
                .onChange(of: investMonthsString) { commitInvestMonths() }
                .textFieldStyle(.roundedBorder)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.secondary, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { self.hideKeyboard() }
        .onChange(of: asset.id) { oldValue, newValue in
            updateFieldsFromAsset()
        }
        .padding(.horizontal)
    }
}

