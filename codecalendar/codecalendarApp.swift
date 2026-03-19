//
//  codecalendarApp.swift
//  codecalendar
//

import SwiftUI
import SwiftData

@main
struct DevDashApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("accentColor") private var accentColor = "blue"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                MainTabView()
                    .tint(colorFromString(accentColor))
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        .modelContainer(for: [Project.self, Task.self])
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
