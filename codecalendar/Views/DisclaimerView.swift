//
//  DisclaimerView.swift
//  codecalendar
//
//  Created by Cameron on 3/21/26.
//

import SwiftUI

struct DisclaimerView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.accentColor.opacity(0.05),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimating)
                
                // Title
                Text("Work in Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimating)
                
                // Disclaimer text
                VStack(spacing: 16) {
                    Text("This app is currently in active development and may contain:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Unexpected bugs & glitches", systemImage: "ant.fill")
                        Label("Missing features", systemImage: "exclamationmark.circle")
                        Label("Performance improvements in progress", systemImage: "gauge.medium")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
                    
                    Text("Your feedback helps make this app better!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    
                    Text("You can rate the app in Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .offset(y: isAnimating ? 0 : 30)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
                
                Spacer()
                
                // I Understand button
                Button {
                    hasAcceptedDisclaimer = true
                } label: {
                    Text("I Understand")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.accentColor)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .offset(y: isAnimating ? 0 : 40)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    DisclaimerView()
}
