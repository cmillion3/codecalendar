//
//  DashboardView.swift
//  codecalendar
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode = false

    @Query(sort: \Project.createdDate, order: .reverse) private var projects: [Project]
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    
    @State private var showingCreateProject = false
    @State private var showingCreateTask = false
    
    private var overdueTasks: [Task] { tasks.filter { !$0.completed && $0.dueDate < Date() } }
    
    @Query(sort: \Task.completedDate, order: .reverse)
    private var recentlyCompletedTasks: [Task]
    
    private var activeProjects: Int { projects.filter { !$0.complete }.count }
    private var totalTasks: Int { tasks.count }
    private var overdueCount: Int { overdueTasks.count }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome header
                    welcomeHeader
                    
                    // Stats Grid
                    statsGrid
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCreateProject) { CreateProjectView() }
            .sheet(isPresented: $showingCreateTask) { CreateTaskView(projects: projects) }
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Your productivity dashboard")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Active Projects",
                value: "\(activeProjects)",
                icon: "folder.badge.gear",
                color: .blue
            )
            
            StatCard(
                title: "Total Tasks",
                value: "\(totalTasks)",
                icon: "checklist",
                color: .indigo
            )
            
            StatCard(
                title: "Overdue",
                value: "\(overdueCount)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Quick Actions", systemImage: "bolt.fill")
            
            HStack(spacing: 12) {
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
                    title: "Complete Overdue",
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
            sectionHeader(title: "Recent Activity", systemImage: "clock.fill")
            
            if recentlyCompletedTasks.isEmpty {
                emptyActivityView
            } else {
                VStack(spacing: 12) {
                    ForEach(recentlyCompletedTasks.prefix(5)) { task in
                        ActivityRow(task: task)
                    }
                }
            }
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Text("No recent activity")
                .font(.body)
                .foregroundColor(.secondary)
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
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Function
    private func markOverdueTasksComplete() {
        for task in overdueTasks {
            task.completed = true
            task.completedDate = Date()
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to mark tasks complete: \(error)")
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                        )
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
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

// MARK: - Activity Row
struct ActivityRow: View {
    let task: Task
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.3), lineWidth: isDarkMode ? 0.5 : 0)
                    )
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(task.details)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(task.completedDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
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
        .shadow(color: isDarkMode ? .clear : Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
}
