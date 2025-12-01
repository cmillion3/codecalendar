//
//  HomeView.swift
//  codecalendar
//
//  Created by Cam on 11/20/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Project.dueDate) private var projects: [Project]
    
    @State private var selectedProjectlist = "Recents"
    let projectListOptions = ["Recents", "Starred"]
    
    @State private var selectedTasklist = "Due soon"
    let projectTasklist = ["Due Soon", "Overdue"]
    
    @State private var showingCreateProject = false
    
    var body: some View {
        ScrollView { // Enable vertical scrolling
            VStack { // content container
                Text("Good Afternoon, user!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                VStack(spacing: 8) {
                    HStack {
                        Text("Projects").font(.headline)
                        Spacer()
                        Picker("Options", selection: $selectedProjectlist) {
                            ForEach(projectListOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                    }
                    
                    if projects.isEmpty {
                        Image(systemName: "tray.full")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("When you view projects, the most recent one will show up here!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(projects) { project in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.name)
                                        .font(.headline)
                                    Text(project.details)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Due \(project.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    Button {
                        showingCreateProject = true
                    } label: {
                        Text("Create New Project")
                            .frame(maxWidth: .infinity) // Make label fill width
                            .padding(.vertical, 8) // thinner vertical padding
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .contentShape(Rectangle()) // Ensure the whole area is tappable
                    }
                    .cornerRadius(10) // Apply corner radius to the button
                    .frame(maxWidth: .infinity, alignment: .center) // keeps it full-width in the container
                    // .frame(height: 40) // Uncomment if you want a fixed thin height
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x:0, y:2)
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(4)
                        VStack(alignment: .leading) {
                            Text("This week's project progress")
                            Text("Quickly view a project's progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer() // optional: pushes content to the leading side
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // ensure leading alignment across full width

                    Button(action: {
                        print("Hello World")
                    }) {
                        Text("Select a project")
                            .frame(maxWidth: .infinity) // Make label fill width
                            .padding(.vertical, 8) // thinner vertical padding
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .contentShape(Rectangle()) // Ensure the whole area is tappable
                    }
                    .cornerRadius(10) // Apply corner radius to the button
                    .frame(maxWidth: .infinity, alignment: .center) // keeps it full-width in the container
                    // .frame(height: 40) // Uncomment if you want a fixed thin height
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x:0, y:2)
                VStack(spacing: 8) {
                    HStack {
                        Text("My Task").font(.headline)
                        Spacer()
                        Picker("Options", selection: $selectedTasklist) {
                            ForEach(projectTasklist, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                    }
                    Image(systemName: "checklist")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("You're all caught up on task this week! ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    Button(action: {
                        print("Hello World")
                    }) {
                        Text("Create task")
                            .frame(maxWidth: .infinity) // Make label fill width
                            .padding(.vertical, 8) // thinner vertical padding
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .contentShape(Rectangle()) // Ensure the whole area is tappable
                    }
                    .cornerRadius(10) // Apply corner radius to the button
                    .frame(maxWidth: .infinity, alignment: .center) // keeps it full-width in the container
                    // .frame(height: 40) // Uncomment if you want a fixed thin height
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x:0, y:2)
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(4)
                        Button(action: {
                            print("Hello World")
                        }) {
                            Text("Projects")
                                .padding(.vertical, 8) // thinner vertical padding
                                .contentShape(Rectangle()) // Ensure the whole area is tappable
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Image(systemName: "arrow.right.circle.dotted")
                    }
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(4)
                        Button(action: {
                            print("Hello World")
                        }) {
                            Text("Goals")
                                .padding(.vertical, 8) // thinner vertical padding
                                .contentShape(Rectangle()) // Ensure the whole area is tappable
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Image(systemName: "arrow.right.circle.dotted")
                    }
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(4)
                        Button(action: {
                            print("Hello World")
                        }) {
                            Text("Portfolio")
                                .padding(.vertical, 8) // thinner vertical padding
                                .contentShape(Rectangle()) // Ensure the whole area is tappable
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Image(systemName: "arrow.right.circle.dotted")
                    }
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(4)
                        Button(action: {
                            print("Hello World")
                        }) {
                            Text("Learn")
                                .padding(.vertical, 8) // thinner vertical padding
                                .contentShape(Rectangle()) // Ensure the whole area is tappable
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Image(systemName: "arrow.right.circle.dotted")
                    }
                }
                
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 5, x:0, y:2)
                
            }
            .padding() // keep outer padding inside the scrollable area
        }
        .sheet(isPresented: $showingCreateProject) {
            CreateProjectView()
        }
    }
}

#Preview {
    HomeView()
}
