//
//  ProjectsView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Project.createdDate, order: .reverse) private var projects: [Project]
    
    @State private var selectedProject: Project?
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    @State private var showingTaskFilter = false
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
                VStack(spacing: 20) {
                    // Project Picker Header
                    VStack(spacing: 12) {
                        HStack {
                            Text("Projects")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                showingCreateProject = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        if projects.isEmpty {
                            emptyStateView
                        } else {
                            projectPickerSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if let project = selectedProject {
                        // Project Overview Card
                        projectOverviewCard(project: project)
                        
                        // Tasks Section
                        tasksSection(project: project)
                    } else if !projects.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder.badge.questionmark")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("Select a project to view details")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.accentColor.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No Projects Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first project to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingCreateProject = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Project")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    private var projectPickerSection: some View {
        VStack(spacing: 8) {
            Picker("Select Project", selection: $selectedProject) {
                ForEach(projects) { project in
                    Text(project.name)
                        .tag(project as Project?)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
    
    private func projectOverviewCard(project: Project) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: project.starred ? "star.fill" : "star")
                            .foregroundColor(project.starred ? .yellow : .gray)
                            .onTapGesture {
                                project.starred.toggle()
                            }
                        
                        Text(project.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text(project.details)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label("Due \(project.dueDate.formatted(date: .abbreviated, time: .omitted))",
                              systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(project.dueDate < Date() && !project.complete ? .red : .secondary)
                        
                        Spacer()
                        
                        Text("Created \(project.createdDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                NavigationLink {
                    EditProjectView(project: project)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
            }
            
            // Progress Stats
            HStack(spacing: 16) {
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
                    icon: "chart.bar.fill",
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
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: geometry.size.width, height: 10)
                                .foregroundColor(Color(.systemGray4))
                            
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: geometry.size.width * CGFloat(project.completionPercentage / 100), height: 10)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private func tasksSection(project: Project) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
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
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
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
                            .padding(6)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button {
                        showingCreateTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(.horizontal)
            
            let filteredTasks = filteredAndSortedTasks(for: project)
            
            if filteredTasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: selectedTaskFilter == .completed ? "checkmark.circle" : "list.bullet.clipboard")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(emptyTasksMessage(for: selectedTaskFilter))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if selectedTaskFilter != .all && selectedTaskFilter != .pending {
                        Button("Show All Tasks") {
                            selectedTaskFilter = .all
                        }
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTasks) { task in
                        NavigationLink {
                            EditTaskView(task: task)
                        } label: {
                            TaskRow(task: task, onToggleComplete: {
                                Task.toggleCompleted(task)
                            })
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func filteredAndSortedTasks(for project: Project) -> [Task] {
        let tasks = project.tasks
        
        // Filter
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
        
        // Sort
        switch sortOption {
        case .dueDate:
            return filteredTasks.sorted { $0.dueDate < $1.dueDate }
        case .effortScore:
            return filteredTasks.sorted { $0.effortScore > $1.effortScore }
        case .name:
            return filteredTasks.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }
    
    private func emptyTasksMessage(for filter: TaskFilter) -> String {
        switch filter {
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
}

// MARK: - Supporting Views

private struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TaskRow: View {
    let task: Task
    let onToggleComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleComplete) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.completed ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.name)
                        .font(.headline)
                        .strikethrough(task.completed, color: .secondary)
                        .foregroundColor(task.completed ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text("\(task.effortScore)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(task.dueDate < Date() && !task.completed ? .red : .secondary)
                    
                    Spacer()
                    
                    if task.completed, let completedDate = task.completedDate {
                        Text("Completed \(completedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
