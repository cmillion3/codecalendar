import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var details: String
    var dueDate: Date
    var createdDate: Date
    var complete: Bool
    var starred: Bool = false
    @Relationship(deleteRule: .cascade) var tasks: [Task] = []

    init(
        id: UUID = UUID(),
        name: String,
        details: String,
        dueDate: Date,
        createdDate: Date = .now,
        complete: Bool = false,
        starred: Bool = false
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.dueDate = dueDate
        self.createdDate = createdDate
        self.complete = complete
        self.starred = starred
    }
    
    // Computed property to check if all tasks are completed
    var allTasksCompleted: Bool {
        guard !tasks.isEmpty else { return false }
        return tasks.allSatisfy { $0.completed }
    }
    
    // Update project completion status based on tasks
    func updateCompletionFromTasks() {
        let newCompletionStatus = allTasksCompleted
        if complete != newCompletionStatus {
            complete = newCompletionStatus
        }
    }
    
    // Mark all tasks as completed
    func completeAllTasks() {
        for task in tasks {
            if !task.completed {
                task.completed = true
                task.completedDate = Date()
            }
        }
        complete = true
    }
    
    // Mark all tasks as incomplete
    func uncompleteAllTasks() {
        for task in tasks {
            if task.completed {
                task.completed = false
                task.completedDate = nil
            }
        }
        complete = false
    }
}
