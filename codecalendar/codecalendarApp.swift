//
//  codecalendarApp.swift
//  codecalendar
//
//  Created by Cam on 11/20/25.
//

import SwiftUI
import SwiftData

@main
struct DevDashApp: App {
    @AppStorage("accentColor") private var accentColor = "blue"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(colorFromString(accentColor))
                .preferredColorScheme(isDarkMode ? .dark : .light)
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
        default: return .blue
        }
    }
}

