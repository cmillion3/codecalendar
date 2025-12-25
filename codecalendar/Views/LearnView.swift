//
//  LearnView.swift
//  codecalendar
//

import SwiftUI

struct LearnView: View {
    @State private var selectedCategory: ResourceCategory = .programming
    
    enum ResourceCategory: String, CaseIterable {
        case programming = "Programming"
        case tools = "Tools"
        case design = "Design"
        case productivity = "Productivity"
        case career = "Career"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Learning Resources")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Hand-picked resources for developers and students")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ResourceCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Disclaimer
                    Text("These are third-party resources. We're not affiliated with nor endorse these sites.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Resources List
                    LazyVStack(spacing: 12) {
                        ForEach(resources(for: selectedCategory)) { resource in
                            ResourceCard(resource: resource)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func resources(for category: ResourceCategory) -> [LearningResource] {
        switch category {
        case .programming:
            return programmingResources
        case .tools:
            return toolResources
        case .design:
            return designResources
        case .productivity:
            return productivityResources
        case .career:
            return careerResources
        }
    }
}

// MARK: - Resource Card
struct ResourceCard: View {
    let resource: LearningResource
    
    var body: some View {
        Link(destination: resource.url) {
            HStack(spacing: 16) {
                // Icon/Image
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(resource.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: resource.icon)
                        .font(.title2)
                        .foregroundColor(resource.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(resource.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        ForEach(resource.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Data Models
struct LearningResource: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let url: URL
    let icon: String
    let color: Color
    let tags: [String]
}

// Sample Data
let programmingResources = [
    LearningResource(
        title: "freeCodeCamp",
        description: "Free coding tutorials and projects",
        url: URL(string: "https://freecodecamp.org")!,
        icon: "laptopcomputer",
        color: .green,
        tags: ["Tutorials", "Projects", "Free"]
    ),
    LearningResource(
        title: "MDN Web Docs",
        description: "Web development documentation by Mozilla",
        url: URL(string: "https://developer.mozilla.org")!,
        icon: "doc.text.fill",
        color: .orange,
        tags: ["Documentation", "Web", "Reference"]
    ),
    LearningResource(
        title: "LeetCode",
        description: "Practice coding interview questions",
        url: URL(string: "https://leetcode.com")!,
        icon: "brain.head.profile",
        color: .red,
        tags: ["Practice", "Interviews", "Algorithms"]
    )
]

let toolResources = [
    LearningResource(
        title: "GitHub",
        description: "Code hosting and collaboration",
        url: URL(string: "https://github.com")!,
        icon: "square.stack.3d.up.fill",
        color: .purple,
        tags: ["Version Control", "Open Source"]
    ),
    LearningResource(
        title: "Figma",
        description: "Collaborative design tool",
        url: URL(string: "https://figma.com")!,
        icon: "paintpalette.fill",
        color: .pink,
        tags: ["Design", "UI/UX", "Prototyping"]
    )
]

let designResources = [
    LearningResource(
        title: "Figma Community",
        description: "Free UI kits and design resources",
        url: URL(string: "https://figma.com/community")!,
        icon: "person.3.fill",
        color: .blue,
        tags: ["UI Kits", "Templates", "Free"]
    )
]

let productivityResources = [
    LearningResource(
        title: "Notion",
        description: "All-in-one workspace",
        url: URL(string: "https://notion.so")!,
        icon: "note.text",
        color: .gray,
        tags: ["Notes", "Organization", "Free Plan"]
    )
]

let careerResources = [
    LearningResource(
        title: "LinkedIn Learning",
        description: "Professional development courses (free trial)",
        url: URL(string: "https://linkedin.com/learning")!,
        icon: "briefcase.fill",
        color: .blue,
        tags: ["Courses", "Career", "30-day Trial"]
    )
]

#Preview {
    LearnView()
}