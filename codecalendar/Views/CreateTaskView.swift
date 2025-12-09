import SwiftUI
import SwiftData

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var details = ""
    @State private var dueDate = Date()
    @State private var effortScore = 5
    @State private var selectedProject: Project?

    let projects: [Project]

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Information") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $details, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    Stepper("Effort Score: \(effortScore)", value: $effortScore, in: 1...10)
                    Picker("Project", selection: $selectedProject) {
                        Text("None").tag(Project?.none)
                        ForEach(projects) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let task = Task(
                            name: name,
                            details: details,
                            dueDate: dueDate,
                            effortScore: effortScore
                        )
                        if let project = selectedProject {
                            task.project = project
                            project.tasks.append(task)
                        }
                        modelContext.insert(task)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateTaskView(projects: [])
}
