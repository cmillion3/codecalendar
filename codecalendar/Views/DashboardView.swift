//
//  DashboardView.swift
//  codecalendar
//
//  Created by Cameron on 12/22/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.createdDate, order: .reverse) private var projects: [Project]
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    
    // State variables for sheet presentation
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    
    private var overdueTasks: [Task] { tasks.filter { !$0.completed && $0.dueDate < Date() } }
    
    @Query(sort: \Task.completedDate, order: .reverse)
    private var recentlyCompletedTasks: [Task]
    
    // Stats
    private var activeProjects: Int { projects.filter { !$0.complete }.count }
    private var totalTasks: Int { tasks.count }
    private var overdueCount: Int { overdueTasks.count }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Stats Cards
                    statsCardsSection
                    
                    // MARK: Quick Actions
                    quickActionsSection
                    
                    // MARK: Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            // Add sheets for creating tasks and projects
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
            .sheet(isPresented: $showingCreateTask) {
                CreateTaskView(projects: projects)
            }
        }
    }
    
    // MARK: - Stats Cards
    private var statsCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Active Projects",
                    value: "\(activeProjects)",
                    icon: "folder.badge.gear",
                    color: .blue
                )
                .frame(maxWidth: .infinity)
                
                StatCard(
                    title: "Total Tasks",
                    value: "\(totalTasks)",
                    icon: "checklist",
                    color: .indigo
                )
                .frame(maxWidth: .infinity)
                
                StatCard(
                    title: "Overdue",
                    value: "\(overdueCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 10) {
                QuickActionButton(
                    title: "New Project",
                    icon: "plus.circle.fill",
                    color: .blue
                ) {
                    showingCreateProject = true
                }
                
                QuickActionButton(
                    title: "New Task",
                    icon: "checkmark.circle.fill",
                    color: .green
                ) {
                    showingCreateTask = true
                }
                
                QuickActionButton(
                    title: "Mark all Overdue Tasks as Complete",
                    icon: "flag.fill",
                    color: .orange
                ) {
                    markOverdueTasksComplete()
                }
            }
        }
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
            
            if recentlyCompletedTasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.green.opacity(0.3))
                    
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentlyCompletedTasks.prefix(5)) { task in
                        ActivityRow(task: task)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Function
    private func markOverdueTasksComplete() {
        for task in overdueTasks {
            task.completed = true
            task.completedDate = Date()
        }
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Failed to mark tasks complete: \(error)")
        }
    }
}

// MARK: - Components
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ActivityRow: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(task.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(task.completedDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
}
