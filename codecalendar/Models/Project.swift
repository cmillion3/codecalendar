//
//  Project.swift
//  codecalendar
//
//  Created by Cam on 11/24/25.
//

import Foundation
import SwiftData


@Model
final class Project {
    var name: String
    var details: String
    var dueDate: Date
    
    init(name: String, details: String, dueDate: Date) {
        self.name = name
        self.details = details
        self.dueDate = dueDate
    }
}
