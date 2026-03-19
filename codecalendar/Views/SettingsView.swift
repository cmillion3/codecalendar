//
//  SettingsView.swift
//  codecalendar
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UserNotifications

// MARK: - Import Strategy
enum ImportStrategy {
    case merge
    case replace
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("enableOverdueAlerts") private var enableOverdueAlerts = true
    @AppStorage("userName") private var userName = ""
    
    @Query private var tasks: [Task]

    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingImportOptions = false
    @State private var showingDeleteAlert = false
    @State private var showingClearAlert = false
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var exportURL: URL?
    @State private var importURL: URL?

    @StateObject private var dataManager: DataManager

    init() {
        let container = try! ModelContainer(for: Project.self, Task.self)
        let context = ModelContext(container)
        _dataManager = StateObject(wrappedValue: DataManager(modelContext: context))
    }

    // MARK: - Computed property for export document
    private var exportDocument: ExportDocument {
        if let url = exportURL, let data = try? Data(contentsOf: url) {
            return ExportDocument(data: data)
        } else {
            return ExportDocument(data: Data())
        }
    }

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

                // MARK: - Notifications (SIMPLIFIED)
                Section("Notifications") {
                    Toggle("Enable Task Reminders", isOn: $enableOverdueAlerts)
                        .onChange(of: enableOverdueAlerts) { _, newValue in
                            if newValue {
                                NotificationManager.shared.requestPermission { granted in
                                    if granted {
                                        // Reschedule all tasks
                                        for task in tasks {
                                            NotificationManager.shared.scheduleTaskReminders(for: task)
                                        }
                                    }
                                }
                            } else {
                                NotificationManager.shared.cancelAll()
                            }
                        }
                    
                    if enableOverdueAlerts {
                        Text("You'll get reminders at: 7 days, 3 days, 1 day, and day of at 9 AM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Profile Section
                Section("Profile") {
                    HStack {
                        Text("Display Name")
                        Spacer()
                        TextField("Your name", text: $userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }
                }

                // Onboarding Section
                Section("Onboarding") {
                    Button("Show Onboarding Again") {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                    .foregroundColor(.blue)
                }

                // MARK: - Data Management
                Section("Data Management") {
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        showingImportPicker = true
                    } label: {
                        HStack {
                            Label("Import Data", systemImage: "square.and.arrow.down")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Label("Clear Completed Tasks", systemImage: "checkmark.circle.badge.xmark")
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Label("Delete All Data", systemImage: "trash")
                            Spacer()
                        }
                    }
                }

                // About
                Section {
                    NavigationLink("Help & Tutorial") {
                        TutorialView()
                    }
                    NavigationLink("About Codecalendar") {
                        AboutView()
                    }
                    Link("Rate on App Store", destination: URL(string: "https://apps.apple.com")!)
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .fileExporter(
                isPresented: $showingExportSheet,
                document: exportDocument,
                contentType: .codecalendarData,
                defaultFilename: "Codecalendar_Backup"
            ) { result in
                switch result {
                case .success:
                    showSuccess(message: "Data exported successfully!")
                case .failure(let error):
                    showError(message: "Export failed: \(error.localizedDescription)")
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.codecalendarData, .json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importURL = url
                    showingImportOptions = true
                case .failure(let error):
                    showError(message: "Import failed: \(error.localizedDescription)")
                }
            }
            .alert("Import Options", isPresented: $showingImportOptions) {
                Button("Merge with existing") {
                    importData(strategy: .merge)
                }
                Button("Replace all data", role: .destructive) {
                    importData(strategy: .replace)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("How would you like to import this data?")
            }
            .alert("Clear Completed Tasks", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCompletedTasks()
                }
            } message: {
                Text("This will permanently delete all completed tasks. This action cannot be undone.")
            }
            .alert("Delete All Data", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all projects and tasks. This action cannot be undone.")
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successMessage)
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                dataManager.modelContext = modelContext
            }
        }
    }

    // MARK: - Data Management Methods
    @State private var successMessage = ""

    private func exportData() {
        do {
            let data = try dataManager.exportData()
            if let url = dataManager.saveExportToFile(data: data) {
                exportURL = url
                showingExportSheet = true
            } else {
                showError(message: "Failed to create export file")
            }
        } catch {
            showError(message: "Export failed: \(error.localizedDescription)")
        }
    }

    private func importData(strategy: ImportStrategy) {
        guard let url = importURL else { return }

        guard url.startAccessingSecurityScopedResource() else {
            showError(message: "Cannot access the selected file")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            if strategy == .replace {
                try dataManager.deleteAllData()
            }
            try dataManager.importData(from: url)
            showSuccess(message: "Data imported successfully!")
        } catch {
            showError(message: "Import failed: \(error.localizedDescription)")
        }
    }

    private func clearCompletedTasks() {
        do {
            try dataManager.clearCompletedTasks()
            showSuccess(message: "Completed tasks cleared successfully!")
        } catch {
            showError(message: "Failed to clear tasks: \(error.localizedDescription)")
        }
    }

    private func deleteAllData() {
        do {
            try dataManager.deleteAllData()
            showSuccess(message: "All data deleted successfully!")
        } catch {
            showError(message: "Failed to delete data: \(error.localizedDescription)")
        }
    }

    private func showSuccess(message: String) {
        successMessage = message
        showingSuccessAlert = true
    }

    private func showError(message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// MARK: - Supporting Views (keep these)
struct AccentColorPickerView: View {
    @AppStorage("accentColor") private var accentColor = "blue"
    let colors = ["blue", "green", "orange", "purple", "red", "teal", "indigo", "mint", "pink", "yellow"]

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
        case "indigo": return .indigo
        case "mint": return .mint
        case "pink": return Color(red: 255/255, green: 124/255, blue: 190/255)
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

// MARK: - Keep these existing views
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
                Text("Codecalendar is built with SwiftUI and SwiftData")
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
