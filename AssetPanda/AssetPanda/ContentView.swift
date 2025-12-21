//
//  ContentView.swift
//  AssetPanda
//
//  Created by Sri Tummala on 12/18/25.
//

import SwiftUI
import Foundation
//import SavedView
//import AssetCardView
//import NetWorthCalculator
//import Asset

struct ContentView: View {
    @StateObject private var store = PortfolioStore()
    @State private var showSavedPortfolios = false
    @State private var showSavedView = false
    @State private var assets: [Asset] = [Asset()]
    @State private var calculatedTotal: Double? = nil
    @State private var savedMessage: String? = nil
    
    @State private var showSavePrompt = false
    @State private var savePortfolioName: String = ""
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        return formatter
    }
    
    /*
    private var portfolioPicker: some View {
        if !self.store.portfolios.isEmpty {
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(self.store.portfolios.enumerated()), id: \.element.id) { index, portfolio in
                            portfolioPickerRow(index: index, portfolio: portfolio)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func portfolioPickerRow(index: Int, portfolio: SavedPortfolio) -> some View {
        HStack(spacing: 6) {
            Button(action: {
                self.assets = portfolio.assets
                self.calculatedTotal = nil
                self.savedMessage = nil
            }) {
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Portfolio \(index + 1)")
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text(portfolio.savedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        if !portfolio.assets.isEmpty {
                            Text("\(portfolio.assets.count) asset\(portfolio.assets.count == 1 ? "" : "s")")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(minWidth: 70, alignment: .leading)
                }
                .padding(.vertical, 6)
                .padding(.leading, 12)
                .padding(.trailing, 8)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
            }
            Button(action: {
                self.store.deletePortfolio(portfolio)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
    */
    
    private var assetList: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(self.assets.indices, id: \.self) { idx in
                    AssetCardView(asset: self.$assets[idx], onRemove: self.assets.count > 1 ? { self.assets.remove(at: idx) } : nil)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        Group {
            if self.calculatedTotal == nil {
                Button(action: {
                    self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: self.assets)
                }) {
                    Text("Calculate")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        Button(action: {
                            self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: self.assets)
                        }) {
                            Text("Calculate")
                                .font(.headline)
                                .frame(maxWidth: .infinity, maxHeight: 44)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            self.showSavePrompt = true
                            self.savePortfolioName = ""
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                Text("Save")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            self.assets = self.assets.map { _ in Asset() }
                            self.calculatedTotal = nil
                            self.savedMessage = nil
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.headline)
                                .frame(maxWidth: .infinity, maxHeight: 44)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if let total = self.calculatedTotal, let formatted = self.currencyFormatter.string(from: NSNumber(value: total)) {
                        Text("Future Value: \(formatted)")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                            .padding(.top)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                HStack {
                    Text("Your Assets")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding(.horizontal)
                
                assetList
                
                actionButtons
                
                if let msg = self.savedMessage {
                    Text(msg)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.top, 4)
                        .transition(.opacity)
                        .animation(.easeInOut, value: savedMessage)
                }
                
                Spacer(minLength: 16)
            }
            //.padding(.top)
            .onAppear {
                self.store.load()
            }
            //.navigationTitle("AssetPanda")
            //.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { print("Menu tapped") }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("AssetPanda")
                        .font(.system(size: 22, weight: .semibold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { self.showSavedView = true }) {
                        Image(systemName: "heart")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { self.assets.append(Asset()) }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showSavedView) {
                SavedPortfoliosView(store: store, onPortfolioSelected: { portfolio in
                    self.assets = portfolio.assets
                    self.calculatedTotal = NetWorthCalculator.calculateFutureValue(for: portfolio.assets)
                    self.savedMessage = nil
                    self.showSavedView = false
                })
            }
            .sheet(isPresented: $showSavePrompt) {
                SavePortfolioPrompt(
                    portfolioCount: store.portfolios.count,
                    portfolioName: $savePortfolioName,
                    onCancel: {
                        showSavePrompt = false
                    },
                    onSave: {
                        let nameToUse = savePortfolioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Portfolio \(store.portfolios.count + 1)" : savePortfolioName.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if store.containsPortfolio(with: assets) {
                            savedMessage = "Already saved!"
                        } else {
                            let portfolio = SavedPortfolio(name: nameToUse, assets: assets, savedDate: Date())
                            store.save(portfolio: portfolio)
                            savedMessage = "Saved!"
                        }
                        showSavePrompt = false
                        
                        // Clear savedMessage after 2 seconds
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
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(portfolioName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
