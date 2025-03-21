import SwiftUI

struct JSHomeView: View {
    @StateObject private var viewModel = JSCodeViewModel()
    @State private var selectedCategory: JSCategory?
    @State private var selectedLevel: JavaScriptTutorial.Level?
    @State private var selectedExecution: JSCodeExecution?
    @State private var showExecutionPlayground = false
    @State private var showCodeVisualizer = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedCategory) {
                // Category filters
                Section(header: Text("Categories")) {
                    ForEach(JSCategory.allCases, id: \.self) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: iconName(for: category))
                                .foregroundColor(categoryColor(for: category))
                        }
                    }
                }
                
                // Difficulty levels
                Section(header: Text("Levels")) {
                    NavigationLink(destination: TutorialListByLevelView(viewModel: viewModel, level: .beginner)) {
                        Label("Beginner", systemImage: "1.circle")
                            .foregroundColor(.green)
                    }
                    
                    NavigationLink(destination: TutorialListByLevelView(viewModel: viewModel, level: .intermediate)) {
                        Label("Intermediate", systemImage: "2.circle")
                            .foregroundColor(.orange)
                    }
                    
                    NavigationLink(destination: TutorialListByLevelView(viewModel: viewModel, level: .advanced)) {
                        Label("Advanced", systemImage: "3.circle")
                            .foregroundColor(.red)
                    }
                }
                
                // Code execution playground
                Section(header: Text("Playground")) {
                    Button(action: {
                        self.showCodeVisualizer = true
                    }) {
                        Label("JavaScript Visualizer", systemImage: "play.circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        self.selectedExecution = JSCodeExecution.allExecutions.first
                        self.showExecutionPlayground = true
                    }) {
                        Label("Code Executor", systemImage: "terminal")
                            .foregroundColor(.purple)
                    }
                }
                
                // Settings
                Section(header: Text("Settings")) {
                    Toggle(isOn: $viewModel.codeHighlighted) {
                        Label("Syntax Highlighting", systemImage: "highlighter")
                    }
                    
                    Toggle(isOn: $viewModel.isDarkMode) {
                        Label("Dark Mode", systemImage: viewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("JS Tutor")
        } content: {
            // Content column - show tutorials for selected category or featured tutorials
            if let category = viewModel.selectedCategory {
                JSCategoryTutorialListView(viewModel: viewModel, category: category)
            } else {
                FeaturedTutorialsView(viewModel: viewModel)
            }
        } detail: {
            // Detail column - show selected tutorial details
            if let selectedTutorial = viewModel.selectedTutorial {
                TutorialDetailView(viewModel: viewModel, tutorial: selectedTutorial)
            } else {
                Text("Select a tutorial to begin")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
        .sheet(isPresented: $showExecutionPlayground) {
            if let execution = selectedExecution {
                JSCodeExecutionView(execution: execution)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .sheet(isPresented: $showCodeVisualizer) {
            JSCodeVisualizerView()
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func iconName(for category: JSCategory) -> String {
        switch category {
        case .basics:
            return "1.square"
        case .functions:
            return "function"
        case .objects:
            return "cube"
        case .arrays:
            return "list.bullet"
        case .async:
            return "timer"
        case .es6:
            return "arrow.right.square"
        }
    }
    
    private func categoryColor(for category: JSCategory) -> Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .green
        case .objects:
            return .orange
        case .arrays:
            return .purple
        case .async:
            return .pink
        case .es6:
            return .teal
        }
    }
}

// List of tutorials for a category
struct JSCategoryTutorialListView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    let category: JSCategory
    
    var body: some View {
        List(selection: $viewModel.selectedTutorial) {
            ForEach(viewModel.tutorialsForCategory(category)) { tutorial in
                TutorialSection(tutorial: tutorial)
                    .tag(tutorial)
            }
        }
        .navigationTitle(category.rawValue)
        .listStyle(InsetGroupedListStyle())
    }
}

// List of tutorials for a difficulty level
struct TutorialListByLevelView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    let level: JavaScriptTutorial.Level
    
    var body: some View {
        List(selection: $viewModel.selectedTutorial) {
            ForEach(viewModel.tutorialsForLevel(level)) { tutorial in
                TutorialSection(tutorial: tutorial)
                    .tag(tutorial)
            }
        }
        .navigationTitle(level.rawValue + " Tutorials")
        .listStyle(InsetGroupedListStyle())
    }
}

// Featured tutorials view
struct FeaturedTutorialsView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 16) {
                ForEach(viewModel.tutorials) { tutorial in
                    TutorialCard(tutorial: tutorial)
                        .onTapGesture {
                            viewModel.selectedTutorial = tutorial
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Featured Tutorials")
    }
}

// Tutorial section in list
struct TutorialSection: View {
    let tutorial: JavaScriptTutorial
    
    var body: some View {
        NavigationLink(value: tutorial) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tutorial.title)
                    .font(.headline)
                
                Text(tutorial.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(tutorial.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(categoryColor(for: tutorial.category).opacity(0.2))
                        .foregroundColor(categoryColor(for: tutorial.category))
                        .cornerRadius(4)
                    
                    Text(tutorial.level.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(levelColor(for: tutorial.level).opacity(0.2))
                        .foregroundColor(levelColor(for: tutorial.level))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func categoryColor(for category: JSCategory) -> Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .green
        case .objects:
            return .orange
        case .arrays:
            return .purple
        case .async:
            return .pink
        case .es6:
            return .teal
        }
    }
    
    private func levelColor(for level: JavaScriptTutorial.Level) -> Color {
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

// Card view for tutorials
struct TutorialCard: View {
    let tutorial: JavaScriptTutorial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tutorial.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(tutorial.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(tutorial.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor(for: tutorial.category).opacity(0.2))
                    .foregroundColor(categoryColor(for: tutorial.category))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(tutorial.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(levelColor(for: tutorial.level).opacity(0.2))
                    .foregroundColor(levelColor(for: tutorial.level))
                    .cornerRadius(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func categoryColor(for category: JSCategory) -> Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .green
        case .objects:
            return .orange
        case .arrays:
            return .purple
        case .async:
            return .pink
        case .es6:
            return .teal
        }
    }
    
    private func levelColor(for level: JavaScriptTutorial.Level) -> Color {
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