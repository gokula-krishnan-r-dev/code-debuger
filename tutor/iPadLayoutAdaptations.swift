import SwiftUI

// Generic modifier to adapt layout based on horizontal size class
struct AdaptiveLayoutModifier<Regular: View, Compact: View>: ViewModifier {
    let compact: () -> Compact
    let regular: () -> Regular
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        Group {
            if horizontalSizeClass == .compact {
                compact()
            } else {
                regular()
            }
        }
    }
}

// Extension to make the modifier easier to use
extension View {
    func adaptiveLayout<Regular: View, Compact: View>(
        compact: @escaping () -> Compact,
        regular: @escaping () -> Regular
    ) -> some View {
        modifier(AdaptiveLayoutModifier(compact: compact, regular: regular))
    }
}

// Enhanced iPad layout for code execution
struct iPadEnhancedCodeExecution: ViewModifier {
    @ObservedObject var viewModel: JSCodeViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        // This code has been replaced by the new JSCodeExecutionView system
        // Keep as a reference for potential future enhancements
        return content
    }
}

// Extension for JSCodeExecutionView to provide access to its components
// These placeholders are implemented in the actual JSCodeExecutionView
extension CodeExecutionView {
    // Placeholder implementations for iPad layout
    var codeContentView: some View {
        Text("Code Content")
    }
    
    var memoryContentView: some View {
        Text("Memory Content")
    }
    
    var controlContentView: some View {
        Text("Control Content")
    }
}

// iPad optimized navigation view
struct iPadOptimizedNavigationView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationSplitView {
            content
        } detail: {
            Text("Select a tutorial to begin")
                .foregroundColor(.secondary)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// This code is no longer needed as we've built a new system
// Keeping it commented for reference
/*
// Visual enhancements for iPad screens
extension TutorialListView {
    var iPadEnhancedView: some View {
        List {
            ForEach(TutorialCategory.allCases, id: \.self) { category in
                CategorySection(category: category)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("JavaScript Tutorials")
    }
    
    private struct CategorySection: View {
        let category: TutorialCategory
        @ObservedObject var viewModel: TutorialViewModel
        
        var body: some View {
            Section(header: Text(category.rawValue)) {
                let filteredTutorials = viewModel.tutorials.filter { $0.category == category }
                ForEach(filteredTutorials) { tutorial in
                    NavigationLink(destination: TutorialDetailView(tutorial: tutorial, viewModel: viewModel)) {
                        iPadTutorialRowView(tutorial: tutorial)
                    }
                }
            }
        }
        
        init(category: TutorialCategory) {
            self.category = category
            self.viewModel = TutorialViewModel()
        }
    }
}

struct iPadTutorialRowView: View {
    let tutorial: Tutorial
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(tutorial.title)
                    .font(.headline)
                Text(tutorial.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Category badge for iPad view
            Text(tutorial.category.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor(for: tutorial.category))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
    
    private func categoryColor(for category: TutorialCategory) -> Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .green
        case .objects:
            return .orange
        case .dom:
            return .purple
        case .async:
            return .pink
        case .python:
            return .indigo
        }
    }
}

// Enhanced code execution view for iPad
extension CodeExecutionView {
    var iPadEnhancedCodeExecution: some View {
        HStack(spacing: 0) {
            // Code Panel (left side)
            codePanelView
            
            Divider()
            
            // Memory Panel (right side)
            memoryAndControlView
        }
    }
    
    private var codePanelView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Python 3.6")
                .font(.headline)
                .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                codeContentView
                    .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: UIScreen.main.bounds.width * 0.4)
    }
    
    private var memoryAndControlView: some View {
        VStack {
            memoryContentView
            
            Divider()
            
            controlContentView
        }
        .frame(maxWidth: .infinity)
    }
    
    private var codeContentView: some View {
        // This should be implemented in the main CodeExecutionView
        EmptyView()
    }
    
    private var memoryContentView: some View {
        // This should be implemented in the main CodeExecutionView
        EmptyView()
    }
    
    private var controlContentView: some View {
        // This should be implemented in the main CodeExecutionView
        EmptyView()
    }
}
*/ 
