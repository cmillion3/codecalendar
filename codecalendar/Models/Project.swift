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
}
