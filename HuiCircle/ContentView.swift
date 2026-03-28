//
//  ContentView.swift
//  HuiCircle
//
//  Created by KhanhNguyen on 28/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedRole") private var selectedRole: String = ""
    
    var body: some View {
        Group {
            if selectedRole == "host" {
                HostDashboardView()
            } else if selectedRole == "member" {
                MemberDashboardView()
            } else {
                RoleSelectionView(selectedRole: $selectedRole)
            }
        }
        .onAppear {
            MockDataService.shared.seedDataIfNeeded(modelContext: modelContext)
        }
    }
}

struct RoleSelectionView: View {
    @Binding var selectedRole: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 80))
                .foregroundStyle(DesignTokens.Colors.gradient)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
            
            Text("HuiCircle")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
            
            Text("Bạn là ai?")
                .font(.title2)
                .foregroundColor(.secondary)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
            
            VStack(spacing: 20) {
                Button(action: {
                    withAnimation { selectedRole = "host" }
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Chủ Hụi (Host)")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignTokens.Colors.primaryStart)
                    .foregroundColor(.white)
                    .cornerRadius(DesignTokens.Defaults.cornerRadius)
                }
                .shadow(color: DesignTokens.Colors.primaryStart.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4), value: isAnimating)
                
                Button(action: {
                    withAnimation { selectedRole = "member" }
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Người Chơi (Member)")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignTokens.Colors.cardBackground)
                    .foregroundColor(.primary)
                    .cornerRadius(DesignTokens.Defaults.cornerRadius)
                }
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: isAnimating)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: HuiGroup.self, inMemory: true)
}
