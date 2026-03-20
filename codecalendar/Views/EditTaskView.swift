//
//  EditTaskView.swift
//  codecalendar
//

import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode = false

    @Bindable var task: Task
    
    @Query(sort: \Project.dueDate) private var projects: [Project]
    
    // Helper function for clickable links
    private func attributedDescription(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
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

    var body: some View {
        Form {
            Section("Task Info") {
                TextField("Name", text: $task.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $task.details)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .scrollContentBackground(.hidden)
                    
                    // Preview of clickable links
                    if !task.details.isEmpty {
                        Divider()
                        Text("Preview:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(attributedDescription(task.details))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .padding(.vertical, 8)
                
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
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Edit Task")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EditTaskView(task: Task(
        name: "Sample Task",
        details: "This is a sample task with a link: https://example.com",
        dueDate: Date(),
        effortScore: 5
    ))
    .modelContainer(for: [Project.self, Task.self])
}
