import Foundation
import SwiftData

@Model
final class Task {
    @Attribute(.unique) var id: UUID
    var name: String
    var details: String
    var dueDate: Date
    var effortScore: Int
    var completed: Bool
    var completedDate: Date?
    var project: Project?

    init(
        id: UUID = UUID(),
        name: String,
        details: String,
        dueDate: Date,
        effortScore: Int,
        completed: Bool = false,
        completedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.dueDate = dueDate
        self.effortScore = effortScore
        self.completed = completed
        self.completedDate = completedDate
    }
}

extension Task {
    static func toggleCompleted(_ task: Task) {
        task.completed.toggle()
        if task.completed {
            task.completedDate = Date()
        } else {
            task.completedDate = nil
        }
    }
}

