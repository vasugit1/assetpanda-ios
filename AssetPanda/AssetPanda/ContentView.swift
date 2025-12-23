//
//  ContentView.swift
//  AssetPanda
//
//  Created by Sri Tummala on 12/18/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var store = PortfolioStore()

    @State private var showSavedPortfolios = false
    @State private var showSavedView = false
    @State private var showSettingsView = false
    @State private var showAboutView = false

    @State private var assets: [Asset] = [Asset()]
    @State private var calculatedTotal: Double? = nil
    @State private var savedMessage: String? = nil

    @State private var showSavePrompt = false
    @State private var savePortfolioName: String = ""

    @State private var scrollProxy: ScrollViewProxy? = nil

    // ✅ Minimize/expand: track collapsed cards by ID
    @State private var collapsedAssetIDs: Set<UUID> = []

    // ✅ Future value details sheet
    @State private var showFutureValueDetails: Bool = false
    @State private var breakdownRows: [FutureValueBreakdownRow] = []

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        return formatter
    }

    // MARK: - Compact Header (Custom "Nav Bar")
    private var compactHeader: some View {
        HStack(spacing: 12) {

            Menu {
                Button { self.showSavedView = true } label: {
                    Label("Saved Portfolios", systemImage: "heart.fill")
                }

                Button { self.showSettingsView = true } label: {
                    Label("Settings", systemImage: "gear")
                }

                Button { self.showAboutView = true } label: {
                    Label("About Us", systemImage: "info.circle")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }

            Spacer()

            Text("AssetPanda")
                .font(.system(size: 22, weight: .semibold))
                .lineLimit(1)

            Spacer()

            if calculatedTotal != nil {
                Button(action: { self.showSavePrompt = true }) {
                    Image(systemName: store.containsPortfolio(with: assets) ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Asset List (Scroll Content)
    private var assetList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    Text("Your Assets")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    ForEach(self.assets) { asset in
                        if let idx = self.assets.firstIndex(where: { $0.id == asset.id }) {

                            let assetId = self.assets[idx].id
                            let isCollapsed = collapsedAssetIDs.contains(assetId)

                            AssetCardView(
                                asset: self.$assets[idx],
                                isCollapsed: isCollapsed,
                                onHeaderTap: {
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                                        if collapsedAssetIDs.contains(assetId) {
                                            collapsedAssetIDs.remove(assetId)
                                        } else {
                                            collapsedAssetIDs.insert(assetId)
                                        }
                                    }
                                },
                                onRemove: self.assets.count > 1 ? {
                                    if let removeIndex = self.assets.firstIndex(where: { $0.id == assetId }) {
                                        self.assets.remove(at: removeIndex)
                                    }
                                    collapsedAssetIDs.remove(assetId)
                                } : nil
                            )
                            .id(assetId)
                        }
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 12)
            }
            .onAppear { self.scrollProxy = proxy }
            .onChange(of: assets.count) { _, _ in
                if let last = assets.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    // MARK: - Actions
    private var actionButtons: some View {
        HStack(spacing: 16) {

            Button(action: {
                let newAsset = Asset()
                assets.append(newAsset)
                if let proxy = scrollProxy {
                    withAnimation { proxy.scrollTo(newAsset.id, anchor: .bottom) }
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .cornerRadius(12)
            }

            Button(action: {
                self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: self.assets)
            }) {
                Text("Calculate")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            Button(action: {
                self.assets = [Asset()]
                self.calculatedTotal = nil
                self.savedMessage = nil
                self.collapsedAssetIDs.removeAll()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                compactHeader
                assetList
                actionButtons

                // ✅ Centered + clickable Future Value
                if let total = self.calculatedTotal,
                   let formatted = self.currencyFormatter.string(from: NSNumber(value: total)) {

                    Button {
                        // ✅ Add asset type to the breakdown label
                        breakdownRows = assets.enumerated().map { (idx, a) in
                            let typeName = a.type.displayName
                            return FutureValueBreakdownRow(
                                label: "Asset \(idx + 1) (\(typeName))",
                                value: NetWorthCalculator.futureValue(for: a)
                            )
                        }
                        showFutureValueDetails = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Future Value: \(formatted)")
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .sheet(isPresented: $showFutureValueDetails) {
                        FutureValueDetailsView(
                            assets: assets,
                            breakdown: breakdownRows,
                            total: total
                        )
                        .presentationDetents([.medium, .large])
                    }
                }

                if let msg = self.savedMessage {
                    Text(msg)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.top, 4)
                        .transition(.opacity)
                        .animation(.easeInOut, value: savedMessage)
                        .padding(.horizontal)
                }

                Spacer(minLength: 16)
            }
            .onAppear { self.store.load() }
            .navigationBarHidden(true)

            .navigationDestination(isPresented: $showSavedView) {
                SavedPortfoliosView(store: store, onPortfolioSelected: { portfolio in
                    self.assets = portfolio.assets
                    self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: portfolio.assets)
                    self.savedMessage = nil
                    self.showSavedView = false
                    self.collapsedAssetIDs.removeAll()
                })
            }

            .navigationDestination(isPresented: $showSettingsView) {
                SettingsView()
            }

            .navigationDestination(isPresented: $showAboutView) {
                AboutUsView()
            }

            .sheet(isPresented: $showSavePrompt, onDismiss: {
                showSavePrompt = false
                savePortfolioName = ""
            }) {
                SavePortfolioPrompt(
                    portfolioCount: store.portfolios.count,
                    portfolioName: $savePortfolioName,
                    existingNames: store.portfolios.map { $0.name },
                    onCancel: { showSavePrompt = false },
                    onSave: {
                        let trimmed = savePortfolioName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let nameToUse = trimmed.isEmpty ? "Portfolio \(store.portfolios.count + 1)" : trimmed

                        if store.containsPortfolio(with: assets) {
                            savedMessage = "Already saved!"
                        } else {
                            let portfolio = SavedPortfolio(name: nameToUse, assets: assets, savedDate: Date())
                            store.save(portfolio: portfolio)
                            savedMessage = "Saved!"
                        }

                        showSavePrompt = false

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { savedMessage = nil }
                        }
                    }
                )
                .presentationDetents([.medium])
            }
        }
        .alert("Delete Portfolio?", isPresented: $showSavedPortfolios) {
            Button("OK") {}
        }
    }
}

// MARK: - Save Portfolio Prompt
struct SavePortfolioPrompt: View {
    let portfolioCount: Int
    @Binding var portfolioName: String
    let existingNames: [String]
    var onCancel: () -> Void
    var onSave: () -> Void

    @FocusState private var nameFieldFocused: Bool
    @State private var isDuplicateName: Bool = false

    var normalizedName: String { portfolioName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    var nameIsDuplicate: Bool {
        existingNames.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .contains(normalizedName)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Save Portfolio")
                    .font(.title2.bold())
                    .padding(.top)

                TextField("Enter name (e.g., 2025 Plan & Beyond)", text: $portfolioName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .focused($nameFieldFocused)

                if isDuplicateName {
                    Text("A portfolio with this name already exists.")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }

                Text("Give this portfolio a name so you can easily find it later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Spacer()
            }
            .onAppear { self.nameFieldFocused = true }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if nameIsDuplicate {
                            isDuplicateName = true
                            return
                        }
                        isDuplicateName = false
                        onSave()
                    }
                    .disabled(portfolioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || nameIsDuplicate)
                }
            }
        }
    }
}

// MARK: - Future Value Details Models (local)
struct FutureValueBreakdownRow: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Future Value Details Sheet
struct FutureValueDetailsView: View {
    let assets: [Asset]
    let breakdown: [FutureValueBreakdownRow]
    let total: Double

    private let monthColWidth: CGFloat = 56 // ✅ narrower month column

    private var currencyFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.usesGroupingSeparator = true
        f.locale = Locale.current
        return f
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // ===== Future Estimate Breakdown =====
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader("Future Estimate Breakdown")

                        VStack(spacing: 10) {
                            ForEach(breakdown) { row in
                                HStack {
                                    Text(row.label + " :")
                                        .font(.body.weight(.semibold))
                                    Spacer()
                                    Text(currencyFormatter.string(from: NSNumber(value: row.value)) ?? "\(row.value)")
                                        .font(.body.monospacedDigit())
                                }
                            }

                            Divider().padding(.vertical, 4)

                            HStack {
                                Text("Future Value :")
                                    .font(.headline)
                                Spacer()
                                Text(currencyFormatter.string(from: NSNumber(value: total)) ?? "\(total)")
                                    .font(.headline.monospacedDigit())
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.black.opacity(0.04))
                        )
                    }

                    // ===== Combined Amortization (ALL assets) =====
                    VStack(alignment: .leading, spacing: 10) {
                        sectionHeader("Amortization")

                        let rows = NetWorthCalculator.portfolioAmortizationSchedule(for: assets)

                        amortizationTable(rows: rows)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.black.opacity(0.04))
                            )
                    }
                }
                .padding()
            }
            .navigationTitle("Future Value Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // ✅ Month column narrower + other columns moved left (not full width)
    private func amortizationTable(rows: [AmortizationRow]) -> some View {
        VStack(spacing: 8) {

            // Header Row
            HStack(spacing: 6) {   // ⬅️ reduced spacing
                Text("Month")
                    .frame(width: 44, alignment: .center)   // ⬅️ narrower + centered

                Text("Principal")
                    .frame(width: 95, alignment: .trailing)

                Text("Interest")
                    .frame(width: 85, alignment: .trailing)

                Text("Total")
                    .frame(width: 110, alignment: .trailing)

                Spacer(minLength: 0)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)

            Divider()

            // Data Rows
            ForEach(rows) { r in
                HStack(spacing: 6) {   // ⬅️ reduced spacing
                    Text("\(r.month)")
                        .frame(width: 44, alignment: .center) // ⬅️ centered month value

                    Text(currencyFormatter.string(from: NSNumber(value: r.contribution)) ?? "\(r.contribution)")
                        .frame(width: 95, alignment: .trailing)
                        .monospacedDigit()

                    Text(currencyFormatter.string(from: NSNumber(value: r.interest)) ?? "\(r.interest)")
                        .frame(width: 85, alignment: .trailing)
                        .monospacedDigit()

                    Text(currencyFormatter.string(from: NSNumber(value: r.endingTotal)) ?? "\(r.endingTotal)")
                        .frame(width: 110, alignment: .trailing)
                        .monospacedDigit()

                    Spacer(minLength: 0)
                }
                .font(.subheadline)
            }
        }
    }

}

#Preview {
    ContentView()
}
