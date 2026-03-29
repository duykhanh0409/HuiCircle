import SwiftUI

struct HeaderBanner: View {
    let title: String
    let subtitle: String
    @Binding var appearCards: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .opacity(appearCards ? 1 : 0)
        .offset(y: appearCards ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appearCards)
    }
}
