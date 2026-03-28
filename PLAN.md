# HuiCircle — MVP Plan

> App quản lý hụi: hỗ trợ **Chủ hụi (Host)** và **Người chơi (Member)**
> Tech: SwiftUI + SwiftData (local) + MVVM | Started: 2026-03-28

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| Architecture | MVVM |
| Data | SwiftData (local) |
| Platform | iOS 17+ |

---

## Project Structure

```
HuiCircle/
├── App/
│   └── HuiCircleApp.swift          ← entry point, ModelContainer
├── Models/                          ← SwiftData @Model
│   ├── User.swift
│   ├── HuiGroup.swift               ← Dây hụi
│   ├── HuiMember.swift              ← Thành viên
│   ├── HuiRound.swift               ← Kỳ hụi
│   └── Payment.swift                ← Thanh toán
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── HuiGroupViewModel.swift
│   ├── RoundViewModel.swift
│   └── MemberViewModel.swift
├── Views/
│   ├── Shared/                      ← Reusable components
│   │   ├── HuiCardView.swift
│   │   ├── StatusBadge.swift
│   │   ├── SectionHeader.swift
│   │   └── EmptyStateView.swift
│   ├── Host/
│   │   ├── HostDashboardView.swift
│   │   ├── HuiGroupListView.swift
│   │   ├── HuiGroupDetailView.swift
│   │   ├── CreateHuiGroupView.swift
│   │   ├── RoundDetailView.swift
│   │   └── MemberListView.swift
│   └── Member/
│       ├── MemberDashboardView.swift
│       ├── MyGroupsView.swift
│       └── GroupDetailMemberView.swift
├── Services/
│   └── MockDataService.swift        ← seed data cho demo
└── Resources/
    └── DesignTokens.swift           ← colors, fonts, spacing
```

---

## Data Models

### HuiGroup — Dây hụi
| Field | Type | Mô tả |
|-------|------|--------|
| `id` | UUID | |
| `name` | String | Tên dây hụi |
| `baseAmount` | Double | Tiền gốc mỗi kỳ |
| `totalRounds` | Int | Số kỳ = số thành viên |
| `startDate` | Date | Ngày bắt đầu |
| `frequency` | Enum | `.monthly` / `.weekly` |
| `status` | Enum | `.active` / `.completed` / `.paused` |

### HuiMember — Thành viên
| Field | Type | Mô tả |
|-------|------|--------|
| `id` | UUID | |
| `name` | String | Tên |
| `phone` | String | SĐT |
| `hasWon` | Bool | Đã hốt chưa |
| `wonRound` | Int? | Hốt kỳ nào |

### HuiRound — Kỳ hụi
| Field | Type | Mô tả |
|-------|------|--------|
| `roundNumber` | Int | Kỳ số mấy |
| `dueDate` | Date | Hạn đóng |
| `winner` | HuiMember? | Người hốt |
| `bidAmount` | Double | Số tiền bid |
| `status` | Enum | `.pending` / `.active` / `.completed` |

### Payment — Thanh toán
| Field | Type | Mô tả |
|-------|------|--------|
| `amount` | Double | Số tiền đóng |
| `paidAt` | Date? | Ngày đóng (nil = chưa đóng) |
| `isPaid` | Bool | Trạng thái |
| `roundNumber` | Int | Kỳ tương ứng |

---

## Business Logic

```swift
// Số tiền mỗi người phải đóng kỳ có bid
actualPayment = baseAmount - bidAmount

// Tiền người hốt nhận
receivedAmount = totalMembers × actualPayment
```

---

## Screens

### Host (Chủ hụi)
```
TabView
├── 🏠 Dashboard       ← tổng quan, cảnh báo ai chưa đóng
├── 📋 Dây Hụi         ← list + detail + tạo mới
│   └── RoundDetail    ← đánh dấu đóng tiền, chọn người hốt
└── ⚙️  Cài đặt
```

### Member (Người chơi)
```
TabView
├── 🏠 Tổng quan       ← tiền cần đóng, lời/lỗ
└── 📋 Dây hụi của tôi ← timeline kỳ, lịch sử thanh toán
```

---

## Design System

- **Primary**: Gradient #4F46E5 → #7C3AED (xanh-tím)
- **Accent**: #F59E0B (cam-vàng) cho warning/highlight
- **Cards**: rounded 16px, subtle shadow
- **Dark mode**: full support
- **Animations**: spring transitions, shimmer loading

---

## Implementation Progress

### Phase 1 — Setup
- [x] Folder structure (MVVM)
- [x] DesignTokens.swift
- [x] HuiCircleApp.swift (ModelContainer + role selection)

### Phase 2 — Models
- [x] HuiGroup.swift
- [x] HuiMember.swift
- [x] HuiRound.swift
- [x] Payment.swift
- [x] MockDataService.swift (seed data)

### Phase 3 — Shared Components
- [x] HuiCardView
- [x] StatusBadge
- [x] SectionHeader
- [x] EmptyStateView

### Phase 4 — Host Views
- [x] HostDashboardView
- [x] HuiGroupListView
- [x] HuiGroupDetailView
- [x] CreateHuiGroupView
- [x] RoundDetailView
- [x] MemberListView

### Phase 5 — Member Views
- [x] MemberDashboardView
- [x] MyGroupsView
- [x] GroupDetailMemberView

### Phase 6 — Polish
- [x] Animations & transitions
- [x] Empty states
- [x] Build & run on Simulator
