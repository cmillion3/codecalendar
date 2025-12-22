//
//  MainTabView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//


import SwiftUI

struct MainTabView: View {
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
        .accentColor(.blue)
    }
}
