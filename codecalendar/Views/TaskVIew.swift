//
//  TaskView.swift
//  codecalendar
//
//  Created by Cam on 11/22/25.
//

import SwiftUI
import SwiftData

struct TaskView: View {
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var expandToday = true
    @State private var expandNextWeek = true
    @State private var expandLater = true
    
    private let calendar = Calendar.current
    
    // MARK: - Task Grouping
    private var todayTasks: [Task] {
        tasks.filter { task in
            !task.completed && calendar.isDateInToday(task.dueDate)
        }
        .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var nextWeekTasks: [Task] {
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        return tasks.filter { task in
            !task.completed &&
            task.dueDate > today &&
            task.dueDate <= nextWeek &&
            !calendar.isDateInToday(task.dueDate)
        }
        .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var laterTasks: [Task] {
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date())!
        
        return tasks.filter { task in
            !task.completed && task.dueDate > nextWeek
        }
        .sorted { $0.dueDate < $1.dueDate }
    }
    
    private var completedTasks: [Task] {
        tasks.filter { $0.completed }
            .sorted { ($0.completedDate ?? $0.dueDate) > ($1.completedDate ?? $1.dueDate) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    if tasks.isEmpty {
                        emptyStateView
                    } else {
                        // Today Section
                        TaskSectionCard(
                            title: "Today",
                            icon: "sun.max.fill",
                            color: .orange,
                            tasks: todayTasks,
                            isExpanded: $expandToday
                        )
                        
                        // Next Week Section
                        TaskSectionCard(
                            title: "Next 7 Days",
                            icon: "calendar",
                            color: .blue,
                            tasks: nextWeekTasks,
                            isExpanded: $expandNextWeek
                        )
                        
                        // Later Section
                        TaskSectionCard(
                            title: "Later",
                            icon: "clock.fill",
                            color: .purple,
                            tasks: laterTasks,
                            isExpanded: $expandLater
                        )
                        
                        // Completed Section
                        if !completedTasks.isEmpty {
                            completedSection
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("My Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Task Overview")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Stay organized and on track")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Stats badge
                let pendingCount = tasks.filter { !$0.completed }.count
                if pendingCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                        Text("\(pendingCount) pending")
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
                    .foregroundColor(.accentColor)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Completed Section
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("\(completedTasks.count) tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(completedTasks.prefix(10)) { task in
                    completedTaskRow(task)
                }
                
                if completedTasks.count > 10 {
                    Text("+\(completedTasks.count - 10) more completed tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
        .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Empty State
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
                
                Image(systemName: "checklist")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 8) {
                Text("No Tasks Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first task to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
    
    // MARK: - Helper Functions
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
    
    private func completedTaskRow(_ task: Task) -> some View {
        NavigationLink {
            EditTaskView(task: task)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        if let completedDate = task.completedDate {
                            Text("Completed \(completedDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Task Section Card Component
struct TaskSectionCard: View {
    let title: String
    let icon: String
    let color: Color
    let tasks: [Task]
    @Binding var isExpanded: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(color.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                            )
                        
                        Image(systemName: icon)
                            .font(.subheadline)
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                        )
                )
            }
            .buttonStyle(.plain)
            
            // Content
            if isExpanded && !tasks.isEmpty {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskRowView(task: task)
                    }
                }
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            } else if isExpanded && tasks.isEmpty {
                emptyState
            }
        }
    }
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("No tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .transition(.opacity)
    }
}

// MARK: - Task Row Component (Reusable)
struct TaskRowView: View {
    let task: Task
    @AppStorage("isDarkMode") private var isDarkMode = false
    
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
    
    var body: some View {
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
}

#Preview {
    TaskView()
        .modelContainer(for: [Project.self, Task.self])
}
