import SwiftUI
import SwiftData

struct RoundDetailView: View {
    @Bindable var round: HuiRound
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingBidSheet = false
    @State private var selectedWinnerID: UUID?
    @State private var bidAmountStr: String = ""
    
    // BUG-01 & BUG-03
    @State private var showingForceCloseAlert = false
    @State private var showingStartRoundError = false
    
    private var isAllPaid: Bool {
        guard let group = round.group else { return true }
        // Filter members to find their payments for the current round
        let totalPaid = group.members.filter { member in
            let payment = member.payments.first { $0.roundNumber == round.roundNumber }
            return payment?.isPaid ?? false
        }.count
        return totalPaid == group.members.count
    }
    
    private var isMembersFilled: Bool {
        guard let group = round.group else { return true }
        return group.members.count >= group.totalRounds
    }
    
    var body: some View {
        List {
            Section(header: Text("Thông tin kỳ hụi")) {
                LabeledContent("Trạng thái", value: round.status.rawValue)
                LabeledContent("Thời hạn", value: formatDate(round.dueDate))
                
                if let winner = round.winner {
                    LabeledContent("Người hốt", value: winner.name)
                    LabeledContent("Bỏ thầu", value: formatCurrency(round.bidAmount))
                    LabeledContent("Tiền nhận", value: formatCurrency(round.receivedAmount))
                        .fontWeight(.bold)
                } else if round.status == .active {
                    Button(action: { showingBidSheet = true }) {
                        Label("Chọn người hốt và bỏ thầu", systemImage: "crown.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if round.status == .active || round.status == .completed {
                Section(header: Text("Tình trạng thu tiền - \(formatCurrency(round.actualPayment))/người")) {
                    if let group = round.group {
                        ForEach(group.members) { member in
                            let payment = member.payments.first { $0.roundNumber == round.roundNumber }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(member.name)
                                        .font(.headline)
                                    if member.id == round.winner?.id {
                                        Text("Người hốt kỳ này")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Spacer()
                                
                                if let p = payment {
                                    Button(action: {
                                        togglePayment(p)
                                    }) {
                                        Image(systemName: p.isPaid ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(p.isPaid ? .green : .gray)
                                            .font(.title2)
                                    }
                                } else {
                                    Text("Lỗi dữ liệu")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                
                if round.status == .active {
                    Section {
                        Button(action: { 
                            if isAllPaid {
                                finishRound()
                            } else {
                                showingForceCloseAlert = true
                            }
                        }) {
                            Text("Đóng kỳ hụi")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(isAllPaid ? DesignTokens.Colors.primaryStart : Color.gray)
                                .cornerRadius(8)
                        }
                        
                        if !isAllPaid {
                            Text("⚠️ Chưa thu đủ tiền của tất cả thành viên.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(Color.clear)
                } else if round.status == .completed {
                    Section {
                        Button(action: { reopenRound() }) {
                            Text("Mở lại kỳ hụi")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(DesignTokens.Colors.primaryStart)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).stroke(DesignTokens.Colors.primaryStart, lineWidth: 1))
                        }
                        Text("Phòng trường hợp bạn nhập sai dữ liệu.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
                }
            } else if round.status == .pending {
                Section {
                    Button(action: { 
                        if round.roundNumber == 1 && !isMembersFilled {
                            showingStartRoundError = true
                        } else {
                            startRound()
                        }
                    }) {
                        Text("Bắt đầu thu kỳ này")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(round.roundNumber == 1 && !isMembersFilled ? Color.gray : Color.green)
                            .cornerRadius(8)
                    }
                    
                    if round.roundNumber == 1 && !isMembersFilled {
                        Text("⚠️ Cần ít nhất \(round.group?.totalRounds ?? 0) thành viên mới được mở kỳ đầu tiên.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Kỳ \(round.roundNumber)")
        .sheet(isPresented: $showingBidSheet) {
            bidSheet
        }
        .alert("Chưa đủ tiền", isPresented: $showingForceCloseAlert) {
            Button("Quay lại", role: .cancel) { }
            Button("Vẫn đóng kỳ", role: .destructive) {
                finishRound()
            }
        } message: {
            Text("Có một số thành viên chưa hoàn tất đóng tiền. Bạn có chắc chắn muốn đóng kỳ hụi này không?")
        }
        .alert("Chưa đủ thành viên", isPresented: $showingStartRoundError) {
            Button("Hiểu rồi", role: .cancel) { }
        } message: {
            Text("Số lượng thành viên hiện tại (\(round.group?.members.count ?? 0)) ít hơn quy mô dây hụi (\(round.group?.totalRounds ?? 0)). Hãy thêm đủ người trước khi bắt đầu hốt kỳ 1.")
        }
    }
    
    private var bidSheet: some View {
        NavigationStack {
            Form {
                if let group = round.group {
                    Picker("Người hốt", selection: $selectedWinnerID) {
                        Text("Chọn người...").tag(UUID?.none)
                        
                        ForEach(group.members.filter { !$0.hasWon }) { member in
                            Text(member.name).tag(UUID?.some(member.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Tiền bỏ thầu (VNĐ)", text: $bidAmountStr)
                        .keyboardType(.numberPad)
                    
                    if let val = Double(bidAmountStr) {
                        Section(header: Text("Tự động tính")) {
                            LabeledContent("Tiền mỗi người đóng", value: formatCurrency(group.baseAmount - val))
                        }
                    }
                }
            }
            .navigationTitle("Bỏ Thầu")
            .navigationBarItems(
                leading: Button("Huỷ", action: { showingBidSheet = false }),
                trailing: Button("Lưu", action: { saveWinner() })
                    .disabled(selectedWinnerID == nil || Double(bidAmountStr) == nil)
            )
        }
    }
    
    private func startRound() {
        round.status = .active
        guard let group = round.group else { return }
        
        // Tạo payments rỗng cho kỳ này
        for member in group.members {
            if !member.payments.contains(where: { $0.roundNumber == round.roundNumber }) {
                let payment = Payment(amount: round.actualPayment, roundNumber: round.roundNumber)
                modelContext.insert(payment)
                payment.member = member
                member.payments.append(payment)
            }
        }
    }
    
    private func saveWinner() {
        guard let id = selectedWinnerID, let amt = Double(bidAmountStr), let group = round.group else { return }
        
        if let winner = group.members.first(where: { $0.id == id }) {
            round.winner = winner
            round.bidAmount = amt
            winner.hasWon = true
            winner.wonRound = round.roundNumber
            
            // Cập nhật lại số tiền phải thu
            for member in group.members {
                if let payment = member.payments.first(where: { $0.roundNumber == round.roundNumber }) {
                    payment.amount = round.actualPayment
                }
            }
            
            showingBidSheet = false
        }
    }
    
    private func togglePayment(_ payment: Payment) {
        payment.isPaid.toggle()
        payment.paidAt = payment.isPaid ? Date() : nil
    }
    
    private func finishRound() {
        round.status = .completed
    }
    
    private func reopenRound() {
        round.status = .active
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) đ"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
