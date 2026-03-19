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
            
            LearnView()  // NEW TAB
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
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
        case "indigo": return .indigo
        case "pink": return Color(red: 255/255, green: 124/255, blue: 190/255)
        case "yellow": return .yellow
        default: return .blue
        }
    }
}
