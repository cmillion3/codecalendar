//
//  codecalendarApp.swift
//  codecalendar
//

import SwiftUI
import SwiftData

@main
struct DevDashApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false
    @AppStorage("accentColor") private var accentColor = "blue"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            if !hasAcceptedDisclaimer {
                DisclaimerView()
                    .tint(colorFromString(accentColor))
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else if !hasCompletedOnboarding {
                OnboardingView()
                    .tint(colorFromString(accentColor))
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
        case "pink": return Color(red: 255/255, green: 124/255, blue: 190/255)
        case "yellow": return .yellow
        default: return .blue
        }
    }
}
