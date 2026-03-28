import SwiftUI

struct HuiCardView: View {
    let title: String
    let amount: Double
    let frequency: String
    let statusText: String
    let statusColor: Color
    let progress: Double // 0.0 to 1.0
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formatCurrency(amount))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignTokens.Colors.primaryStart)
                }
                Spacer()
                StatusBadge(text: statusText, color: statusColor)
            }
            
            HStack {
                Label(frequency, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% hoàn thành")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 6)
                        .foregroundColor(DesignTokens.Colors.primaryStart.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: max(0, min(geometry.size.width * CGFloat(animatedProgress), geometry.size.width)), height: 6)
                        .foregroundColor(DesignTokens.Colors.primaryStart)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedProgress)
                }
            }
            .frame(height: 6)
        }
        .padding(DesignTokens.Defaults.padding)
        .background(DesignTokens.Colors.cardBackground)
        .cornerRadius(DesignTokens.Defaults.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            animatedProgress = progress
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) đ"
    }
}
