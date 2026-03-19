
//
//  DataManager.swift
//  codecalendar
//
//  Created by Cameron on 12/26/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Combine

// MARK: - Export Data Models
struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let projects: [ExportProject]
    
    static let currentVersion = "1.0"
}

struct ExportProject: Codable {
    let id: UUID
    let name: String
    let details: String
    let dueDate: Date
    let createdDate: Date
    let complete: Bool
    let starred: Bool
    let tasks: [ExportTask]
}

struct ExportTask: Codable {
    let id: UUID
    let name: String
    let details: String
    let dueDate: Date
    let effortScore: Int
    let completed: Bool
    let completedDate: Date?
}

// MARK: - UTType for our data
extension UTType {
    static var codecalendarData: UTType {
        UTType(exportedAs: "com.codecalendar.data")
    }
}

// MARK: - Data Manager
@MainActor
final class DataManager: ObservableObject {
    var modelContext: ModelContext   
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Export
    
    func exportData() throws -> Data {
        // Fetch all projects and their tasks
        let descriptor = FetchDescriptor<Project>()
        let projects = try modelContext.fetch(descriptor)
        
        // Convert to export format
        let exportProjects = projects.map { project in
            ExportProject(
                id: project.id,
                name: project.name,
                details: project.details,
                dueDate: project.dueDate,
                createdDate: project.createdDate,
                complete: project.complete,
                starred: project.starred,
                tasks: project.tasks.map { task in
                    ExportTask(
                        id: task.id,
                        name: task.name,
                        details: task.details,
                        dueDate: task.dueDate,
                        effortScore: task.effortScore,
                        completed: task.completed,
                        completedDate: task.completedDate
                    )
                }
            )
        }
        
        let exportData = ExportData(
            version: ExportData.currentVersion,
            exportDate: Date(),
            projects: exportProjects
        )
        
        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(exportData)
    }
    
    func saveExportToFile(data: Data) -> URL? {
        // Create a safe date string: "2026-03-18_12-17-00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let filename = "DevDash_Backup_\(dateString)"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
            .appendingPathExtension("devdash")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to save export: \(error)")
            return nil
        }
    }
    
    // MARK: - Import
    
    func importData(from url: URL) throws {
        let data = try Data(contentsOf: url)
        
        // Decode the data
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let importData = try decoder.decode(ExportData.self, from: data)
        
        // Validate version
        guard importData.version == ExportData.currentVersion else {
            throw ImportError.unsupportedVersion
        }
        
        // Import each project and its tasks
        for exportProject in importData.projects {
            let project = Project(
                id: exportProject.id,
                name: exportProject.name,
                details: exportProject.details,
                dueDate: exportProject.dueDate,
                createdDate: exportProject.createdDate,
                complete: exportProject.complete,
                starred: exportProject.starred
            )
            
            modelContext.insert(project)
            
            for exportTask in exportProject.tasks {
                let task = Task(
                    id: exportTask.id,
                    name: exportTask.name,
                    details: exportTask.details,
                    dueDate: exportTask.dueDate,
                    effortScore: exportTask.effortScore,
                    completed: exportTask.completed,
                    completedDate: exportTask.completedDate
                )
                
                task.project = project
                project.tasks.append(task)
                modelContext.insert(task)
            }
        }
        
        try modelContext.save()
    }
    
    enum ImportError: Error, LocalizedError {
        case unsupportedVersion
        case invalidFormat
        
        var errorDescription: String? {
            switch self {
            case .unsupportedVersion:
                return "This backup was created with a different version of the app"
            case .invalidFormat:
                return "The file format is invalid or corrupted"
            }
        }
    }
    
    // MARK: - Clear Completed Tasks
    
    func clearCompletedTasks() throws {
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate { $0.completed == true })
        let completedTasks = try modelContext.fetch(descriptor)
        
        for task in completedTasks {
            modelContext.delete(task)
        }
        
        try modelContext.save()
    }
    
    // MARK: - Delete All Data
    
    func deleteAllData() throws {
        // Delete all tasks first (due to relationships)
        let taskDescriptor = FetchDescriptor<Task>()
        let allTasks = try modelContext.fetch(taskDescriptor)
        for task in allTasks {
            modelContext.delete(task)
        }
        
        // Delete all projects
        let projectDescriptor = FetchDescriptor<Project>()
        let allProjects = try modelContext.fetch(projectDescriptor)
        for project in allProjects {
            modelContext.delete(project)
        }
        
        try modelContext.save()
    }
}
