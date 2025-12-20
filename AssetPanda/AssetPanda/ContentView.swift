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
    @State private var showingSavedPortfolios = false
    @State private var assets: [Asset] = [Asset()]
    @State private var calculatedTotal: Double? = nil
    @State private var savedMessage: String? = nil
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Your Assets")
                    .font(.title2.bold())
                Spacer()
                Button(action: {
                    assets.append(Asset())
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding(8)
                }
                .accessibilityLabel("Add Asset")
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 18) {
                    ForEach(assets.indices, id: \.self) { idx in
                        AssetCardView(asset: $assets[idx], onRemove: assets.count > 1 ? { assets.remove(at: idx) } : nil)
                    }
                }
                .padding(.top)
            }
            
            if calculatedTotal == nil {
                Button(action: {
                    calculatedTotal = NetWorthCalculator.calculateFutureValue(for: assets)
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
                HStack(spacing: 16) {
                    Button(action: {
                        calculatedTotal = NetWorthCalculator.calculateFutureValue(for: assets)
                    }) {
                        Text("Calculate")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        saveCurrentPortfolio()
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
                }
                .padding(.horizontal)
                .padding(.top)
                
                if let total = calculatedTotal, let formatted = currencyFormatter.string(from: NSNumber(value: total)) {
                    Text("Future Value: \(formatted)")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                
                if let msg = savedMessage {
                    Text(msg)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
            
            Spacer(minLength: 16)
        }
        .padding(.top)
        .onAppear {
            store.load()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSavedPortfolios = true
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
        .sheet(isPresented: $showingSavedPortfolios) {
            SavedPortfoliosView(store: store)
        }
    }
    
    private func saveCurrentPortfolio() {
        let portfolio = SavedPortfolio(assets: assets)
        store.save(portfolio: portfolio)
        savedMessage = "Saved!"
    }
}

#Preview {
    ContentView()
}
