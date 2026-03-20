//
//  HomeView.swift
//  codecalendar
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Project.dueDate) private var projects: [Project]
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    @AppStorage("userName") private var userName = ""
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var selectedProjectlist = "Recents"
    let projectListOptions = ["Recents", "Starred"]
    
    @State private var selectedTasklist = "Due Soon"
    let projectTasklist = ["Due Soon", "Overdue"]
    
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    @State private var showingTemplatePicker = false
    @State private var selectedProgressProject: Project? = nil
    
    // MARK: - Computed Properties (unchanged)
    private var displayedProjects: [Project] {
        let sorted = projects.sorted { $0.createdDate > $1.createdDate }
        if selectedProjectlist == "Starred" {
            return sorted.filter { $0.starred }
        }
        return sorted
    }
    
    private var displayedTasks: [Task] {
        let sorted = tasks.sorted { $0.dueDate < $1.dueDate }
        if selectedTasklist == "Overdue" {
            let today = Calendar.current.startOfDay(for: Date())
            return sorted.filter { !$0.completed && $0.dueDate <= today }
        }
        return sorted
    }
    
    private var progressTasks: [Task] {
        guard let project = selectedProgressProject else { return [] }
        return project.tasks
    }
    
    private var completedCount: Int { progressTasks.filter { $0.completed }.count }
    private var overdueCount: Int { progressTasks.filter { !$0.completed && $0.dueDate < Date() }.count }
    private var dueCount: Int { progressTasks.filter { !$0.completed && $0.dueDate >= Date() }.count }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with greeting
                    headerSection
                    
                    // Projects Section
                    projectsSection
                    
                    // Progress Section
                    progressSection
                    
                    // Tasks Section
                    tasksSection
                    
                    // Calendar Section
                    calendarSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateProject) { CreateProjectView() }
            .sheet(isPresented: $showingCreateTask) { CreateTaskView(projects: projects) }
            .sheet(isPresented: $showingTemplatePicker) { TemplatePickerView() }
            .onAppear {
                if selectedProgressProject == nil {
                    selectedProgressProject = projects.first
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good Afternoon")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text(userName.isEmpty ? "User" : userName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Avatar placeholder with dark mode support
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: isDarkMode ? 1 : 0)
                    )
                    .overlay(
                        Text(userName.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    )
            }
            
            HeaderView()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Projects Section
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Projects",
                systemImage: "folder.fill",
                pickerSelection: $selectedProjectlist,
                options: projectListOptions
            )
            
            if displayedProjects.isEmpty {
                // Empty state with template option INSIDE the same card
                emptyStateView(
                    icon: "folder.badge.plus",
                    message: selectedProjectlist == "Starred" ? "No starred projects" : "No projects yet",
                    primaryButtonTitle: "Create Project",
                    primaryAction: { showingCreateProject = true },
                    secondaryButtonTitle: "Start from Template",
                    secondaryAction: { showingTemplatePicker = true },
                    secondaryIcon: "square.on.square"
                )
            } else {
                // Horizontal scroll of project cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(displayedProjects) { project in
                            projectCard(project)
                        }
                        
                        // "Quick Create" cards section
                        HStack(spacing: 12) {
                            // New Project card
                            Button {
                                showingCreateProject = true
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.1))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: isDarkMode ? 1 : 0)
                                            )
                                        
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .foregroundColor(.accentColor)
                                    }
                                    
                                    Text("New Project")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(width: 160, height: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                        )
                                )
                            }
                            
                            // Template card
                            Button {
                                showingTemplatePicker = true
                            } label: {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.1))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.purple.opacity(0.3), lineWidth: isDarkMode ? 1 : 0)
                                            )
                                        
                                        Image(systemName: "square.on.square")
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Text("From Template")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.purple)
                                }
                                .frame(width: 160, height: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                        )
                                )
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private func projectCard(_ project: Project) -> some View {
        NavigationLink {
            EditProjectView(project: project)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Icon with dark mode support
                    ZStack {
                        Circle()
                            .fill(project.starred ? Color.yellow.opacity(0.15) : Color.accentColor.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(project.starred ? Color.yellow.opacity(0.3) : Color.accentColor.opacity(0.3),
                                            lineWidth: isDarkMode ? 1 : 0)
                            )
                        
                        Image(systemName: project.starred ? "star.fill" : "folder.fill")
                            .font(.title3)
                            .foregroundColor(project.starred ? .yellow : .accentColor)
                    }
                    
                    Spacer()
                    
                    // Menu
                    Menu {
                        Button {
                            project.starred.toggle()
                        } label: {
                            Label(project.starred ? "Unstar" : "Star", systemImage: "star")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(project.details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Due date
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(project.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Progress indicator with dark mode support
                if !project.tasks.isEmpty {
                    let completed = project.tasks.filter { $0.completed }.count
                    let total = project.tasks.count
                    let percentage = total > 0 ? Double(completed) / Double(total) : 0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(completed)/\(total)")
                                .font(.caption2)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(Int(percentage * 100))%")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray4))
                                    .frame(width: geometry.size.width, height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.accentColor)
                                    .frame(width: geometry.size.width * percentage, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            .padding(16)
            .frame(width: 200, height: 220)
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
        .buttonStyle(.plain)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Progress",
                systemImage: "chart.line.uptrend.xyaxis",
                trailingContent: {
                    Picker("Project", selection: $selectedProgressProject) {
                        Text("Select Project").tag(Project?.none)
                        ForEach(projects) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.accentColor)
                }
            )
            
            if let project = selectedProgressProject {
                VStack(spacing: 20) {
                    // Project header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(project.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Due \(project.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Circular progress with dark mode support
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 8)
                                .frame(width: 70, height: 70)
                            
                            let total = project.tasks.count
                            let completed = project.tasks.filter { $0.completed }.count
                            let percentage = total > 0 ? Double(completed) / Double(total) : 0
                            
                            Circle()
                                .trim(from: 0, to: percentage)
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(percentage * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    // Stats grid with dark mode support
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        statCard(title: "Completed", value: "\(completedCount)", color: .green)
                        statCard(title: "Overdue", value: "\(overdueCount)", color: .red)
                        statCard(title: "Due", value: "\(dueCount)", color: .orange)
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
                .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            } else {
                Text("Select a project to see progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
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
        }
    }
    
    // MARK: - Tasks Section
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Tasks",
                systemImage: "checklist",
                pickerSelection: $selectedTasklist,
                options: projectTasklist
            )
            
            if displayedTasks.isEmpty {
                emptyStateView(
                    icon: "checklist",
                    message: selectedTasklist == "Overdue" ? "No overdue tasks" : "All caught up!",
                    primaryButtonTitle: "Create Task",
                    primaryAction: { showingCreateTask = true }
                    // No secondary button for tasks
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(displayedTasks.prefix(5)) { task in
                        taskRow(task)
                    }
                    
                    if displayedTasks.count > 5 {
                        NavigationLink {
                            // Full tasks view
                            Text("All Tasks")
                        } label: {
                            Text("See All (\(displayedTasks.count))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                                        )
                                )
                        }
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
                            .textSelection(.enabled)  // This makes links selectable and tappable
                    }
                    
                    // Due date
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(task.dueDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                        
                        if task.dueDate < Date() && !task.completed {
                            Text("• Overdue")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundColor(task.dueDate < Date() && !task.completed ? .red : .secondary)
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
    
    private func attributedDescription(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Find all URLs in the text
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

    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Calendar", systemImage: "calendar")
            
            CalendarView()
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, systemImage: String, pickerSelection: Binding<String>? = nil, options: [String]? = nil, trailingContent: (() -> AnyView)? = nil) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let pickerSelection = pickerSelection, let options = options {
                Picker("", selection: pickerSelection) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            
            if let trailingContent = trailingContent {
                trailingContent()
            }
        }
    }
    
    private func sectionHeader(title: String, systemImage: String, trailingContent: @escaping () -> some View) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            trailingContent()
        }
    }
    
    private func emptyStateView(
        icon: String,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil,
        secondaryIcon: String? = nil
    ) -> some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            // Message
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Primary button
            Button(action: primaryAction) {
                Text(primaryButtonTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
            }
            
            // Secondary button (if provided)
            if let secondaryButtonTitle = secondaryButtonTitle,
               let secondaryAction = secondaryAction {
                
                Divider()
                    .background(Color(.separator))
                    .padding(.horizontal, 40)
                
                Button(action: secondaryAction) {
                    HStack(spacing: 8) {
                        if let secondaryIcon = secondaryIcon {
                            Image(systemName: secondaryIcon)
                                .font(.subheadline)
                        }
                        Text(secondaryButtonTitle)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.purple.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                )
        )
        .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    private func statCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: isDarkMode ? 0.5 : 0)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Project.self, Task.self])
}
