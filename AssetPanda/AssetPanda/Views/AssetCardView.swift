import SwiftUI

struct AssetCardView: View {
    @Binding var asset: Asset
    @State private var currentValueString: String = ""
    @State private var growthRateString: String = ""
    @State private var yieldRateString: String = ""
    @State private var investMonthsString: String = ""
    @State private var inflationString: String = ""
    var onRemove: (() -> Void)? = nil
    
    private func updateFieldsFromAsset() {
        currentValueString = String(format: "%.2f", asset.currentValue)
        growthRateString = String(format: "%.2f", asset.growthRate)
        if asset.yieldRate == 0 {
            yieldRateString = ""
        } else {
            yieldRateString = String(format: "%.2f", asset.yieldRate)
        }
        investMonthsString = "\(asset.investMonths)"
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
        _growthRateString = State(initialValue: asset.wrappedValue.growthRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.growthRate))
        _yieldRateString = State(initialValue: asset.wrappedValue.yieldRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.yieldRate))
        _investMonthsString = State(initialValue: asset.wrappedValue.investMonths == 0 ? "" : "\(asset.wrappedValue.investMonths)")
        if let inflation = asset.wrappedValue.inflation {
            _inflationString = State(initialValue: String(format: "%.2f", inflation))
        } else {
            _inflationString = State(initialValue: "")
        }
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

            HStack(spacing: 12) {
                // Container to constrain the width to about 50% of the HStack
                HStack {
                    TextField("Enter current value", text: $currentValueString, onCommit: commitCurrentValue)
                        .keyboardType(.decimalPad)
                        .onChange(of: currentValueString) { commitCurrentValue() }
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .layoutPriority(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("Location", selection: $asset.location) {
                    ForEach(AssetLocation.allCases) { location in
                        Text(location == .usa ? "USD" : "INR").tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

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
        .padding(.horizontal)
    }
}

