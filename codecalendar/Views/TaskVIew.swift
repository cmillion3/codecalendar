//
//  TaskVIew.swift
//  codecalendar
//
//  Created by Cam on 11/22/25.
//

import SwiftUI

struct TaskVIew: View {
    @State private var expandToday = true
    @State private var expandNextWeek = false
    @State private var expandLater = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("My Task")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Do Today
                SectionCard {
                    DisclosureGroup(isExpanded: $expandToday) {
                        // Placeholder for future task list
                        EmptyStateRow(title: "No tasks for today yet.")
                    } label: {
                        Label("Do Today", systemImage: "sun.max")
                            .font(.headline)
                    }
                }

                // Do Next Week
                SectionCard {
                    DisclosureGroup(isExpanded: $expandNextWeek) {
                        // Placeholder for future task list
                        EmptyStateRow(title: "No tasks for next week yet.")
                    } label: {
                        Label("Do Next Week", systemImage: "calendar")
                            .font(.headline)
                    }
                }

                // Do Later
                SectionCard {
                    DisclosureGroup(isExpanded: $expandLater) {
                        // Placeholder for future task list
                        EmptyStateRow(title: "No tasks for later yet.")
                    } label: {
                        Label("Do Later", systemImage: "clock")
                            .font(.headline)
                    }
                }
            }
            .padding()
        }
    }
}

private struct SectionCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
                .animation(.default, value: UUID()) // simple expand/collapse animation
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

private struct EmptyStateRow: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tray")
                .foregroundColor(.secondary)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TaskVIew()
}
