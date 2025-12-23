// Create a SwiftUI view for the Settings screen
import SwiftUI

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Settings")
                .font(.largeTitle.bold())
            Text("Coming soon...")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    SettingsView()
}
