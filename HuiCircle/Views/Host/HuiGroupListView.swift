import SwiftUI
import SwiftData

struct HuiGroupListView: View {
    @Query(sort: \HuiGroup.startDate, order: .reverse) private var groups: [HuiGroup]
    @State private var showingCreateGroup = false
    
    var body: some View {
        NavigationStack {
            List {
                if groups.isEmpty {
                    EmptyStateView(
                        iconName: "tray.fill",
                        title: "Chưa có dây hụi",
                        message: "Bạn chưa tạo dây hụi nào. Bấm vào nút + để tạo mới nhé.",
                        buttonTitle: "Tạo Dây Hụi",
                        buttonAction: { showingCreateGroup = true }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(groups) { group in
                        ZStack {
                            NavigationLink(destination: HuiGroupDetailView(group: group)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            HuiCardView(
                                title: group.name,
                                amount: group.baseAmount,
                                frequency: group.frequency.rawValue,
                                statusText: group.status.rawValue,
                                statusColor: statusColor(for: group.status),
                                progress: progress(for: group)
                            )
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Danh Sách Dây Hụi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateGroup = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateHuiGroupView()
            }
        }
    }
    
    private func statusColor(for status: GroupStatus) -> Color {
        switch status {
        case .active: return .green
        case .completed: return .blue
        case .paused: return .orange
        }
    }
    
    private func progress(for group: HuiGroup) -> Double {
        guard group.totalRounds > 0 else { return 0 }
        let completed = group.rounds.filter { $0.status == .completed }.count
        return Double(completed) / Double(group.totalRounds)
    }
}
