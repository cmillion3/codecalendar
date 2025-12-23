//
//  SettingsView.swift
//  codecalendar
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("reminderTime") private var reminderTime = 24 // hours before
    @AppStorage("enableOverdueAlerts") private var enableOverdueAlerts = true
    @AppStorage("enableWeeklyReports") private var enableWeeklyReports = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    NavigationLink("Accent Color") {
                        AccentColorPickerView()
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Task Reminders", isOn: $enableOverdueAlerts)
                    
                    if enableOverdueAlerts {
                        Picker("Remind Before", selection: $reminderTime) {
                            Text("1 hour").tag(1)
                            Text("6 hours").tag(6)
                            Text("12 hours").tag(12)
                            Text("24 hours").tag(24)
                            Text("2 days").tag(48)
                        }
                    }
                    
                    Toggle("Weekly Progress Reports", isOn: $enableWeeklyReports)
                    NavigationLink("Notification Schedule") {
                        NotificationScheduleView()
                    }
                }
                
                // Data Management
                Section("Data") {
                    NavigationLink("Backup & Export") {
                        BackupView()
                    }
                    NavigationLink("Privacy Settings") {
                        PrivacyView()
                    }
                    Button("Clear Completed Tasks") {
                        // Action
                    }
                    .foregroundColor(.red)
                }
                
                // About
                Section {
                    NavigationLink("Help & Tutorial") {
                        TutorialView()
                    }
                    NavigationLink("About DevDash") {
                        AboutView()
                    }
                    Link("Rate on App Store", destination: URL(string: "https://apps.apple.com")!)
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Supporting Views

struct AccentColorPickerView: View {
    @AppStorage("accentColor") private var accentColor = "blue"
    let colors = ["blue", "green", "orange", "purple", "red", "teal"]
    
    var body: some View {
        Form {
            Section("Choose Accent Color") {
                ForEach(colors, id: \.self) { color in
                    HStack {
                        Circle()
                            .fill(colorFromString(color))
                            .frame(width: 24, height: 24)
                        
                        Text(color.capitalized)
                        
                        Spacer()
                        
                        if accentColor == color {
                            Image(systemName: "checkmark")
                                .foregroundColor(colorFromString(color))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        accentColor = color
                    }
                }
            }
        }
        .navigationTitle("Accent Color")
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

struct NotificationScheduleView: View {
    @AppStorage("quietHoursStart") private var quietHoursStart = 22 // 10 PM
    @AppStorage("quietHoursEnd") private var quietHoursEnd = 8 // 8 AM
    @AppStorage("enableQuietHours") private var enableQuietHours = false
    
    var body: some View {
        Form {
            Toggle("Enable Quiet Hours", isOn: $enableQuietHours)
            
            if enableQuietHours {
                DatePicker("Quiet Hours Start",
                          selection: Binding(
                            get: { dateFromHour(quietHoursStart) },
                            set: { quietHoursStart = hourFromDate($0) }
                          ),
                          displayedComponents: .hourAndMinute)
                
                DatePicker("Quiet Hours End",
                          selection: Binding(
                            get: { dateFromHour(quietHoursEnd) },
                            set: { quietHoursEnd = hourFromDate($0) }
                          ),
                          displayedComponents: .hourAndMinute)
            }
            
            Section("Notification Types") {
                Toggle("Due Date Reminders", isOn: .constant(true))
                Toggle("Overdue Alerts", isOn: .constant(true))
                Toggle("Project Progress", isOn: .constant(true))
            }
        }
        .navigationTitle("Notification Schedule")
    }
    
    private func dateFromHour(_ hour: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func hourFromDate(_ date: Date) -> Int {
        Calendar.current.component(.hour, from: date)
    }
}

struct BackupView: View {
    var body: some View {
        Form {
            Section("Backup") {
                Button("Export All Data") {
                    // Export logic
                }
                Button("Create Backup") {
                    // Backup logic
                }
            }
            
            Section("Import") {
                Button("Import from Backup") {
                    // Import logic
                }
            }
        }
        .navigationTitle("Backup & Export")
    }
}

struct PrivacyView: View {
    @AppStorage("analyticsEnabled") private var analyticsEnabled = true
    
    var body: some View {
        Form {
            Section("Analytics") {
                Toggle("Share Usage Analytics", isOn: $analyticsEnabled)
                Text("Helps improve the app. No personal data is shared.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Data") {
                NavigationLink("View Collected Data") {
                    Text("Data summary here")
                }
                Button("Delete All Data") {
                    // Delete logic
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy")
    }
}

struct TutorialView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Getting Started")
                    .font(.title)
                    .bold()
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("1. Create Projects", systemImage: "folder.badge.plus")
                        .font(.headline)
                    Text("Organize your work into projects with due dates and details.")
                        .foregroundColor(.secondary)
                    
                    Label("2. Add Tasks", systemImage: "checklist")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Break down projects into manageable tasks with effort scores.")
                        .foregroundColor(.secondary)
                    
                    Label("3. Track Progress", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Use the Dashboard to monitor your completion rates and deadlines.")
                        .foregroundColor(.secondary)
                    
                    Label("4. Stay Organized", systemImage: "star.fill")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Star important projects and use filters to focus on what matters.")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
            }
            .padding()
        }
        .navigationTitle("Help & Tutorial")
    }
}

struct AboutView: View {
    var body: some View {
        Form {
            Section("App") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text("100")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Developer") {
                Label("Created by Cameron", systemImage: "person.fill")
                Link("Visit Website", destination: URL(string: "https://example.com")!)
            }
            
            Section("Open Source") {
                Text("DevDash is built with SwiftUI and SwiftData")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Link("View on GitHub", destination: URL(string: "https://github.com")!)
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    SettingsView()
}
