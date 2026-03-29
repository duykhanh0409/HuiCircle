# HuiCircle — Improvement Plan (v2)

> Sau MVP v1, đây là danh sách cải tiến ưu tiên, được phân nhóm theo tính chất.
> Updated: 2026-03-28

---

## 🔴 Critical Bugs (Phải fix trước khi dùng thực tế)

### BUG-01: Hoàn tất kỳ hụi khi chưa thu đủ tiền
**Mô tả:** Hiện tại nút "Đóng kỳ hụi" luôn luôn active, dù chỉ 1/15 thành viên đánh dấu đã đóng vẫn được phép hoàn tất. Như vậy là hoàn toàn sai nghiệp vụ.

**Hành vi mong muốn:**
- Nút "Đóng kỳ hụi" phải bị **disabled** (xám) khi còn bất kỳ thành viên nào chưa đóng.
- Nếu bắt buộc muốn đóng sớm (trường hợp đặc biệt), phải thêm popup xác nhận cảnh báo.

**File cần sửa:** `RoundDetailView.swift`

---

### BUG-02: Tạo dây hụi thành công mà không có thành viên nào
**Mô tả:** Business thực tế là phải có đủ người thì mới hốt hụi được. Hiện tại app cho phép tạo dây hụi 0 thành viên và vẫn cho phép "Bắt đầu thu", tức là kỳ đó không thu được một đồng nào và logic bị vỡ.

**Hành vi mong muốn:**
- Nút "Lưu" trong `CreateHuiGroupView` phải check `totalMembers >= 2`.
- Chỉ cho phép "Bắt đầu thu kỳ" khi `group.members.count >= group.totalRounds`.
- Hiển thị banner alert nhắc chủ hụi "Bạn cần thêm đủ {X} thành viên trước".

**File cần sửa:** `CreateHuiGroupView.swift`, `RoundDetailView.swift`

---

### BUG-03: Không thể edit kỳ hụi sau khi đã "Hoàn tất"
**Mô tả:** Sau khi bấm "Đóng kỳ hụi", dữ liệu bị đóng băng, không có cơ chế revert. Thực tế chủ hụi hay bấm nhầm hoặc muốn sửa lại.

**Hành vi mong muốn:**
- Thêm nút **"Mở lại kỳ"** (Reopen) khi Round status là `.completed`.
- Reopen sẽ đổi trạng thái về `.active`, giữ nguyên dữ liệu payment để chủ hụi chỉnh sửa.

**File cần sửa:** `RoundDetailView.swift`

---

## 🟠 Major Improvements (Thay đổi kiến trúc lớn)

### IMP-01: Hệ thống Account & Authentication (Quan trọng nhất)

**Vấn đề hiện tại:**
- MVP chỉ dùng `@AppStorage("selectedRole")` để giả lập 2 vai trò trên cùng 1 thiết bị.
- Member side hiện tại đang **show toàn bộ dây hụi** của chủ hụi, không có phân tách dữ liệu theo từng người.

**Thiết kế mới:**

```
User Account
├── Profile: name, phone, avatarURL
├── role: .host | .member (có thể kiêm cả 2!)
└── ownedGroups: [HuiGroup]    ← chỉ Host mới có
    memberOf: [HuiMembership]  ← Member tham chiếu dây hụi qua MemberShip ID
```

**Luồng đăng nhập:**
- Tầng Local MVP: Tạo màn hình tạo Profile khi lần đầu mở app, lưu `currentUser` vào UserDefaults/SwiftData.
- Tầng tương lai: SwiftData + CloudKit Sync (hoặc Supabase) để Share dữ liệu giữa Host và nhiều Member device khác nhau.

**Cụ thể cần làm:**

```
Phase A — Local Account:
├── Màn hình "Tạo hồ sơ" (onboarding lần đầu)
│   ├── Nhập Tên, SĐT
│   └── Chọn vai trò ưu tiên: Chủ Hụi / Người Chơi
├── Model User lưu vào SwiftData
├── ContentView check: if currentUser == nil → Onboarding, else → Dashboard
└── Mỗi HuiGroup phải gắn ownerID (User.id của người tạo)
```

---

### IMP-02: Phân quyền Member — Chỉ thấy dây hụi mình tham gia

**Vấn đề:** Member hiện tại xem `@Query` tất cả `HuiGroup`, vô tình thấy cả những dây hụi của người khác.

**Giải pháp:**
Tạo model `HuiMembership` như một bảng join:
```swift
@Model class HuiMembership {
    var user: User         // người chơi
    var group: HuiGroup    // dây hụi họ tham gia
    var joinedAt: Date
    var memberEntry: HuiMember  // thông tin gốc của member trong dây
}
```

Member Dashboard sẽ Query: `HuiMembership.filter { $0.user.id == currentUser.id }`

---

### IMP-03: Validation logic nghiệp vụ đầy đủ

| Hành động | Điều kiện cho phép |
|-----------|-------------------|
| Tạo dây hụi | baseAmount > 0, totalRounds ≥ 2 |
| Bắt đầu thu kỳ | `members.count == totalRounds` |
| Chọn người hốt | Chỉ người chưa bao giờ hốt |
| Đóng kỳ | Tất cả payments đều `isPaid == true` |
| Sang kỳ tiếp | Kỳ trước phải `status == .completed` |

---

## 🟡 UX Improvements

### UX-01: Màn hình Tạo dây hụi — Thêm member ngay lúc tạo
**Hiện tại:** Tạo dây hụi xong, phải vào Detail → Bấm Thành viên → thêm từng người.
**Cải tiến:** Tích hợp bước thêm thành viên ngay trong `CreateHuiGroupView` (step-by-step flow: Bước 1 thông tin, Bước 2 Thêm thành viên).

### UX-02: Dashboard thực tế thay vì số hardcode
- Host Dashboard: Đọc từ SwiftData thực tế: tổng số dây đang active, tổng số người chưa đóng tiền kỳ này.
- Member Dashboard: Tổng tiền đã đóng, đã nhận, lời/lỗ thực tế từ dữ liệu Payment.

### UX-03: Sắp xếp thứ tự thanh toán trong Round
**Hiện tại:** Danh sách thành viên trong kỳ hiện ra ngẫu nhiên, khó quan sát.
**Cải tiến:** Đẩy người **chưa đóng lên đầu** (sort: isPaid == false lên trước), và hiển thị đậm màu đỏ.

---

## Implementation Order (Thứ tự ưu tiên xử lý)

```
Sprint 2 — Fixes & Validation
├── [BUG-01] Block Đóng kỳ khi chưa thu đủ
├── [BUG-02] Validate đủ thành viên trước khi thu kỳ
├── [BUG-03] Tính năng Mở lại kỳ (Reopen)
└── [UX-03] Sort thành viên chưa đóng lên đầu

Sprint 3 — Account System (Local)
├── [IMP-01] Model User + Onboarding screen
├── Gắn ownerID vào HuiGroup
└── Lưu currentUser vào SwiftData

Sprint 4 — Proper Member Separation
├── [IMP-02] Model HuiMembership
├── Member chỉ thấy dây hụi mình tham gia
└── [UX-01] Tạo dây hụi multi-step (gồm thêm member)

Sprint 4 — Dashboard thực tế & Financial Insights
├── [UX-02] Dashboard đọc dữ liệu thực từ SwiftData (Tổng tiền đóng, Tổng lãi)
├── [IMP-04] Tính toán "Tổng tiền dự kiến hốt" cho Member
└── [UX-04] Timeline lịch sử đóng hụi chi tiết (Tiền + Lãi từng kỳ)

Sprint 5 — Advanced Winning Flow
├── [IMP-05] Thêm "Tiền thảo" (Phí quản lý) và "Tiền thăm" (Bỏ thầu) vào logic hốt
├── [UX-05] Phân loại Hốt sớm / Hốt chót
└── [IMP-06] Trường "Ghi chú" cho từng dây hụi

Sprint 6 — Utility & Safety
├── [UX-06] Hệ thống Thùng rác (Trash) để khôi phục dây hụi đã xoá
├── [UX-07] Phân loại Hụi sống / Hụi đã hoàn thành (Archive)
└── [UX-08] Tìm kiếm dây hụi
```

---

## 🔵 "Sổ Hụi" App Analysis Insights (Reference for Design)

Dựa trên screenshot app đối thủ, chúng ta cần học tập các điểm sau:
1. **Financial Focus**: Người dùng quan tâm nhất là "Lời bao nhiêu" và "Khi nào hốt được bao nhiêu".
2. **Visual Timeline**: Thay vì chỉ check-box, hãy hiển thị số tiền chênh lệch (lãi) ngay tại từng kỳ.
3. **Safety**: Luôn có Thùng rác để tránh mất dữ liệu quan trọng.
4. **Customization**: Thêm Ghi chú để cá nhân hoá mục tiêu chơi hụi.
