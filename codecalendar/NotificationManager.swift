//
//  NotificationManager.swift
//  codecalendar
//

import UserNotifications
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // Request permission
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Schedule all 4 reminders for a task
    func scheduleTaskReminders(for task: Task) {
        guard !task.completed else { return }
        
        let dueDate = task.dueDate
        let calendar = Calendar.current
        
        // 7 days before at 9 AM
        if let sevenDays = calendar.date(byAdding: .day, value: -7, to: dueDate) {
            scheduleReminder(at: sevenDays, task: task, type: "7 days left")
        }
        
        // 3 days before at 9 AM
        if let threeDays = calendar.date(byAdding: .day, value: -3, to: dueDate) {
            scheduleReminder(at: threeDays, task: task, type: "3 days left")
        }
        
        // 1 day before at 9 AM
        if let oneDay = calendar.date(byAdding: .day, value: -1, to: dueDate) {
            scheduleReminder(at: oneDay, task: task, type: "1 day left")
        }
        
        // Day of at 9 AM
        if let dayOf = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dueDate) {
            scheduleReminder(at: dayOf, task: task, type: "due today")
        }
    }
    
    private func scheduleReminder(at date: Date, task: Task, type: String) {
        // Only schedule if date is in the future
        guard date > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📅 \(task.name)"
        content.body = "\(type) – \(task.details.isEmpty ? "Task reminder" : task.details)"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(task.id.uuidString)-\(type)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            }
        }
    }
    
    // Cancel all reminders for a task
    func cancelReminders(for task: Task) {
        let identifiers = [
            "\(task.id.uuidString)-7 days left",
            "\(task.id.uuidString)-3 days left",
            "\(task.id.uuidString)-1 day left",
            "\(task.id.uuidString)-due today"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // Cancel ALL notifications (for toggling off)
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
