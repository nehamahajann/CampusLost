//
//  SplashScreenView.swift
//  CampusLost
//
//  Created by Neha on 3/10/2026.
//
import SwiftUI

/// The launch splash screen — shown briefly before HomeView appears,
/// visualising the app's core idea: something lost becomes something found.
struct SplashScreenView: View {
    @State private var titleVisible = false
    @State private var iconVisible = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 6) {
                    Text("CampusLost")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    Text("Reuniting students with what they've lost")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : -8)

                lostToFoundGraphic
                    .frame(width: 220, height: 140)
                    .scaleEffect(iconVisible ? 1 : 0.85)
                    .opacity(iconVisible ? 1 : 0)

                Spacer()

                Text("LOST SOMETHING? FOUND SOMETHING?")
                    .font(.caption.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                    .opacity(titleVisible ? 1 : 0)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { titleVisible = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) { iconVisible = true }
        }
    }

    private var lostToFoundGraphic: some View {
        HStack(spacing: 24) {
            iconBubble(systemImage: "questionmark.circle.fill", color: AppTheme.lost)

            Image(systemName: "arrow.right")
                .font(.title2.weight(.bold))
                .foregroundStyle(.secondary)

            iconBubble(systemImage: "checkmark.circle.fill", color: AppTheme.found)
        }
    }

    private func iconBubble(systemImage: String, color: Color) -> some View {
        ZStack {
            Circle().fill(color.opacity(0.15)).frame(width: 84, height: 84)
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(color)
        }
    }
}
