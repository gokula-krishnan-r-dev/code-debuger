import SwiftUI

struct JSCodeVisualizerView: View {
    @StateObject private var viewModel = JSCodeVisualizerViewModel()
    @State private var selectedLine: Int = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and controls
            headerView
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            if viewModel.executionStates.isEmpty && !viewModel.isLoading {
                welcomeScreen
            } else if horizontalSizeClass == .compact {
                // Phone layout - tabbed interface
                phoneTabbedLayout
            } else {
                // iPad layout - side by side
                iPadSplitLayout
            }
        }
        .sheet(isPresented: $viewModel.showExamplesPanel) {
            examplesListView
        }
        .sheet(isPresented: $viewModel.showSettings) {
            settingsView
        }
        .onChange(of: viewModel.currentExecutionState) { newState in
            if let state = newState {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedLine = state.currentLine
                }
            }
        }
        .overlay(
            viewModel.isLoading ? loadingOverlay : nil
        )
    }
    
    // MARK: - Welcome Screen
    
    private var welcomeScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Introduction section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to JavaScript Visualizer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Visualize and understand JavaScript code execution step by step - see memory state, execution frames, and runtime behavior.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // How it works section
                VStack(alignment: .leading, spacing: 16) {
                    Text("How It Works")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureItem(
                            icon: "1.circle.fill",
                            title: "Write or paste JavaScript code",
                            description: "Enter your JavaScript code in the editor or choose from our pre-built examples"
                        )
                        
                        FeatureItem(
                            icon: "2.circle.fill",
                            title: "Click 'Visualize'",
                            description: "The tool will analyze your code and prepare it for step-by-step execution"
                        )
                        
                        FeatureItem(
                            icon: "3.circle.fill",
                            title: "Step through execution",
                            description: "Navigate forward and backward through code execution using control buttons"
                        )
                        
                        FeatureItem(
                            icon: "4.circle.fill",
                            title: "See what's happening",
                            description: "Watch variables change, functions call, and see your code's behavior in real time"
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Features section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Features")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        FeatureCard(
                            icon: "command.square",
                            title: "Live Code Execution",
                            description: "See each line execute with real JavaScript engine"
                        )
                        
                        FeatureCard(
                            icon: "briefcase",
                            title: "Memory Visualization",
                            description: "Understand memory, objects and references"
                        )
                        
                        FeatureCard(
                            icon: "arrow.left.arrow.right",
                            title: "Step Forward & Backward",
                            description: "Navigate through your code's execution flow"
                        )
                        
                        FeatureCard(
                            icon: "terminal",
                            title: "Console Output",
                            description: "See the results of console.log statements"
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Get started section
                VStack(spacing: 20) {
                    Text("Get Started")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            viewModel.showExamplesPanel = true
                        }) {
                            VStack {
                                Image(systemName: "text.book.closed.fill")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 8)
                                Text("Try an Example")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            viewModel.codeText = "// Try your own JavaScript code\nfunction sayHello(name) {\n    console.log(\"Hello, \" + name + \"!\");\n}\n\nsayHello(\"World\");"
                            viewModel.executeCode()
                        }) {
                            VStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 8)
                                Text("Start Coding")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Based on section
                HStack {
                    Text("Based on")
                        .foregroundColor(.secondary)
                    
                    Link("Python Tutor", destination: URL(string: "https://pythontutor.com/javascript.html")!)
                        .foregroundColor(.blue)
                    
                    Text("- the original web-based code visualizer")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .padding()
        }
    }
    
    // MARK: - Layout Components
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("JavaScript Visualizer")
                    .font(.headline)
                
                if let state = viewModel.currentExecutionState {
                    Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.executionStates.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.showExamplesPanel = true
                }) {
                    Image(systemName: "text.book.closed")
                    Text("Examples")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    viewModel.showSettings = true
                }) {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var phoneTabbedLayout: some View {
        VStack(spacing: 0) {
            // Tab selection
            Picker("View", selection: $viewModel.selectedTab) {
                Text("Code").tag(0)
                Text("Output").tag(1)
                Text("Console").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $viewModel.selectedTab) {
                // Code Editor Tab
                codeEditorView
                    .tag(0)
                
                // Memory & Objects Tab
                ScrollView {
                    VStack(spacing: 16) {
                        // Controls when in output view
                        executionControlsView
                            .padding()
                        
                        // Memory Visualization
                        JSMemoryVisualizerView(executionState: viewModel.currentExecutionState)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .tag(1)
                
                // Console Output Tab
                VStack(spacing: 16) {
                    consoleOutputView
                    
                    // Controls when in console view
                    executionControlsView
                        .padding()
                }
                .padding()
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    private var iPadSplitLayout: some View {
        HStack(spacing: 0) {
            // Left side - Code editor
            VStack(spacing: 16) {
                // Code editor
                JSCodeEditorView(
                    code: $viewModel.codeText,
                    selectedLine: $selectedLine,
                    currentHighlightedLine: viewModel.currentExecutionState?.currentLine,
                    highlightColor: .yellow,
                    showLineNumbers: viewModel.showLineNumbers,
                    isEditable: !viewModel.isExecuting,
                    fontSize: 14.0,
                    editorFocused: $viewModel.editorIsFocused
                )
                
                // Execution controls
                executionControlsView
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * viewModel.splitRatio)
            
            // Right side - Memory and console
            VStack(spacing: 16) {
                // Memory visualization
                JSMemoryVisualizerView(executionState: viewModel.currentExecutionState)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                
                // Console output
                consoleOutputView
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * (1 - viewModel.splitRatio))
            
            // Resizing handle
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 4)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newRatio = viewModel.splitRatio + value.translation.width / UIScreen.main.bounds.width
                            viewModel.splitRatio = min(max(0.3, newRatio), 0.7)
                        }
                )
        }
    }
    
    // MARK: - Shared Components
    
    private var codeEditorView: some View {
        VStack(spacing: 8) {
            JSCodeEditorView(
                code: $viewModel.codeText,
                selectedLine: $selectedLine,
                currentHighlightedLine: viewModel.currentExecutionState?.currentLine,
                highlightColor: .yellow,
                showLineNumbers: viewModel.showLineNumbers,
                isEditable: !viewModel.isExecuting,
                fontSize: 14.0,
                editorFocused: $viewModel.editorIsFocused
            )
            .frame(maxHeight: .infinity)
            
            // Settings for the code editor
            HStack {
                Toggle("Line Numbers", isOn: $viewModel.showLineNumbers)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                
                Toggle("Highlight Syntax", isOn: $viewModel.highlightSyntax)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.updateCode("")
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
            .padding(8)
        }
        .padding()
    }
    
    private var executionControlsView: some View {
        VStack(spacing: 8) {
            // Current step explanation
            if let state = viewModel.currentExecutionState {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Explanation")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.executionStates.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    
                    Text(state.explanation)
                        .font(.callout)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .id("explanation-\(state.id)")
                        .animation(.easeInOut(duration: 0.3), value: state.id)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            // Execution controls
            executionControls
            
            // Speed slider
            HStack {
                Image(systemName: "tortoise")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $viewModel.animationSpeed, in: 0.5...2.0, step: 0.25)
                    .frame(maxWidth: .infinity)
                
                Image(systemName: "hare")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .disabled(viewModel.executionStates.isEmpty || viewModel.isLoading)
        .animation(.easeInOut, value: viewModel.currentStepIndex)
    }
    
    private var executionControls: some View {
        HStack(spacing: 14) {
            Button(action: {
                viewModel.resetExecution()
                viewModel.executeCode()
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14))
                    .frame(width: 36, height: 36)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Button(action: {
                viewModel.stepBackward()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
                    .frame(width: 36, height: 36)
            }
            .disabled(viewModel.currentStepIndex <= 0 || viewModel.isLoading)
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Button(action: {
                viewModel.stepForward()
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .frame(width: 36, height: 36)
            }
            .disabled(viewModel.currentStepIndex >= viewModel.executionStates.count - 1 || viewModel.isLoading)
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Button(action: {
                viewModel.updateCode(viewModel.codeText)
                viewModel.executeCode()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Visualize")
                        .font(.callout)
                }
                .frame(width: 100, height: 36)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var consoleOutputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Console Output")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
//                    $viewModel.clearConsole
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .opacity(viewModel.consoleOutput.isEmpty ? 0.3 : 1)
                .disabled(viewModel.consoleOutput.isEmpty)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4))
                .padding(.bottom, 4)
            
            if viewModel.consoleOutput.isEmpty {
                VStack {
                    Image(systemName: "terminal")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 8)
                    
                    Text("No output yet")
                        .foregroundColor(.secondary)
                        .italic()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.consoleOutput.indices, id: \.self) { index in
                                let output = viewModel.consoleOutput[index]
                                HStack(alignment: .top) {
                                    Text("›")
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20, alignment: .center)
                                    
                                    Text(output)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(getConsoleColor(for: output))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(index % 2 == 0 ? Color(.systemGray6) : Color.clear)
                                .cornerRadius(4)
                                .id("console-line-\(index)")
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .padding(.vertical, 4)
                        .onChange(of: viewModel.consoleOutput.count) { _ in
                            if !viewModel.consoleOutput.isEmpty {
                                withAnimation {
                                    proxy.scrollTo("console-line-\(viewModel.consoleOutput.count - 1)", anchor: .bottom)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            
            if viewModel.hasError {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(viewModel.errorMessage)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                }
                .padding(.top, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .animation(.easeIn(duration: 0.2), value: viewModel.consoleOutput.count)
        .animation(.spring(), value: viewModel.hasError)
    }
    
    private func getConsoleColor(for text: String) -> Color {
        if text.contains("Error:") || text.contains("error:") {
            return .red
        } else if text.contains("undefined") {
            return .gray
        } else if text.contains("\"") || text.contains("'") {
            return .green
        } else if text.contains("true") || text.contains("false") {
            return .purple
        } else if let firstChar = text.first, firstChar.isNumber || text.contains("null") {
            return .orange
        } else {
            return .primary
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .opacity(0.7)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Analyzing JavaScript code...")
                    .font(.headline)
                
                Text("This may take a moment for complex code")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Examples Panel
    
    private var examplesListView: some View {
        NavigationView {
            List {
                ForEach(0..<viewModel.codeExamples.count, id: \.self) { index in
                    Button(action: {
                        viewModel.selectCodeExample(index: index)
                        viewModel.showExamplesPanel = false
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.codeExamples[index].title)
                                .font(.headline)
                            
                            Text(viewModel.codeExamples[index].code.prefix(100) + "...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("JavaScript Examples")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        viewModel.showExamplesPanel = false
                    }
                }
            }
        }
    }
    
    // MARK: - Settings View
    
    private var settingsView: some View {
        NavigationView {
            Form {
                Section(header: Text("Execution Settings")) {
                    Toggle("Auto-Visualize Code", isOn: $viewModel.autoVisualizeCode)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("JavaScript Visualizer")
                            .font(.headline)
                        
                        Text("A tool for visualizing JavaScript code execution step-by-step")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.showSettings = false
                    }
                }
            }
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct JSCodeVisualizerView_Previews: PreviewProvider {
    static var previews: some View {
        JSCodeVisualizerView()
    }
} 
