import SwiftUI
import Foundation

private extension AssetType {
    var fieldBaseColor: Color {
        switch self {
        case .realEstate: return Color.gray.opacity(0.13)
        case .stocks: return Color.blue.opacity(0.13)
        case .cash: return Color.green.opacity(0.13)
        case .crypto: return Color.orange.opacity(0.16)
        case .other: return Color.purple.opacity(0.16)
        }
    }
    var fieldFocusedColor: Color { fieldBaseColor.opacity(0.87) }
    var fieldUnfocusedColor: Color { fieldBaseColor }
    var fieldFocusedBorder: Color { Color.accentColor.opacity(0.28) }
    var fieldUnfocusedBorder: Color { Color.secondary.opacity(0.14) }
}

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

enum FocusableField: Hashable {
    case currentValue, monthlyContribution, growthRate, yieldRate, investMonths, inflation
}

struct CardTextFieldStyle: ViewModifier {
    let assetType: AssetType
    let isFocused: Bool
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isFocused ? assetType.fieldFocusedColor : assetType.fieldUnfocusedColor)
                    .animation(.easeInOut(duration: 0.25), value: isFocused)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isFocused ? assetType.fieldFocusedBorder : assetType.fieldUnfocusedBorder, lineWidth: 1)
                    .animation(.easeInOut(duration: 0.25), value: isFocused)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.black.opacity(isFocused ? 0.06 : 0.03), lineWidth: 2)
                    .blur(radius: 1.2)
                    .offset(y: 1)
                    .mask(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(colors: [Color.black, Color.clear],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                    )
            )
    }
}

struct AssetCardView: View {
    @Binding var asset: Asset

    // NEW: collapse/expand control from parent
    let isCollapsed: Bool
    let onHeaderTap: () -> Void

    @State private var currentValueString: String = ""
    @State private var monthlyContributionString: String = ""
    @State private var growthRateString: String = ""
    @State private var yieldRateString: String = ""
    @State private var investMonthsString: String = ""
    @State private var inflationString: String = ""

    @FocusState private var focusedField: FocusableField?

    var onRemove: (() -> Void)? = nil

    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = Locale.current.groupingSeparator ?? ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        return formatter
    }

    private func parseDecimal(_ input: String) -> Double? {
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","
        let cleaned = input.replacingOccurrences(of: groupingSeparator, with: "")
        return Double(cleaned)
    }

    private func formatNumber(_ value: Double) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    private func updateCurrentValueString(_ newValue: String) {
        let decimalSeparator = numberFormatter.decimalSeparator ?? "."
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","

        let cleanedInput = newValue.replacingOccurrences(of: groupingSeparator, with: "")

        if newValue != currentValueString {
            currentValueString = newValue
        }

        if let value = Double(cleanedInput) {
            asset.currentValue = max(0, value)
            if !newValue.isEmpty && !newValue.hasSuffix(decimalSeparator) {
                let formatted = formatNumber(value)
                if formatted != currentValueString && focusedField != .currentValue {
                    currentValueString = formatted
                }
            }
        } else if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.currentValue = 0
        }
    }

    private func updateMonthlyContributionString(_ newValue: String) {
        let decimalSeparator = numberFormatter.decimalSeparator ?? "."
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","

        let cleanedInput = newValue.replacingOccurrences(of: groupingSeparator, with: "")

        if newValue != monthlyContributionString {
            monthlyContributionString = newValue
        }

        if let value = Double(cleanedInput) {
            asset.monthlyContribution = max(0, value)
            if !newValue.isEmpty && !newValue.hasSuffix(decimalSeparator) {
                let formatted = formatNumber(value)
                if formatted != monthlyContributionString && focusedField != .monthlyContribution {
                    monthlyContributionString = formatted
                }
            }
        } else if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.monthlyContribution = 0
        }
    }

    private func updateGrowthRateString(_ newValue: String) {
        let decimalSeparator = numberFormatter.decimalSeparator ?? "."
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","

        let cleanedInput = newValue.replacingOccurrences(of: groupingSeparator, with: "")

        if newValue != growthRateString {
            growthRateString = newValue
        }

        if let value = Double(cleanedInput) {
            asset.growthRate = value
            if !newValue.isEmpty && !newValue.hasSuffix(decimalSeparator) {
                let formatted = formatNumber(value)
                if formatted != growthRateString && focusedField != .growthRate {
                    growthRateString = formatted
                }
            }
        } else if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.growthRate = 0
        }
    }

    private func updateYieldRateString(_ newValue: String) {
        let decimalSeparator = numberFormatter.decimalSeparator ?? "."
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","

        let cleanedInput = newValue.replacingOccurrences(of: groupingSeparator, with: "")

        if newValue != yieldRateString {
            yieldRateString = newValue
        }

        if let value = Double(cleanedInput) {
            asset.yieldRate = value
            if !newValue.isEmpty && !newValue.hasSuffix(decimalSeparator) {
                let formatted = formatNumber(value)
                if formatted != yieldRateString && focusedField != .yieldRate {
                    yieldRateString = formatted
                }
            }
        } else if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.yieldRate = 0
        }
    }

    private func updateInflationString(_ newValue: String) {
        let decimalSeparator = numberFormatter.decimalSeparator ?? "."
        let groupingSeparator = numberFormatter.groupingSeparator ?? ","

        let cleanedInput = newValue.replacingOccurrences(of: groupingSeparator, with: "")

        if newValue != inflationString {
            inflationString = newValue
        }

        if let value = Double(cleanedInput) {
            asset.inflation = value
            if !newValue.isEmpty && !newValue.hasSuffix(decimalSeparator) {
                let formatted = formatNumber(value)
                if formatted != inflationString && focusedField != .inflation {
                    inflationString = formatted
                }
            }
        } else if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.inflation = nil
        }
    }

    private func updateInvestMonthsString(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber }
        if filtered != investMonthsString {
            investMonthsString = filtered
        }
        if let value = Int(filtered) {
            asset.investMonths = max(0, value)
        } else if filtered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.investMonths = 0
        }
    }

    // MARK: - Sync UI strings from model
    private func updateFieldsFromAsset() {
        currentValueString = asset.currentValue == 0 ? "" : formatNumber(asset.currentValue)
        monthlyContributionString = asset.monthlyContribution == 0 ? "" : formatNumber(asset.monthlyContribution)
        growthRateString = asset.growthRate == 0 ? "" : formatNumber(asset.growthRate)
        yieldRateString = asset.yieldRate == 0 ? "" : formatNumber(asset.yieldRate)
        investMonthsString = asset.investMonths == 0 ? "" : "\(asset.investMonths)"
        inflationString = asset.inflation.map { formatNumber($0) } ?? ""
    }

    // MARK: - Commit helpers
    private func commitCurrentValue() {
        if let value = parseDecimal(currentValueString) {
            asset.currentValue = max(0, value)
            currentValueString = formatNumber(value)
        } else if currentValueString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.currentValue = 0
            currentValueString = ""
        }
    }

    private func commitMonthlyContribution() {
        if let value = parseDecimal(monthlyContributionString) {
            asset.monthlyContribution = max(0, value)
            monthlyContributionString = formatNumber(value)
        } else if monthlyContributionString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.monthlyContribution = 0
            monthlyContributionString = ""
        }
    }

    private func commitGrowthRate() {
        if let value = parseDecimal(growthRateString) {
            asset.growthRate = value
            growthRateString = formatNumber(value)
        } else if growthRateString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.growthRate = 0
            growthRateString = ""
        }
    }

    private func commitYieldRate() {
        if let value = parseDecimal(yieldRateString) {
            asset.yieldRate = value
            yieldRateString = formatNumber(value)
        } else if yieldRateString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.yieldRate = 0
            yieldRateString = ""
        }
    }

    private func commitInvestMonths() {
        let filtered = investMonthsString.filter { $0.isNumber }
        if let value = Int(filtered) {
            asset.investMonths = max(0, value)
            investMonthsString = "\(value)"
        } else if investMonthsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.investMonths = 0
            investMonthsString = ""
        }
    }

    private func commitInflation() {
        if let value = parseDecimal(inflationString) {
            asset.inflation = value
            inflationString = formatNumber(value)
        } else if inflationString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            asset.inflation = nil
            inflationString = ""
        }
    }

    // MARK: - Init (UPDATED SIGNATURE)
    public init(
        asset: Binding<Asset>,
        isCollapsed: Bool,
        onHeaderTap: @escaping () -> Void,
        onRemove: (() -> Void)? = nil
    ) {
        self._asset = asset
        self.isCollapsed = isCollapsed
        self.onHeaderTap = onHeaderTap
        self.onRemove = onRemove

        _currentValueString = State(initialValue: asset.wrappedValue.currentValue == 0 ? "" : {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.usesGroupingSeparator = true
            f.maximumFractionDigits = 2
            return f.string(from: NSNumber(value: asset.wrappedValue.currentValue)) ?? String(asset.wrappedValue.currentValue)
        }())
        _monthlyContributionString = State(initialValue: asset.wrappedValue.monthlyContribution == 0 ? "" : {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.usesGroupingSeparator = true
            f.maximumFractionDigits = 2
            return f.string(from: NSNumber(value: asset.wrappedValue.monthlyContribution)) ?? String(asset.wrappedValue.monthlyContribution)
        }())
        _growthRateString = State(initialValue: asset.wrappedValue.growthRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.growthRate))
        _yieldRateString = State(initialValue: asset.wrappedValue.yieldRate == 0 ? "" : String(format: "%.2f", asset.wrappedValue.yieldRate))
        _investMonthsString = State(initialValue: asset.wrappedValue.investMonths == 0 ? "" : "\(asset.wrappedValue.investMonths)")
        _inflationString = State(initialValue: asset.wrappedValue.inflation.map { String(format: "%.2f", $0) } ?? "")
    }

    var body: some View {
        VStack(spacing: 14) {

            // MARK: - Header row (Type + Currency + Remove + Collapse Toggle)
            HStack(spacing: 8) {

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

                Picker("Currency", selection: $asset.location) {
                    ForEach(AssetLocation.allCases) { location in
                        Text(location == .usa ? "USD" : "INR").tag(location)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 110, height: 28)
                .layoutPriority(1)

                // Chevron toggle indicator
                Image(systemName: isCollapsed ? "chevron.down" : "chevron.up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 28)
                    .accessibilityHidden(true)

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
            // Header is the collapse/expand tap target
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
                onHeaderTap()
            }

            // MARK: - Fields (collapsible)
            if !isCollapsed {
                VStack(spacing: 14) {

                    TextField("Enter current value", text: $currentValueString)
                        .keyboardType(.decimalPad)
                        .onChange(of: currentValueString) { _, newValue in
                            updateCurrentValueString(newValue)
                        }
                        .onSubmit { commitCurrentValue() }
                        .focused($focusedField, equals: .currentValue)
                        .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .currentValue))
                        .animation(.easeInOut(duration: 0.25), value: asset.type)

                    TextField("Monthly Contribution", text: $monthlyContributionString)
                        .keyboardType(.decimalPad)
                        .onChange(of: monthlyContributionString) { _, newValue in
                            updateMonthlyContributionString(newValue)
                        }
                        .onSubmit { commitMonthlyContribution() }
                        .focused($focusedField, equals: .monthlyContribution)
                        .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .monthlyContribution))
                        .animation(.easeInOut(duration: 0.25), value: asset.type)

                    TextField("Annual growth rate (%)", text: $growthRateString)
                        .keyboardType(.decimalPad)
                        .onChange(of: growthRateString) { _, newValue in
                            updateGrowthRateString(newValue)
                        }
                        .onSubmit { commitGrowthRate() }
                        .focused($focusedField, equals: .growthRate)
                        .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .growthRate))
                        .animation(.easeInOut(duration: 0.25), value: asset.type)

                    HStack(spacing: 10) {
                        TextField("Annual yield (%) (optional)", text: $yieldRateString)
                            .keyboardType(.decimalPad)
                            .onChange(of: yieldRateString) { _, newValue in
                                updateYieldRateString(newValue)
                            }
                            .onSubmit { commitYieldRate() }
                            .focused($focusedField, equals: .yieldRate)
                            .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .yieldRate))
                            .animation(.easeInOut(duration: 0.25), value: asset.type)

                        TextField("Inflation (%) (optional)", text: $inflationString)
                            .keyboardType(.decimalPad)
                            .onChange(of: inflationString) { _, newValue in
                                updateInflationString(newValue)
                            }
                            .onSubmit { commitInflation() }
                            .focused($focusedField, equals: .inflation)
                            .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .inflation))
                            .animation(.easeInOut(duration: 0.25), value: asset.type)
                    }

                    TextField("Investment months", text: $investMonthsString)
                        .keyboardType(.numberPad)
                        .onChange(of: investMonthsString) { _, newValue in
                            updateInvestMonthsString(newValue)
                        }
                        .onSubmit { commitInvestMonths() }
                        .focused($focusedField, equals: .investMonths)
                        .modifier(CardTextFieldStyle(assetType: asset.type, isFocused: focusedField == .investMonths))
                        .animation(.easeInOut(duration: 0.25), value: asset.type)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(asset.type.cardBackgroundColor)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.secondary, lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.25), value: asset.type)
        )
        .contentShape(Rectangle())
        // Keep your existing "tap to hide keyboard" for the overall card,
        // but it won't collapse/expand unless the header is tapped.
        .onTapGesture { hideKeyboard() }
        .onAppear { updateFieldsFromAsset() }
        .onChange(of: asset.id) { _, _ in
            updateFieldsFromAsset()
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: isCollapsed)
    }
}
