//
//  EditProjectView.swift
//  codecalendar
//
//  Created by Cam on 12/8/25.
//

import SwiftUI
import SwiftData

struct EditProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var project: Project
    
    @State private var showingConfirmation = false
    @State private var pendingCompletionState = false

    var body: some View {
        Form {
            Section("Project Info") {
                TextField("Name", text: $project.name)
                TextField("Description", text: $project.details, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                DatePicker("Due Date", selection: $project.dueDate, displayedComponents: .date)
            }
            Section("Status") {
                Toggle("Completed", isOn: Binding(
                    get: { project.complete },
                    set: { newValue in
                        if newValue != project.complete {
                            pendingCompletionState = newValue
                            showingConfirmation = true
                        }
                    }
                ))
                
                HStack {
                    Image(systemName: project.starred ? "star.fill" : "star")
                        .foregroundColor(project.starred ? .yellow : .gray)
                        .font(.title2)
                    Text(project.starred ? "Starred" : "Not starred")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    project.starred.toggle()
                }
            }
            
            // Show task completion status
            if !project.tasks.isEmpty {
                Section("Tasks Progress") {
                    let completedCount = project.tasks.filter { $0.completed }.count
                    let totalCount = project.tasks.count
                    
                    HStack {
                        Text("\(completedCount)/\(totalCount) tasks completed")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if completedCount == totalCount {
                            Text("All done!")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if completedCount > 0 {
                            ProgressView(value: Double(completedCount), total: Double(totalCount))
                                .frame(width: 100)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Project")
        .alert(pendingCompletionState ? "Complete All Tasks?" : "Uncomplete All Tasks?", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {
                // Reset the toggle
                project.complete = !pendingCompletionState
            }
            Button(pendingCompletionState ? "Complete All" : "Uncomplete All", role: pendingCompletionState ? .none : .destructive) {
                if pendingCompletionState {
                    project.completeAllTasks()
                } else {
                    project.uncompleteAllTasks()
                }
            }
        } message: {
            if pendingCompletionState {
                Text("Marking this project as complete will also mark all \(project.tasks.count) tasks as completed. This action cannot be undone.")
            } else {
                Text("Marking this project as incomplete will also mark all \(project.tasks.count) tasks as incomplete. This action cannot be undone.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete") {
                    modelContext.delete(project)
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // Ensure project completion status matches tasks
                    project.updateCompletionFromTasks()
                    dismiss()
                }
            }
        }
    }
}
