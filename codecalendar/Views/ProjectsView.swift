//
//  ProjectsView.swift
//  codecalendar
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Query(sort: \Project.createdDate, order: .reverse) private var projects: [Project]
    
    @State private var selectedProject: Project?
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    @State private var selectedTaskFilter: TaskFilter = .all
    @State private var sortOption: TaskSortOption = .dueDate
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
        case overdue = "Overdue"
    }
    
    enum TaskSortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case effortScore = "Effort"
        case name = "Name"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with project selector
                    projectHeader
                    
                    if let project = selectedProject {
                        // Project Overview Card
                        projectOverviewCard(project)
                        
                        // Tasks Section with filters
                        tasksSection(project)
                    } else if !projects.isEmpty {
                        selectProjectPrompt
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateProject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
            .sheet(isPresented: $showingCreateTask) {
                if let project = selectedProject {
                    CreateTaskView(projects: [project])
                } else {
                    CreateTaskView(projects: projects)
                }
            }
            .onAppear {
                if selectedProject == nil && !projects.isEmpty {
                    selectedProject = projects.first
                }
            }
            .onChange(of: projects.count) { _, _ in
                // If the selected project is no longer in the list, reset it
                if let selected = selectedProject, !projects.contains(where: { $0.id == selected.id }) {
                    selectedProject = projects.first
                }
            }
        }
    }
    
    // MARK: - Helper Functions for Links
    private func attributedDescription(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        let pattern = "https?://[^\\s]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return attributedString
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        for match in matches.reversed() {
            let urlString = nsString.substring(with: match.range)
            if let url = URL(string: urlString) {
                let range = Range(match.range, in: text)!
                let attributedRange = AttributedString(text).range(of: urlString)!
                attributedString[attributedRange].link = url
                attributedString[attributedRange].foregroundColor = .accentColor
                attributedString[attributedRange].underlineStyle = .single
            }
        }
        
        return attributedString
    }
    
    // MARK: - Project Header
    private var projectHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            if projects.isEmpty {
                emptyStateView
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Project")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(projects) { project in
                            Button {
                                selectedProject = project
                            } label: {
                                HStack {
                                    Text(project.name)
                                    if selectedProject?.id == project.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedProject?.name ?? "Choose a project")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                )
                        )
                        .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: "folder.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 8) {
                Text("No Projects Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first project to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                showingCreateProject = true
            } label: {
                Text("Create Project")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
    }
    
    private var selectProjectPrompt: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: "folder.badge.questionmark")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Text("Select a project to view details")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
    }
    
    // MARK: - Project Overview Card
    private func projectOverviewCard(_ project: Project) -> some View {
        VStack(spacing: 20) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        // Star button
                        Button {
                            project.starred.toggle()
                        } label: {
                            Image(systemName: project.starred ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundColor(project.starred ? .yellow : .gray)
                        }
                        
                        Text(project.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text(project.details)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Edit button
                NavigationLink {
                    EditProjectView(project: project)
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            
            Divider()
                .background(Color(.separator))
            
            // Stats
            HStack(spacing: 20) {
                StatBadge(
                    title: "Tasks",
                    value: "\(project.tasks.count)",
                    icon: "checklist",
                    color: .blue
                )
                
                StatBadge(
                    title: "Completed",
                    value: "\(project.tasks.filter { $0.completed }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatBadge(
                    title: "Overdue",
                    value: "\(project.tasks.filter { !$0.completed && $0.dueDate < Date() }.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                StatBadge(
                    title: "Avg Effort",
                    value: String(format: "%.1f", project.tasks.map { Double($0.effortScore) }.average ?? 0),
                    icon: "bolt.fill",
                    color: .orange
                )
            }
            
            // Progress Bar
            if !project.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(project.completionPercentage))%")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    
                    ProgressView(value: project.completionPercentage / 100)
                        .tint(.accentColor)
                        .background(
                            ProgressView(value: project.completionPercentage / 100)
                                .background(Color(.systemGray5))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
        .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Tasks Section
    private func tasksSection(_ project: Project) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with filters
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Filter and Sort buttons
                HStack(spacing: 12) {
                    // Filter Menu
                    Menu {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            Button {
                                selectedTaskFilter = filter
                            } label: {
                                HStack {
                                    Text(filter.rawValue)
                                    if selectedTaskFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(selectedTaskFilter.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                )
                        )
                    }
                    
                    // Sort Menu
                    Menu {
                        ForEach(TaskSortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                    )
                            )
                    }
                    
                    // Add Task button
                    Button {
                        showingCreateTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            let filteredTasks = filteredAndSortedTasks(for: project)
            
            if filteredTasks.isEmpty {
                emptyTasksView
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredTasks) { task in
                        taskRow(task)
                    }
                }
            }
        }
    }
    
    private func taskRow(_ task: Task) -> some View {
        NavigationLink {
            EditTaskView(task: task)
        } label: {
            HStack(spacing: 16) {
                // Checkbox
                Button {
                    Task.toggleCompleted(task)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(task.completed ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(task.completed ? Color.green.opacity(0.1) : Color.clear)
                            )
                        
                        if task.completed {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(task.name)
                            .font(.headline)
                            .strikethrough(task.completed)
                            .foregroundColor(task.completed ? .secondary : .primary)
                        
                        Spacer()
                        
                        // Effort badge
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 8))
                            Text("\(task.effortScore)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                        )
                    }
                    
                    // Task description with clickable links
                    if !task.details.isEmpty {
                        Text(attributedDescription(task.details))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .textSelection(.enabled)
                    }
                    
                    // Due date and project
                    HStack(spacing: 8) {
                        Label(
                            task.dueDate.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                        .font(.caption2)
                        .foregroundColor(task.dueDate < Date() && !task.completed ? .red : .secondary)
                        
                        if let project = task.project {
                            Label(project.name, systemImage: "folder")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
            )
            .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private var emptyTasksView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: selectedTaskFilter == .completed ? "checkmark.circle" : "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text(emptyTasksMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if selectedTaskFilter != .all && selectedTaskFilter != .pending {
                Button("Show All Tasks") {
                    selectedTaskFilter = .all
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.1))
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
    }
    
    // MARK: - Helper Methods
    private var emptyTasksMessage: String {
        switch selectedTaskFilter {
        case .all:
            return "No tasks yet. Add your first task!"
        case .pending:
            return "No pending tasks"
        case .completed:
            return "No completed tasks yet"
        case .overdue:
            return "No overdue tasks. Great work!"
        }
    }
    
    private func filteredAndSortedTasks(for project: Project) -> [Task] {
        let tasks = project.tasks
        
        let filteredTasks: [Task]
        switch selectedTaskFilter {
        case .all:
            filteredTasks = tasks
        case .pending:
            filteredTasks = tasks.filter { !$0.completed }
        case .completed:
            filteredTasks = tasks.filter { $0.completed }
        case .overdue:
            filteredTasks = tasks.filter { !$0.completed && $0.dueDate < Date() }
        }
        
        switch sortOption {
        case .dueDate:
            return filteredTasks.sorted { $0.dueDate < $1.dueDate }
        case .effortScore:
            return filteredTasks.sorted { $0.effortScore > $1.effortScore }
        case .name:
            return filteredTasks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Extensions
extension Project {
    var completionPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedCount = tasks.filter { $0.completed }.count
        return Double(completedCount) / Double(tasks.count) * 100
    }
}

extension Array where Element == Double {
    var average: Double? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}

#Preview {
    ProjectsView()
        .modelContainer(for: [Project.self, Task.self])
}
