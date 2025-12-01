//
//  CreateProjectView.swift
//  codecalendar
//
//  Created by Cam on 11/24/25.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var details = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Project Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $details, axis: .vertical).lineLimit(3, reservesSpace: true)
                    DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let project = Project(
                            name: name,
                            details: details,
                            dueDate: dueDate
                        )
                        modelContext.insert(project) // SwiftData autosaves on main run loop
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateProjectView()
}
