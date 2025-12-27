//
//  OnboardingView.swift
//  codecalendar
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("accentColor") private var accentColor = "blue"
    
    @State private var currentStep = 0
    @State private var tempName = ""
    @State private var tempColor = "blue"
    
    let colors = [
        ("blue", "Blue", Color.blue),
        ("green", "Green", Color.green),
        ("orange", "Orange", Color.orange),
        ("purple", "Purple", Color.purple),
        ("red", "Red", Color.red),
        ("teal", "Teal", Color.teal),
        ("indigo", "Indigo", Color.indigo),
        ("mint", "Mint", Color.mint)
    ]
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorFromString(tempColor).opacity(0.1),
                    .white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentStep ? colorFromString(tempColor) : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 40)
                
                // Content area
                TabView(selection: $currentStep) {
                    welcomeStep
                        .tag(0)
                    
                    nameStep
                        .tag(1)
                    
                    colorStep
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.spring()) {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(colorFromString(tempColor))
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 2 ? "Get Started" : "Next") {
                        if currentStep == 2 {
                            completeOnboarding()
                        } else {
                            withAnimation(.spring()) {
                                currentStep += 1
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(colorFromString(tempColor))
                    .cornerRadius(12)
                    .disabled(currentStep == 1 && tempName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Steps
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 80))
                .foregroundColor(colorFromString(tempColor))
            
            VStack(spacing: 16) {
                Text("Welcome to DevDash")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Your personal project management companion for students and developers")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "folder.badge.plus",
                    color: colorFromString(tempColor),
                    title: "Manage Projects",
                    description: "Organize tasks into projects with deadlines"
                )
                
                FeatureRow(
                    icon: "chart.bar.fill",
                    color: colorFromString(tempColor),
                    title: "Track Progress",
                    description: "Visualize your completion rates and stay on schedule"
                )
                
                FeatureRow(
                    icon: "sparkles",
                    color: colorFromString(tempColor),
                    title: "Learning Resources",
                    description: "Access curated developer tools and tutorials"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
    }
    
    private var nameStep: some View {
        VStack(spacing: 40) {
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(colorFromString(tempColor))
            
            VStack(spacing: 16) {
                Text("What should we call you?")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("This will appear in your greeting")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                TextField("Enter your name", text: $tempName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 30)
                
                Text("You can change this later in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            if !userName.isEmpty {
                tempName = userName
            }
        }
    }
    
    private var colorStep: some View {
        VStack(spacing: 40) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60))
                .foregroundColor(colorFromString(tempColor))
            
            VStack(spacing: 16) {
                Text("Choose Your Color")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Pick an accent color for your app")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(colors, id: \.0) { color in
                    ColorOption(
                        color: color.2,
                        name: color.1,
                        isSelected: tempColor == color.0
                    ) {
                        tempColor = color.0
                    }
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal, 20)
        .onAppear {
            if !accentColor.isEmpty {
                tempColor = accentColor
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func completeOnboarding() {
        // Save user preferences
        if !tempName.trimmingCharacters(in: .whitespaces).isEmpty {
            userName = tempName.trimmingCharacters(in: .whitespaces)
        }
        
        accentColor = tempColor
        hasCompletedOnboarding = true
    }
    
    private func colorFromString(_ color: String) -> Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "teal": return .teal
        case "indigo": return .indigo
        case "mint": return .mint
        default: return .blue
        }
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

struct ColorOption: View {
    let color: Color
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 60, height: 60)
                    
                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                
                Text(name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
}