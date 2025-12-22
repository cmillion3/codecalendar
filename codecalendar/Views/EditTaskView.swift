//
//  EditTaskView.swift
//  codecalendar
//
//  Created by Cameron on 12/19/25.
//


import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var task: Task      // same pattern as EditProjectView

    @Query(sort: \Project.dueDate) private var projects: [Project]

    var body: some View {
        Form {
            Section("Task Info") {
                TextField("Name", text: $task.name)
                TextField("Description", text: $task.details, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                DatePicker("Due Date", selection: $task.dueDate, displayedComponents: .date)
                Stepper("Effort: \(task.effortScore)", value: $task.effortScore, in: 1...10)
                Toggle("Completed", isOn: $task.completed)
                    .onChange(of: task.completed) { _, newValue in
                        task.completedDate = newValue ? Date() : nil
                    }
            }

            Section("Project") {
                Picker("Project", selection: Binding(
                    get: { task.project },
                    set: { newProject in
                        task.project = newProject
                    }
                )) {
                    Text("None").tag(Project?.none)
                    ForEach(projects) { project in
                        Text(project.name).tag(project as Project?)
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(task)
                    dismiss()
                } label: {
                    Text("Delete Task")
                }
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}
