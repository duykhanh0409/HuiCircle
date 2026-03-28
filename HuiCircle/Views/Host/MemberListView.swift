import SwiftUI
import SwiftData

struct MemberListView: View {
    @Bindable var group: HuiGroup
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddMember = false
    @State private var newMemberName = ""
    @State private var newMemberPhone = ""
    
    var body: some View {
        List {
            if group.members.isEmpty {
                EmptyStateView(
                    iconName: "person.2.slash",
                    title: "Chưa có thành viên",
                    message: "Bạn chưa thêm người chơi nào vào dây hụi này."
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(group.members) { member in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(DesignTokens.Colors.primaryStart)
                        
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .font(.headline)
                            Text(member.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if member.hasWon {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                    }
                }
                .onDelete(perform: deleteMember)
            }
        }
        .navigationTitle("Danh sách thành viên")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddMember = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .alert("Thêm thành viên", isPresented: $showingAddMember) {
            TextField("Tên", text: $newMemberName)
            TextField("Số điện thoại", text: $newMemberPhone)
                .keyboardType(.phonePad)
            Button("Hủy", role: .cancel) { clearForm() }
            Button("Thêm") {
                addMember()
            }
        } message: {
            Text("Nhập thông tin người chơi")
        }
    }
    
    private func addMember() {
        guard !newMemberName.isEmpty else { return }
        
        // Add member logic
        let member = HuiMember(name: newMemberName, phone: newMemberPhone, joinedAt: Date(), hasWon: false)
        modelContext.insert(member)
        member.group = group
        group.members.append(member)
        clearForm()
    }
    
    private func deleteMember(offsets: IndexSet) {
        let membersToDelete = offsets.map { group.members[$0] }
        for member in membersToDelete {
            group.members.removeAll { $0.id == member.id }
            modelContext.delete(member)
        }
    }
    
    private func clearForm() {
        newMemberName = ""
        newMemberPhone = ""
    }
}
