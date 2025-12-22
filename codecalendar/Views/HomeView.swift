//
//  HomeView.swift
//  codecalendar
//

import SwiftUI
import SwiftData

struct HomeView: View {

    // Keep your existing queries, but we’ll filter/sort in computed properties
    @Query(sort: \Project.dueDate) private var projects: [Project]
    @Query(sort: \Task.dueDate) private var tasks: [Task]

    @State private var selectedProjectlist = "Recents"
    let projectListOptions = ["Recents", "Starred"]

    @State private var selectedTasklist = "Due Soon"
    let projectTasklist = ["Due Soon", "Overdue"]

    @State private var showingCreateProject = false
    @State private var showingCreateTask = false

    // Progress card: which project to show stats for
    @State private var selectedProgressProject: Project? = nil

    // MARK: - Filtering / Sorting

    private var displayedProjects: [Project] {
        // always sort by createdDate newest -> oldest
        let sorted = projects.sorted { $0.createdDate > $1.createdDate }

        if selectedProjectlist == "Starred" {
            return sorted.filter { $0.starred }
        } else {
            return sorted
        }
    }

    private var displayedTasks: [Task] {
        let sorted = tasks.sorted { $0.dueDate < $1.dueDate }

        if selectedTasklist == "Overdue" {
            // overdue = due date is today or earlier, and not completed
            let today = Calendar.current.startOfDay(for: Date())
            return sorted.filter { !$0.completed && $0.dueDate <= today }
        } else {
            // Due Soon = all tasks sorted by due date
            return sorted
        }
    }

    // MARK: - Progress counts

    private var progressTasks: [Task] {
        guard let project = selectedProgressProject else { return [] }
        return project.tasks
    }

    private var completedCount: Int {
        progressTasks.filter { $0.completed }.count
    }

    private var overdueCount: Int {
        let now = Date()
        return progressTasks.filter { !$0.completed && $0.dueDate < now }.count
    }

    private var dueCount: Int {
        let now = Date()
        return progressTasks.filter { !$0.completed && $0.dueDate >= now }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                HeaderView()
                VStack {
                    Text("Good Afternoon, user!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // MARK: Projects Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("Projects").font(.headline)
                            Spacer()
                            Picker("Options", selection: $selectedProjectlist) {
                                ForEach(projectListOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        if displayedProjects.isEmpty {
                            Image(systemName: "tray.full")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)

                            Text(selectedProjectlist == "Starred"
                                 ? "No starred projects yet."
                                 : "No projects yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(displayedProjects) { project in
                                    NavigationLink {
                                        EditProjectView(project: project)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: project.starred ? "star.fill" : "folder")
                                                .font(.title2)
                                                .foregroundColor(project.starred ? .yellow : .blue)
                                                .frame(width: 44, height: 44)
                                                .background((project.starred ? Color.yellow : Color.blue).opacity(0.12))
                                                .clipShape(Circle())

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(project.name)
                                                    .font(.headline)
                                                    .lineLimit(1)

                                                Text(project.details)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)

                                                Text("Due \(project.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .frame(height: 72)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }

                        Button {
                            showingCreateProject = true
                        } label: {
                            Text("Create New Project")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                    // MARK: Progress Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.headline)
                            Spacer()
                            Picker("Project", selection: $selectedProgressProject) {
                                Text("Select Project").tag(Project?.none)
                                ForEach(projects) { project in
                                    Text(project.name).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        if let project = selectedProgressProject {
                            HStack {
                                Text(project.name)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }

                            HStack {
                                VStack {
                                    Text("Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(completedCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)

                                VStack {
                                    Text("Overdue")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(overdueCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(overdueCount > 0 ? .red : .primary)
                                }
                                .frame(maxWidth: .infinity)

                                VStack {
                                    Text("Due")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(dueCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 8)
                        } else {
                            Text("Select a project to see its progress.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                    // MARK: Tasks Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("My Tasks").font(.headline)
                            Spacer()
                            Picker("Options", selection: $selectedTasklist) {
                                ForEach(projectTasklist, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        if displayedTasks.isEmpty {
                            Image(systemName: "checklist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)

                            Text(selectedTasklist == "Overdue"
                                 ? "No overdue tasks."
                                 : "You're all caught up on tasks!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(displayedTasks) { task in
                                    NavigationLink {
                                        EditTaskView(task: task)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Button {
                                                Task.toggleCompleted(task)
                                            } label: {
                                                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                                    .font(.title2)
                                                    .foregroundColor(task.completed ? .green : .secondary)
                                            }
                                            .buttonStyle(.plain)

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.name)
                                                    .font(.headline)
                                                    .lineLimit(1)

                                                Text(task.details)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)

                                                HStack {
                                                    Text("Effort: \(task.effortScore)")
                                                        .font(.caption)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Color.gray.opacity(0.2))
                                                        .clipShape(Capsule())

                                                    Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)

                                                    Spacer()
                                                }
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .frame(height: 72)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }

                        Button {
                            showingCreateTask = true
                        } label: {
                            Text("Create New Task")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
            .sheet(isPresented: $showingCreateTask) {
                CreateTaskView(projects: projects)
            }
            .onAppear {
                if selectedProgressProject == nil {
                    selectedProgressProject = projects.first
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
