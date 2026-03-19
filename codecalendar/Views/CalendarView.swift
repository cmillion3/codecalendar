//
//  CalendarView.swift
//  codecalendar
//
//  Created by Cameron on 3/13/26.
//


//
//  CalendarView.swift
//  codecalendar
//
//  Created by Cameron on 12/26/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var tasks: [Task]
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingTaskList = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // Tasks grouped by date for quick lookup
    private var tasksByDate: [Date: [Task]] {
        Dictionary(grouping: tasks) { task in
            calendar.startOfDay(for: task.dueDate)
        }
    }
    
    // Dates that have tasks
    private var datesWithTasks: Set<Date> {
        Set(tasksByDate.keys)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month header with navigation
            monthHeaderView
            
            // Days of week header
            daysOfWeekView
            
            // Calendar grid
            calendarGridView
            
            // Selected date tasks preview
            if showingTaskList, let tasks = tasksByDate[calendar.startOfDay(for: selectedDate)], !tasks.isEmpty {
                selectedDateTasksView(tasks: tasks)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Subviews
    
    private var monthHeaderView: some View {
        HStack {
            Button {
                withAnimation(.spring()) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Text(monthYearString(from: currentMonth))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                withAnimation(.spring()) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private var daysOfWeekView: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGridView: some View {
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0-based for Sunday
        
        let totalCells = daysInMonth + firstWeekday
        let rows = (totalCells / 7) + (totalCells % 7 == 0 ? 0 : 1)
        
        return VStack(spacing: 8) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        let index = row * 7 + column
                        let dayNumber = index - firstWeekday + 1
                        
                        if dayNumber >= 1 && dayNumber <= daysInMonth {
                            let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDayOfMonth)!
                            let isToday = calendar.isDateInToday(date)
                            let hasTasks = datesWithTasks.contains(calendar.startOfDay(for: date))
                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                            
                            DayCell(
                                dayNumber: dayNumber,
                                date: date,
                                isToday: isToday,
                                hasTasks: hasTasks,
                                isSelected: isSelected
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedDate = date
                                    showingTaskList = true
                                }
                            }
                        } else {
                            // Empty cell for days from previous/next month
                            Color.clear
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                    }
                }
            }
        }
    }
    
    private func selectedDateTasksView(tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        showingTaskList = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(tasks.prefix(3)) { task in
                NavigationLink {
                    EditTaskView(task: task)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .strikethrough(task.completed, color: .secondary)
                                .foregroundColor(task.completed ? .secondary : .primary)
                            
                            if let project = task.project {
                                Text(project.name)
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        Spacer()
                        
                        if task.completed {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        } else {
                            Text("\(task.effortScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground).opacity(0.5))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            
            if tasks.count > 3 {
                Text("+\(tasks.count - 3) more tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Helper Methods
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let dayNumber: Int
    let date: Date
    let isToday: Bool
    let hasTasks: Bool
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Background for selected date
            if isSelected {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
            }
            
            // Day number
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(foregroundColor)
            
            // Task indicator dot
            if hasTasks {
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.5))
                    .frame(width: 4, height: 4)
                    .offset(y: 12)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(
            // Today indicator (ring)
            Group {
                if isToday && !isSelected {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1)
                        .frame(width: 36, height: 36)
                }
            }
        )
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .accentColor
        } else if isToday {
            return .accentColor
        } else {
            return .primary
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
        .modelContainer(for: [Task.self, Project.self])
}