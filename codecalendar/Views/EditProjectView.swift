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

    var body: some View {
        Form {
            Section("Project Info") {
                TextField("Name", text: $project.name)
                TextField("Description", text: $project.details, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                DatePicker("Due Date", selection: $project.dueDate, displayedComponents: .date)
            }
            Section("Status") {
                Toggle("Completed", isOn: $project.complete)
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
        }
        .navigationTitle("Edit Project")
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
                    dismiss()
                }
            }
        }
    }
}

