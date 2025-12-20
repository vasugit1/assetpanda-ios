import SwiftUI

struct SavedPortfoliosView: View {
    @ObservedObject var store: PortfolioStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(store.portfolios) { portfolio in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved on \(portfolio.savedDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.headline)
                    Text("Assets: \(portfolio.assets.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Saved Portfolios")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let store = PortfolioStore()
    store.save(portfolio: SavedPortfolio(assets: [Asset(), Asset()]))
    return SavedPortfoliosView(store: store)
}
