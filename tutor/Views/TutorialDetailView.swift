import SwiftUI

struct TutorialDetailView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    let tutorial: JavaScriptTutorial
    @State private var selectedExampleIndex = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Tutorial header
                VStack(alignment: .leading, spacing: 12) {
                    Text(tutorial.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        categoryBadge
                        levelBadge
                    }
                    
                    Text(tutorial.description)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                
                // Examples picker
                if tutorial.examples.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Examples")
                            .font(.headline)
                        
                        Picker("Select Example", selection: $selectedExampleIndex) {
                            ForEach(0..<tutorial.examples.count, id: \.self) { index in
                                Text(tutorial.examples[index].title).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                }
                
                // Code view
                if !tutorial.examples.isEmpty {
                    CodeAndExplanationView(
                        viewModel: viewModel,
                        example: tutorial.examples[selectedExampleIndex]
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleCodeHighlighting()
                }) {
                    Label(
                        viewModel.codeHighlighted ? "Disable Highlighting" : "Enable Highlighting",
                        systemImage: viewModel.codeHighlighted ? "lightbulb.fill" : "lightbulb"
                    )
                }
            }
        }
    }
    
    private var categoryBadge: some View {
        Text(tutorial.category.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(6)
    }
    
    private var levelBadge: some View {
        Text(tutorial.level.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(levelColor.opacity(0.2))
            .foregroundColor(levelColor)
            .cornerRadius(6)
    }
    
    private var categoryColor: Color {
        switch tutorial.category {
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
    
    private var levelColor: Color {
        switch tutorial.level {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
}

struct CodeAndExplanationView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    let example: JSCodeExample
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAnimationView = false
    @State private var animateButton = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(example.title)
                .font(.headline)
            
            // Layout switches based on device size
            if horizontalSizeClass == .regular {
                // iPad layout
                HStack(alignment: .top, spacing: 20) {
                    codeView
                        .frame(minWidth: 0, maxWidth: .infinity)
                    
                    explanationView
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            } else {
                // iPhone layout
                VStack(alignment: .leading, spacing: 20) {
                    codeView
                    explanationView
                }
            }
        }
        .fullScreenCover(isPresented: $showingAnimationView) {
            // Show the step-by-step code visualizer as a full screen cover
            CodeStepVisualizer(codeExample: example)
        }
    }
    
    private var codeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Code block
                    Group {
                        if viewModel.codeHighlighted {
                            viewModel.highlightedCode(example.code)
                        } else {
                            Text(example.code)
                        }
                    }
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
            .cornerRadius(8)
            
            // Code action buttons
            HStack {
                Button(action: {
                    UIPasteboard.general.string = example.code
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    // Open in JSFiddle or similar
                    if let url = URL(string: "https://jsfiddle.net/") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Try it", systemImage: "play.circle")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        animateButton = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingAnimationView = true
                        animateButton = false
                    }
                }) {
                    Label("Visualize", systemImage: "eye")
                        .font(.footnote)
                }
                .buttonStyle(.borderedProminent)
                .scaleEffect(animateButton ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateButton)
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var explanationView: some View {
        ScrollView {
            Text(example.explanation)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
                .cornerRadius(8)
        }
    }
} 