//
//  ContentView.swift
//  AssetPanda
//
//  Created by Sri Tummala on 12/18/25.
//

import SwiftUI
import Foundation
//import AssetCardView
//import NetWorthCalculator
//import Asset

struct ContentView: View {
    @StateObject private var store = PortfolioStore()
    @State private var showSavedPortfolios = false
    @State private var assets: [Asset] = [Asset()]
    @State private var calculatedTotal: Double? = nil
    @State private var savedMessage: String? = nil
    
    @State private var selectedPortfolioId: UUID? = nil
    @State private var portfolioToDelete: SavedPortfolio? = nil
    @State private var showingDeleteAlert = false
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        return formatter
    }
    
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
                            self.saveCurrentPortfolio()
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
                            self.assets = [Asset()]
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
                    
                    if let msg = self.savedMessage {
                        Text(msg)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Inserted Saved Portfolios chip row above "Your Assets"
                if !store.portfolios.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved Portfolios")
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(store.portfolios.enumerated()), id: \.element.id) { index, portfolio in
                                    let isSelected = selectedPortfolioId == portfolio.id
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color(.systemBackground).opacity(isSelected ? 1.0 : 0.8))
                                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                                            )
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Portfolio \(index + 1)")
                                                .font(.callout.weight(.semibold))
                                                .lineLimit(1)
                                            Text(portfolio.savedDate.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            if !portfolio.assets.isEmpty {
                                                Text("\(portfolio.assets.count) asset\(portfolio.assets.count == 1 ? "" : "s")")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 12)
                                    }
                                    .frame(minWidth: 95, maxWidth: 130, minHeight: 44)
                                    .scaleEffect(isSelected ? 1.08 : 1.0)
                                    .onTapGesture {
                                        selectedPortfolioId = portfolio.id
                                        assets = portfolio.assets
                                        calculatedTotal = nil
                                        savedMessage = nil
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            portfolioToDelete = portfolio
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(maxHeight: 60)
                        }
                    }
                    .padding(.top, 6)
                }
                
                HStack {
                    Text("Your Assets")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding(.horizontal)
                
                assetList
                
                actionButtons
                
                Spacer(minLength: 16)
            }
            //.padding(.top)
            .onAppear {
                self.store.load()
                if selectedPortfolioId == nil, !store.portfolios.isEmpty {
                    selectedPortfolioId = store.portfolios.last?.id
                }
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { self.showSavedPortfolios = true }) {
                        Image(systemName: "heart")
                    }
                    Button(action: { self.assets.append(Asset()) }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Delete Portfolio?", isPresented: $showingDeleteAlert, presenting: portfolioToDelete) { portfolio in
            Button("Delete", role: .destructive) {
                store.deletePortfolio(portfolio)
                if selectedPortfolioId == portfolio.id {
                    selectedPortfolioId = nil
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This will permanently remove the saved portfolio.")
        }
    }
    
    private func saveCurrentPortfolio() {
        if store.containsPortfolio(with: assets) {
            savedMessage = "Already saved!"
            return
        }
        let portfolio = SavedPortfolio(assets: assets)
        store.save(portfolio: portfolio)
        savedMessage = "Saved!"
    }
}

#Preview {
    ContentView()
}
