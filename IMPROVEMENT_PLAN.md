# HuiCircle — Unified Improvement Plan (v3)

> Sau khi phân tích app đối thủ và tối ưu UX (Bỏ Onboarding/Account), đây là lộ trình tập trung vào tính cá nhân hoá và độ chính xác tài chính.
> Updated: 2026-03-29

---

## 🟢 Phase 1: Fix Business Logic (Hoàn thành)
*Những lỗi này khiến app bị sai lệch dữ liệu tài chính.*

- [x] **BUG-01: Chốt kỳ hụi an toàn** (`RoundDetailView.swift`)
    - Disabled nút "Đóng kỳ hụi" nếu chưa thu đủ 100% tiền.
    - Thêm xác nhận popup nếu muốn ép đóng.
- [x] **BUG-02: Kiểm soát số lượng thành viên**
    - Kiểm soát: Chỉ cho phép "Bắt đầu thu kỳ 1" khi danh sách thành viên đã đủ (Hội đủ tay mới chơi).
- [x] **BUG-03: Tính năng Reopen (Mở lại kỳ)**
    - Cho phép chủ hụi mở lại kỳ đã đóng để sửa lỗi nhập liệu.

---

## 🟠 Phase 2: Financial Engine (Linh hồn của App)
*Biến app từ một danh sách "To-do" thành một công cụ tài chính thực thụ.*

- **IMP-04: Thuật toán tính Lãi/Lỗ**
    - `Profit = BaseAmount - ActualPayment`.
    - Hiển thị con số Lãi (xanh) hoặc Lỗ cho từng kỳ đóng hụi ngay trên Dashboard.
- **IMP-05: Dashboard thực tế (MainDashboardView)**
    - Thay thế số code cứng (0đ) bằng logic Query từ SwiftData.
    - Tính "Tổng tiền đã đóng" trên toàn app.
    - Tính "Tổng tiền dự kiến hốt" (Expected Return).
- **UX-04: Timeline lịch sử chi tiết**
    - Thay giao diện checkbox đơn điệu bằng danh sách lịch sử có số tiền, ngày tháng, và tiền lãi.

---

## 🟡 Phase 3: Advanced Winning Flow
*Nghiệp vụ sâu cho dân chơi hụi chuyên nghiệp.*

- **IMP-06: Chi phí quản lý (Tiền thảo)**
    - Thêm trường nhập "Tiền thảo" khi Host chốt người hốt. Số tiền này sẽ được trừ vào tổng tiền người hốt nhận được.
- **UX-05: Tinh gọn việc "Hốt hụi"**
    - Tự động phân loại Hốt chót / Hốt sớm.
    - Thêm trường nhập "Tiền thăm" (Bid Amount) trực quan hơn.
- **IMP-07: Ghi chú (Notes)**
    - Cho phép nhập ghi chú mục đích chơi cho từng dây hụi (Vd: "Tiền mua xe", "Hụi nhà cô Bảy").

---

## 🟢 Phase 4: Utility & Safety
*Hoàn thiện trải nghiệm người dùng.*

- **UX-06: Thùng rác (Trash Bin)**
    - Thay vì xoá vĩnh viễn, hãy đưa dây hụi vào thùng rác để có thể khôi phục.
- **UX-07: Lưu trữ (Archive)**
    - Phân loại dây hụi "Đang chạy" và "Đã kết thúc" để Dashboard gọn gàng.
- **UX-08: Tìm kiếm & Lọc**
    - Tìm nhanh tên dây hụi hoặc tên thành viên.

---

## Roadmap triển khai (Sprints)

1. **Sprint 4 (Hôm nay):** Hoàn thiện **Phase 1** (Fix Bugs) và một phần **Phase 2** (Dashboard thực tế).
2. **Sprint 5:** Tập trung vào **Financial Engine** (Tính lãi lỗ, dự kiến hốt).
3. **Sprint 6:** Nâng cấp **Winning Flow** và **Trash Bin**.
