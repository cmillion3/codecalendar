//
//  TemplatePickerView.swift
//  codecalendar
//
//  Created by Cameron on 3/19/26.
//


//
//  TemplatePickerView.swift
//  codecalendar
//
//  Created by Cameron on 3/19/26.
//

import SwiftUI
import SwiftData

struct TemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let templates = ProjectTemplateManager.shared.templates
    
    @State private var selectedDifficulty: String = "All"
    let difficulties = ["All", "Beginner", "Intermediate", "Advanced"]
    
    var filteredTemplates: [ProjectTemplate] {
        if selectedDifficulty == "All" {
            return templates
        } else {
            return templates.filter { $0.difficulty.rawValue == selectedDifficulty }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose a Template")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Start with a pre-built project structure. All tasks will be created with reasonable due dates based on today.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Difficulty filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(difficulties, id: \.self) { difficulty in
                                Button {
                                    withAnimation {
                                        selectedDifficulty = difficulty
                                    }
                                } label: {
                                    Text(difficulty)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedDifficulty == difficulty ? 
                                                      difficultyColor(difficulty).opacity(0.2) : 
                                                      Color(.systemGray5))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(selectedDifficulty == difficulty ? 
                                                       difficultyColor(difficulty).opacity(0.5) : 
                                                       Color.clear, lineWidth: 1)
                                        )
                                        .foregroundColor(selectedDifficulty == difficulty ? 
                                                         difficultyColor(difficulty) : .primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Templates grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(template: template) {
                                createProject(from: template)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Beginner": return .green
        case "Intermediate": return .orange
        case "Advanced": return .red
        default: return .accentColor
        }
    }
    
    private func createProject(from template: ProjectTemplate) {
        // Calculate due date based on estimated days
        let projectDueDate = Calendar.current.date(byAdding: .day, value: template.estimatedDays, to: Date()) ?? Date()
        
        // Create the project
        let project = Project(
            name: template.name,
            details: template.description,
            dueDate: projectDueDate,
            createdDate: Date(),
            complete: false,
            starred: false
        )
        
        modelContext.insert(project)
        
        // Create tasks with sequential due dates
        var currentDate = Date()
        for templateTask in template.tasks {
            // Add estimated hours to current date for this task's due date
            if let taskDueDate = Calendar.current.date(byAdding: .hour, value: templateTask.estimatedHours, to: currentDate) {
                
                let task = Task(
                    name: templateTask.name,
                    details: buildTaskDescription(from: templateTask),
                    dueDate: taskDueDate,
                    effortScore: templateTask.effortScore,
                    completed: false
                )
                
                task.project = project
                project.tasks.append(task)
                modelContext.insert(task)
                
                // Update current date for next task
                currentDate = taskDueDate
            }
        }
        
        // Save context
        try? modelContext.save()
        
        // Schedule notifications if enabled
        if UserDefaults.standard.bool(forKey: "enableOverdueAlerts") {
            for task in project.tasks {
                NotificationManager.shared.scheduleTaskReminders(for: task)
            }
        }
        
        dismiss()
    }
    
    private func buildTaskDescription(from templateTask: TemplateTask) -> String {
        var description = templateTask.description
        
        if let links = templateTask.resourceLinks, !links.isEmpty {
            description += "\n\n📚 Resources:\n"
            for link in links {
                description += "• \(link)\n"
            }
        }
        
        return description
    }
}

struct TemplateCard: View {
    let template: ProjectTemplate
    let onSelect: () -> Void
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and difficulty
                HStack(alignment: .top) {
                    ZStack {
                        Circle()
                            .fill(Color(template.color).opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(Color(template.color).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                            )
                        
                        Image(systemName: template.icon)
                            .font(.title3)
                            .foregroundColor(Color(template.color))
                    }
                    
                    Spacer()
                    
                    // Difficulty badge
                    Text(template.difficulty.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(template.difficulty.color).opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(template.difficulty.color).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                )
                        )
                        .foregroundColor(Color(template.difficulty.color))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Footer with stats
                HStack {
                    // Tasks count
                    Label("\(template.tasks.count) tasks", systemImage: "checklist")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Estimated days
                    Label("\(template.estimatedDays) days", systemImage: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
            )
            .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TemplatePickerView()
}