//
//  codecalendarApp.swift
//  codecalendar
//
//  Created by Cam on 11/20/25.
//

import SwiftUI
import SwiftData

@main
struct codecalendarApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: Project.self)
    }
}
