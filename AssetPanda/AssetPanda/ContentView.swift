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

            // Left: Hamburger Menu
            Menu {
                Button {
                    self.showSavedView = true
                } label: {
                    Label("Saved Portfolios", systemImage: "heart.fill")
                }

                Button {
                    self.showSettingsView = true
                } label: {
                    Label("Settings", systemImage: "gear")
                }

                Button {
                    self.showAboutView = true
                } label: {
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

            // Center: Title
            Text("AssetPanda")
                .font(.system(size: 22, weight: .semibold))
                .lineLimit(1)

            Spacer()

            // Right: Heart (Saved)
            Button(action: { self.showSavePrompt = true }) {
                Image(systemName: "heart")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
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
                            AssetCardView(
                                asset: self.$assets[idx],
                                onRemove: self.assets.count > 1 ? { self.assets.remove(at: idx) } : nil
                            )
                            .id(asset.id)
                        }
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 12)
            }
            .onAppear {
                self.scrollProxy = proxy
            }
            .onChange(of: assets.count) { _, _ in
                // Scroll to last asset if added
                if let last = assets.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
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
                    withAnimation {
                        proxy.scrollTo(newAsset.id, anchor: .bottom)
                    }
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
                // Reset to default: exactly one card
                self.assets = [Asset()]
                self.calculatedTotal = nil
                self.savedMessage = nil
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

                if let total = self.calculatedTotal,
                   let formatted = self.currencyFormatter.string(from: NSNumber(value: total)) {
                    Text("Future Value: \(formatted)")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                        .padding(.horizontal)
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
            .onAppear {
                self.store.load()
            }
            .navigationBarHidden(true) // Hide the system navigation bar

            // Saved Portfolios
            .navigationDestination(isPresented: $showSavedView) {
                SavedPortfoliosView(store: store, onPortfolioSelected: { portfolio in
                    self.assets = portfolio.assets
                    self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: portfolio.assets)
                    self.savedMessage = nil
                    self.showSavedView = false
                })
            }

            // Settings
            .navigationDestination(isPresented: $showSettingsView) {
                SettingsView()
            }

            // About
            .navigationDestination(isPresented: $showAboutView) {
                AboutUsView()
            }

            .sheet(isPresented: $showSavePrompt) {
                SavePortfolioPrompt(
                    portfolioCount: store.portfolios.count,
                    portfolioName: $savePortfolioName,
                    onCancel: {
                        showSavePrompt = false
                    },
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
                            withAnimation {
                                savedMessage = nil
                            }
                        }
                    }
                )
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
    var onCancel: () -> Void
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Save Portfolio")
                    .font(.title2.bold())
                    .padding(.top)

                TextField("e.g., Current Investments", text: $portfolioName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .disabled(portfolioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
