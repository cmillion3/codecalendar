//
//  MainTabView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//

import SwiftUI

struct MainTabView: View {
    @AppStorage("accentColor") private var accentColor = "blue"
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
            
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(colorFromString(accentColor))
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
