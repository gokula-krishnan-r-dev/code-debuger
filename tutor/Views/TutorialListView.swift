import SwiftUI

struct TutorialListView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(JSCategory.allCases, id: \.self) { category in
                    NavigationLink(value: category) {
                        CategoryRowView(category: category)
                    }
                }
            }
            .navigationTitle("JavaScript Tutorials")
        } content: {
            // Second column shows tutorials in selected category
            List(selection: $viewModel.selectedTutorial) {
                if let selectedCategory = viewModel.selectedCategory {
                    let filteredTutorials = viewModel.tutorialsForCategory(selectedCategory)
                    ForEach(filteredTutorials) { tutorial in
                        NavigationLink(value: tutorial) {
                            TutorialRowView(tutorial: tutorial)
                        }
                    }
                } else {
                    Text("Select a category")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(viewModel.selectedCategory?.rawValue ?? "Categories")
        } detail: {
            // Third column shows tutorial detail
            if let selectedTutorial = viewModel.selectedTutorial {
                TutorialDetailView(viewModel: viewModel, tutorial: selectedTutorial)
            } else {
                Text("Select a tutorial to begin")
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: viewModel.selectedCategory) { _ in
            // Clear selected tutorial when category changes
            viewModel.selectedTutorial = nil
        }
    }
}

struct CategoryRowView: View {
    let category: JSCategory
    
    var body: some View {
        HStack {
            Image(systemName: categoryIcon)
                .foregroundColor(categoryColor)
                .frame(width: 30)
            
            Text(category.rawValue)
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: String {
        switch category {
        case .basics:
            return "book.fill"
        case .functions:
            return "function"
        case .objects:
            return "cube.fill"
        case .arrays:
            return "list.bullet.rectangle"
        case .async:
            return "clock.fill"
        case .es6:
            return "sparkles"
        }
    }
    
    private var categoryColor: Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .purple
        case .objects:
            return .orange
        case .arrays:
            return .green
        case .async:
            return .red
        case .es6:
            return .indigo
        }
    }
}

struct TutorialRowView: View {
    let tutorial: JavaScriptTutorial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tutorial.title)
                .font(.headline)
            Text(tutorial.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                LevelBadgeView(level: tutorial.level)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct LevelBadgeView: View {
    let level: JavaScriptTutorial.Level
    
    var body: some View {
        Text(level.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(levelColor.opacity(0.2))
            .foregroundColor(levelColor)
            .cornerRadius(4)
    }
    
    private var levelColor: Color {
        switch level {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
}

// Helper function to convert TutorialCategory to JSCategory
func convertToJSCategory(_ category: TutorialCategory) -> JSCategory {
    switch category {
    case .basics:
        return .basics
    case .functions:
        return .functions
    case .objects:
        return .objects
    case .dom:
        return .arrays // Map DOM to Arrays
    case .async:
        return .async
    case .python:
        return .es6 // Map Python to ES6
    }
} 
