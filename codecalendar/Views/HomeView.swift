import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Project.dueDate) private var projects: [Project]
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    
    @State private var selectedProjectlist = "Recents"
    let projectListOptions = ["Recents", "Starred"]
    
    @State private var selectedTasklist = "Due Soon"
    let projectTasklist = ["Due Soon", "Overdue"]
    
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    @State private var selectedProject: Project? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Good Afternoon, user!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Projects Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("Projects").font(.headline)
                            Spacer()
                            Picker("Options", selection: $selectedProjectlist) {
                                ForEach(projectListOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                        }
                        
                        if projects.isEmpty {
                            Image(systemName: "tray.full")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("When you view projects, the most recent one will show up here!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(projects) { project in
                                    NavigationLink {
                                        EditProjectView(project: project)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(project.name)
                                                .font(.headline)
                                            Text(project.details)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text("Due \(project.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
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
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Tasks Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("My Tasks").font(.headline)
                            Spacer()
                            Picker("Options", selection: $selectedTasklist) {
                                ForEach(projectTasklist, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                        }
                        
                        if tasks.isEmpty {
                            Image(systemName: "checklist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            Text("You're all caught up on tasks this week!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(tasks) { task in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(task.name)
                                            .font(.headline)
                                        Text(task.details)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
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
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Navigation and Sheets
                    .sheet(isPresented: $showingCreateProject) {
                        CreateProjectView()
                    }
                    .sheet(isPresented: $showingCreateTask) {
                        CreateTaskView(projects: projects)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView()
}
