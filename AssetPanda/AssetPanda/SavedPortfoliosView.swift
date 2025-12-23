import SwiftUI

struct SavedPortfoliosView: View {
    @ObservedObject var store: PortfolioStore
    @Environment(\.dismiss) private var dismiss
    var onPortfolioSelected: ((SavedPortfolio) -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.portfolios) { portfolio in
                    Button {
                        onPortfolioSelected?(portfolio)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(portfolio.name)
                                .font(.headline)
                            Text("Saved on \(portfolio.savedDate.formatted(date: .abbreviated, time: .shortened)) • Assets: \(portfolio.assets.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let portfolio = store.portfolios[index]
                        store.deletePortfolio(portfolio)
                    }
                }
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
    store.save(portfolio: SavedPortfolio(name: "Sample Portfolio", assets: [Asset(), Asset()]))
    return SavedPortfoliosView(store: store)
}
