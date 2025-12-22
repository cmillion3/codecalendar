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
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Project.self, Task.self])
    }
}

