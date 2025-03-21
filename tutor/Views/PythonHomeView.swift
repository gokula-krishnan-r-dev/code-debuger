import SwiftUI

struct PythonHomeView: View {
    @StateObject private var viewModel = PythonCodeViewModel()
    @State private var selectedExample: PythonCodeExample?
    @State private var showCodeVisualizer = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.selectedCategory) {
                // Category filters
                Section(header: Text("Categories")) {
                    ForEach(PythonCategory.allCases) { category in
                        NavigationLink(value: category) {
                            Label(category.rawValue, systemImage: category.iconName)
                                .foregroundColor(categoryColor(for: category))
                        }
                    }
                }
                
                // Difficulty levels
                Section(header: Text("Levels")) {
                    ForEach(PythonCodeExample.Difficulty.allCases, id: \.self) { level in
                        NavigationLink(destination: PythonTutorialListByLevelView(viewModel: viewModel, level: level)) {
                            Label(level.rawValue, systemImage: levelIcon(for: level))
                                .foregroundColor(level.color)
                        }
                    }
                }
                
                // Featured code examples
                Section(header: Text("Featured Examples")) {
                    ForEach(viewModel.allExamples) { example in
                        Button(action: {
                            self.selectedExample = example
                            self.showCodeVisualizer = true
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(example.title)
                                        .font(.headline)
                                    
                                    Text(example.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Text(example.difficulty.rawValue)
                                    .font(.caption)
                                    .padding(4)
                                    .background(example.difficulty.color.opacity(0.2))
                                    .foregroundColor(example.difficulty.color)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
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
                    
                    Slider(value: $viewModel.animationSpeed, in: 0.5...2.0, step: 0.25) {
                        Label("Animation Speed", systemImage: "speedometer")
                    } minimumValueLabel: {
                        Text("0.5x")
                    } maximumValueLabel: {
                        Text("2.0x")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Python Tutor")
        } content: {
            // Content column - show tutorials for selected category or featured tutorials
            if let category = viewModel.selectedCategory {
                PythonCategoryTutorialListView(viewModel: viewModel, category: category)
            } else {
                FeaturedPythonTutorialsView(viewModel: viewModel)
            }
        } detail: {
            // Detail column - show selected tutorial details
            if let selectedExample = viewModel.selectedExample {
                PythonTutorialDetailView(viewModel: viewModel, example: selectedExample)
            } else {
                if showCodeVisualizer {
                    PythonCodeVisualizer(codeExample: selectedExample!)
                      .edgesIgnoringSafeArea(.all)
                      .frame(maxWidth:.infinity, maxHeight:.infinity)
                      .presentationDetents([.large])
                } else {
                    Text("Select a tutorial to begin")
                       .foregroundColor(.secondary)
                }
            }
        }
        .navigationSplitViewStyle(.prominentDetail)

    }
    
    private func categoryColor(for category: PythonCategory) -> Color {
        switch category {
        case .basics:
            return .blue
        case .functions:
            return .green
        case .dataStructures:
            return .orange
        case .recursion:
            return .purple
        case .objectOriented:
            return .red
        case .algorithms:
            return .pink
        }
    }
    
    private func levelIcon(for level: PythonCodeExample.Difficulty) -> String {
        switch level {
        case .beginner:
            return "1.circle"
        case .intermediate:
            return "2.circle"
        case .advanced:
            return "3.circle"
        }
    }
}

// Category tutorial list view
struct PythonCategoryTutorialListView: View {
    @ObservedObject var viewModel: PythonCodeViewModel
    let category: PythonCategory
    @State private var selectedExample: PythonCodeExample?
    @State private var showCodeVisualizer = false
    
    var body: some View {
        List {
            ForEach(viewModel.examplesForCategory(category)) { example in
                Button(action: {
                    self.selectedExample = example
                    self.showCodeVisualizer = true
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(example.title)
                                .font(.headline)
                            
                            Text(example.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Text(example.difficulty.rawValue)
                            .font(.caption)
                            .padding(4)
                            .background(example.difficulty.color.opacity(0.2))
                            .foregroundColor(example.difficulty.color)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .navigationTitle(category.rawValue)
    }
}

// Level-filtered tutorial list view
struct PythonTutorialListByLevelView: View {
    @ObservedObject var viewModel: PythonCodeViewModel
    let level: PythonCodeExample.Difficulty
    @State private var selectedExample: PythonCodeExample?
    @State private var showCodeVisualizer = false
    
    var examplesByLevel: [PythonCodeExample] {
        viewModel.allExamples.filter { $0.difficulty == level }
    }
    
    var body: some View {
        List {
            ForEach(examplesByLevel) { example in
                Button(action: {
                    self.selectedExample = example
                    self.showCodeVisualizer = true
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(example.title)
                                .font(.headline)
                            
                            Text(example.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Text(example.category.rawValue)
                            .font(.caption)
                            .padding(4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .navigationTitle("\(level.rawValue) Tutorials")
    }
}

// Featured tutorials view
struct FeaturedPythonTutorialsView: View {
    @ObservedObject var viewModel: PythonCodeViewModel
    @State private var selectedExample: PythonCodeExample?
    @State private var showCodeVisualizer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Featured Python Tutorials")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("Select a tutorial to visualize Python code execution step by step")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
                    ForEach(viewModel.allExamples) { example in
                        tutorialCard(for: example)
                            .onTapGesture {
                                self.selectedExample = example
                                self.showCodeVisualizer = true
                            }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Python Tutor")
        // .sheet(isPresented: $showCodeVisualizer) {
        //     if let example = selectedExample {
        //     PythonCodeVisualizer(codeExample: example)
        //             .edgesIgnoringSafeArea(.all)
        //             .frame(maxWidth: .infinity, maxHeight: .infinity)
        //             .presentationDetents([.large])
        //     }
        // }
    }
    
    private func tutorialCard(for example: PythonCodeExample) -> some View {
        VStack(alignment: .leading) {
            // Header with title and difficulty
            HStack {
                Text(example.title)
                    .font(.headline)
                
                Spacer()
                
                Text(example.difficulty.rawValue)
                    .font(.caption)
                    .padding(4)
                    .background(example.difficulty.color.opacity(0.2))
                    .foregroundColor(example.difficulty.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Divider()
            
            // Description
            Text(example.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.vertical, 4)
            
            // Category and preview button
            HStack {
                Label(example.category.rawValue, systemImage: example.category.iconName)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button("Preview") {
                    self.selectedExample = example
                    self.showCodeVisualizer = true
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2))
    }
}

// Tutorial detail view
struct PythonTutorialDetailView: View {
    @ObservedObject var viewModel: PythonCodeViewModel
    let example: PythonCodeExample
    @State private var showCodeVisualizer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(example.title)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(example.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(example.difficulty.rawValue)
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(example.difficulty.color.opacity(0.2))
                        .foregroundColor(example.difficulty.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.bottom)
                
                // Description
                Text(example.description)
                    .font(.body)
                    .padding(.bottom)
                
                // Code preview
                VStack(alignment: .leading) {
                    Text("Code")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(example.code.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                                HStack(spacing: 0) {
                                    // Line number
                                    Text("\(index + 1)")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 40, alignment: .trailing)
                                        .padding(.trailing, 8)
                                    
                                    // Line content
                                    Text(line)
                                        .font(.system(.body, design: .monospaced))
                                        .padding(.vertical, 2)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .frame(maxHeight: 300)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom)
                
                // Run button
                Button(action: {
                    showCodeVisualizer = true
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Run Visualization")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if let limitations = example.knownLimitations {
                    GroupBox(label: Label("Known Limitations", systemImage: "exclamationmark.triangle")) {
                        Text(limitations)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
                
                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showCodeVisualizer) {
            PythonCodeVisualizer(codeExample: example)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
} 