import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image("AssetPandaIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(radius: 6)
                    .padding(.top, 24)

                Text("About AssetPanda")
                    .font(.title2.bold())

                Text("AssetPanda helps you forecast net worth over time by modeling multiple assets with their own growth assumptions and contributions. Save portfolios to compare plans, revisit scenarios, and track your long-term financial direction in a clean, simple interface.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer(minLength: 12)
            }
            .padding()
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    AboutUsView()
}
