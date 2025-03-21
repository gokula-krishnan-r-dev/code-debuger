import SwiftUI

struct PythonCodeVisualizer: View {
    let codeExample: PythonCodeExample
    @StateObject private var viewModel = PythonCodeViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentStep = 0
    @State private var executionSteps: [PythonExecutionStep] = []
    @State private var sliderValue: Double = 0
    @State private var showConnections = true
    @State private var animatingStep = false
    @State private var isPlaying = false
    @State private var playbackTimer: Timer?
    @State private var showExplanation = true
    @State private var useAdvancedVisualization = false
    @State private var isExecuting = false
    @State private var executionComplete = false
    @State private var executionError: String? = nil
    @State private var isFullScreen = false
    @State private var zoomScale: CGFloat = 1.0
    @State private var executionProgress: Double = 0.0
    @State private var executionSpeed: Double = 1.0
    @State private var draggingOffset: CGSize = .zero
    
    // References tracking
    @State private var framePreferences: [String: CGRect] = [:]
    @State private var objectPreferences: [String: CGRect] = [:]
    
    // Computed properties for layout
    private var splitRatio: CGFloat {
        isFullScreen ? 1 : 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // Header
                    headerView
                        .frame(height: isFullScreen ? 44 : 56)
                    
                    // Main content with horizontal split
                    HStack(spacing: 0) {
                        // Left side - Code
                        VStack {
                            ScrollView {
                                codeView
                                    .frame(minWidth: geometry.size.width * splitRatio)
                            }
                            
                            // Run controls
                            runControlsView
                                .padding(.vertical, 8)
                                .padding(.horizontal, isFullScreen ? 16 : 8)
                        }
                        .frame(width: geometry.size.width * splitRatio)
                        
                        // Divider
                        Divider()
                            .background(Color.secondary)
                        
                        // Right side - Frames and Objects
                        VStack(spacing: 0) {
                            HStack {
                                Text("Frames")
                                    .font(.headline)
                                    .padding()
                                
                                Spacer()
                                
                                Text("Objects")
                                    .font(.headline)
                                    .padding()
                            }
                            .background(Color(.systemGray6))
                            
                            ZStack {
                                if executionSteps.isEmpty {
                                    emptyStateView
                                } else {
                                    memoryVisualizer
                                        .opacity(animatingStep ? 0 : 1)
                                        .scaleEffect(zoomScale)
                                        .offset(draggingOffset)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    self.draggingOffset = value.translation
                                                }
                                                .onEnded { _ in
                                                    withAnimation {
                                                        self.draggingOffset = .zero
                                                    }
                                                }
                                        )
                                        .gesture(
                                            MagnificationGesture()
                                                .onChanged { value in
                                                    self.zoomScale = max(1.0, min(value, 2.5))
                                                }
                                                .onEnded { _ in
                                                    withAnimation {
                                                        self.zoomScale = 1.0
                                                    }
                                                }
                                        )
                                    
                                    if showExplanation, currentStep < executionSteps.count, !executionSteps[currentStep].explanation.isEmpty {
                                        VStack {
                                            Spacer()
                                            
                                            explanationView
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width * (1 - splitRatio))
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Navigation controls
                    navigationControlsView
                        .frame(height: isFullScreen ? 80 : 100)
                }
                
                // Overlay for executing state
                if isExecuting {
                    executingOverlay
                }
            }
            .navigationBarHidden(isFullScreen)
            .statusBar(hidden: isFullScreen)
            .edgesIgnoringSafeArea(isFullScreen ? .all : [])
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("Python 3.6 - \(codeExample.title)")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .lineLimit(1)
            
            if let knownLimitations = codeExample.knownLimitations {
                Button(action: {
                    // Show limitations popup
                }) {
                    Text("known limitations")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            
            Spacer()
            
            // Full screen toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFullScreen.toggle()
                }
            }) {
                Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut("f", modifiers: .command)
            
            if !isFullScreen {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, isFullScreen ? 8 : 12)
        .background(Color(.systemBackground))
    }
    
    private var codeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(getCodeLines().enumerated()), id: \.offset) { index, line in
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
                        .foregroundColor(lineColor(for: index + 1))
                        .background(lineBackground(for: index + 1))
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var runControlsView: some View {
        HStack {
            Button(action: {
                executeCode()
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Run")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isExecuting ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isExecuting)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                resetExecution()
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isExecuting ? Color.gray.opacity(0.5) : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.leading, 8)
            .disabled(isExecuting)
            .buttonStyle(PlainButtonStyle())
            
            // Speed control
            if !executionSteps.isEmpty {
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Speed:")
                        .font(.caption)
                    
                    Button(action: { executionSpeed = max(0.5, executionSpeed - 0.5) }) {
                        Image(systemName: "tortoise.fill")
                            .foregroundColor(executionSpeed <= 0.5 ? .blue : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { executionSpeed = 1.0 }) {
                        Text("1x")
                            .font(.caption)
                            .foregroundColor(executionSpeed == 1.0 ? .blue : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { executionSpeed = min(2.0, executionSpeed + 0.5) }) {
                        Image(systemName: "hare.fill")
                            .foregroundColor(executionSpeed >= 2.0 ? .blue : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var memoryVisualizer: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                if useAdvancedVisualization {
                    // Advanced visualization
                    if currentStep < executionSteps.count {
                        VStack(spacing: 20) {
                            Text("Memory Visualization")
                                .font(.headline)
                                .padding(.top)
                            
                            // Frames section
                            VStack(alignment: .leading) {
                                Text("Call Stack")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                
                                ForEach(executionSteps[currentStep].frames) { frame in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(frame.name)
                                            .font(.headline)
                                            .padding(.bottom, 4)
                                        
                                        ForEach(frame.variables) { variable in
                                            HStack {
                                                Text(variable.name)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(variable.isNew ? .green : .primary)
                                                
                                                Text("=")
                                                
                                                Text(variable.value)
                                                    .foregroundColor(variable.isChanged ? .orange : .primary)
                                            }
                                            .font(.system(.body, design: .monospaced))
                                            .padding(.horizontal)
                                        }
                                    }
                                    .padding()
                                    .background(frame.isActive ? Color.blue.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(frame.isActive ? Color.blue : Color.gray, lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            Divider()
                                .padding(.vertical)
                            
                            // Objects visualization
                            VStack(alignment: .leading) {
                                Text("Python Objects")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                
                                PythonMemoryVisualization(
                                    objects: executionSteps[currentStep].objects,
                                    showReferences: showConnections
                                )
                                .padding()
                                .coordinateSpace(name: "memorySpace")
                                .transition(.slide)
                            }
                        }
                        .padding(20)
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                } else {
                    // Standard visualization with connections
                    ZStack {
                        // All connections first
                        if showConnections {
                            connectionLines
                                .opacity(animatingStep ? 0 : 1)
                                .animation(.easeInOut(duration: 0.5), value: currentStep)
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            if currentStep < executionSteps.count {
                                let step = executionSteps[currentStep]
                                
                                // Frames
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Global frame")
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                    
                                    ForEach(step.frames) { frame in
                                        frameView(frame)
                                            .padding(.leading)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding()
                                .background(Color.clear)
                                
                                // Divider
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                    .padding(.horizontal)
                                
                                // Objects
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(step.objects) { object in
                                        objectView(object)
                                            .id(object.identifier) // Important for reference lookup
                                            .transition(.slide)
                                    }
                                }
                                .padding()
                                .background(Color.clear)
                            }
                        }
                    }
                    .padding(20)
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
            .coordinateSpace(name: "memoryView")
            .onPreferenceChange(FramePreferenceKey.self) { preferences in
                self.framePreferences = preferences
            }
            .onPreferenceChange(ObjectPreferenceKey.self) { preferences in
                self.objectPreferences = preferences
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            if isExecuting {
                ProgressView()
                    .padding()
                Text("Executing code...")
                    .font(.headline)
                
                ProgressView(value: executionProgress)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
            } else if let error = executionError {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .padding()
                    
                    Text("Execution Error")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        executionError = nil
                    }) {
                        Text("Dismiss")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            } else if !executionComplete {
                VStack {
                    Image(systemName: "arrow.left")
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Click Run to start execution")
                        .font(.headline)
                        
                    Text("Visualization will appear here")
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .padding()
                        .opacity(0.7)
                }
                .padding()
            }
        }
    }
    
    private var executingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Executing Python Code...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ProgressView(value: executionProgress)
                    .frame(width: 200)
                    .padding()
            }
            .padding(30)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
    
    private var explanationView: some View {
        Text(executionSteps[currentStep].explanation)
            .font(.system(size: isFullScreen ? 16 : 14))
            .padding(12)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: currentStep)
            .frame(maxWidth: .infinity)
    }
    
    private var navigationControlsView: some View {
        VStack(spacing: 2) {
            // Slider for quick navigation
            HStack {
                Text("\(currentStep + 1)")
                    .font(.caption)
                    .frame(width: 30)
                
                Slider(
                    value: $sliderValue,
                    in: 0...Double(max(executionSteps.count - 1, 1)),
                    step: 1
                )
                .onChange(of: sliderValue) { newValue in
                    if !animatingStep && !executionSteps.isEmpty {
                        stopPlayback()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            animatingStep = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            currentStep = Int(newValue)
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                animatingStep = false
                            }
                        }
                    }
                }
                .disabled(executionSteps.isEmpty)
                
                Text("\(executionSteps.count)")
                    .font(.caption)
                    .frame(width: 30)
            }
            .padding(.horizontal)
            
            HStack {
                // Step indicator
                Text(executionSteps.isEmpty ? "No steps available" : "Step \(currentStep + 1) of \(executionSteps.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Playback controls
                HStack(spacing: 16) {
                    // First step
                    Button(action: {
                        stopPlayback()
                        goToStep(0)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .foregroundColor(executionSteps.isEmpty || currentStep == 0 ? .gray : .blue)
                    }
                    .disabled(executionSteps.isEmpty || currentStep == 0)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Previous step
                    Button(action: {
                        stopPlayback()
                        if currentStep > 0 {
                            goToStep(currentStep - 1)
                        }
                    }) {
                        Image(systemName: "backward.fill")
                            .foregroundColor(executionSteps.isEmpty || currentStep == 0 ? .gray : .blue)
                    }
                    .disabled(executionSteps.isEmpty || currentStep == 0)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Play/Pause
                    Button(action: {
                        isPlaying.toggle()
                        if isPlaying {
                            startPlayback()
                        } else {
                            stopPlayback()
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(executionSteps.isEmpty || currentStep >= executionSteps.count - 1 ? .gray : .blue)
                    }
                    .disabled(executionSteps.isEmpty || currentStep >= executionSteps.count - 1)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Next step
                    Button(action: {
                        stopPlayback()
                        if currentStep < executionSteps.count - 1 {
                            goToStep(currentStep + 1)
                        }
                    }) {
                        Image(systemName: "forward.fill")
                            .foregroundColor(executionSteps.isEmpty || currentStep >= executionSteps.count - 1 ? .gray : .blue)
                    }
                    .disabled(executionSteps.isEmpty || currentStep >= executionSteps.count - 1)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Last step
                    Button(action: {
                        stopPlayback()
                        goToStep(executionSteps.count - 1)
                    }) {
                        Image(systemName: "forward.end.fill")
                            .foregroundColor(executionSteps.isEmpty || currentStep >= executionSteps.count - 1 ? .gray : .blue)
                    }
                    .disabled(executionSteps.isEmpty || currentStep >= executionSteps.count - 1)
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                // Settings toggles
                HStack(spacing: 16) {
                    Toggle(isOn: $showConnections) {
                        Text("Connections")
                            .font(.caption)
                    }
                    
                    Toggle(isOn: $showExplanation) {
                        Text("Explanation")
                            .font(.caption)
                    }
                    
                    Toggle(isOn: $useAdvancedVisualization) {
                        Text("Advanced View")
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var connectionLines: some View {
        let step = executionSteps[currentStep]
        
        return ZStack {
            ForEach(step.frames) { frame in
                ForEach(frame.variables) { variable in
                    if let reference = variable.objectReference {
                        ConnectionLine(
                            from: framePreferences["\(frame.id)_\(variable.id)"] ?? .zero,
                            to: objectPreferences[reference] ?? .zero,
                            color: .blue,
                            animate: true
                        )
                    }
                }
            }
        }
    }
    
    private func frameView(_ frame: PythonFrameState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(frame.name)
                .font(.subheadline)
                .fontWeight(frame.isActive ? .bold : .regular)
                .foregroundColor(frame.isActive ? .primary : .secondary)
            
            ForEach(frame.variables) { variable in
                HStack(spacing: 12) {
                    Text(variable.name)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(variable.isNew ? .green : .primary)
                    
                    Text(variable.value)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(variable.isChanged ? .orange : .primary)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: FramePreferenceKey.self,
                                        value: ["\(frame.id)_\(variable.id)": geo.frame(in: .named("memoryView"))]
                                    )
                            }
                        )
                }
                .padding(.leading)
                .animation(.easeInOut, value: variable.isChanged)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(frame.isActive ? Color.blue.opacity(0.1) : Color.clear)
                .animation(.easeInOut, value: frame.isActive)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(frame.isActive ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                .animation(.easeInOut, value: frame.isActive)
        )
    }
    
    private func objectView(_ object: PythonObjectState) -> some View {
        VStack(alignment: .leading) {
            Text(object.content)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(objectBackground(for: object.type))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(objectBorderColor(for: object.type), lineWidth: 1.5)
                )
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: ObjectPreferenceKey.self,
                                value: [object.identifier: geo.frame(in: .named("memoryView"))]
                            )
                    }
                )
        }
    }
    
    private func objectBackground(for type: PythonObjectType) -> Color {
        switch type {
        case .function:
            return Color.purple.opacity(0.2)
        case .list:
            return Color.blue.opacity(0.2)
        case .tuple:
            return Color.yellow.opacity(0.3)
        case .dictionary:
            return Color.green.opacity(0.2)
        case .string:
            return Color.red.opacity(0.2)
        case .number:
            return Color.orange.opacity(0.2)
        case .none:
            return Color.gray.opacity(0.2)
        }
    }
    
    private func objectBorderColor(for type: PythonObjectType) -> Color {
        switch type {
        case .function:
            return Color.purple
        case .list:
            return Color.blue
        case .tuple:
            return Color.yellow
        case .dictionary:
            return Color.green
        case .string:
            return Color.red
        case .number:
            return Color.orange
        case .none:
            return Color.gray
        }
    }
    
    private func lineColor(for lineNumber: Int) -> Color {
        guard currentStep < executionSteps.count else { return .primary }
        
        let step = executionSteps[currentStep]
        if lineNumber == step.lineNumber {
            return .green
        } else if lineNumber == step.nextLineNumber {
            return .red
        }
        
        return .primary
    }
    
    private func lineBackground(for lineNumber: Int) -> Color {
        guard currentStep < executionSteps.count else { return .clear }
        
        let step = executionSteps[currentStep]
        if lineNumber == step.lineNumber {
            return Color.green.opacity(0.2)
        } else if lineNumber == step.nextLineNumber {
            return Color.red.opacity(0.1)
        }
        
        return .clear
    }
    
    private func getCodeLines() -> [String] {
        codeExample.code.components(separatedBy: .newlines)
    }
    
    // MARK: - Execution Methods
    
    private func executeCode() {
        // Reset any previous execution
        resetExecution()
        
        // Start execution
        isExecuting = true
        
        // Simulate execution progress
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if self.executionProgress < 0.95 {
                self.executionProgress += 0.01
            } else {
                timer.invalidate()
            }
        }
        
        // Simulate network delay for better UX feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            do {
                // In a real implementation, this would call a Python interpreter backend
                // For now, we use the mock implementation
                let steps = viewModel.simulateExecution(for: codeExample)
                
                if steps.isEmpty {
                    self.executionError = "No execution data could be generated for this code"
                } else {
                    self.executionSteps = steps
                    self.currentStep = 0
                    self.sliderValue = 0
                }
                
                // Complete the progress animation
                self.executionProgress = 1.0
                progressTimer.invalidate()
                
                // Small delay to show 100% before clearing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.isExecuting = false
                    self.executionComplete = true
                    self.executionProgress = 0.0
                }
            } catch {
                self.executionError = error.localizedDescription
                self.isExecuting = false
                progressTimer.invalidate()
            }
        }
    }
    
    private func resetExecution() {
        stopPlayback()
        executionSteps = []
        currentStep = 0
        sliderValue = 0
        executionError = nil
        executionComplete = false
        zoomScale = 1.0
        draggingOffset = .zero
    }
    
    private func goToStep(_ step: Int) {
        guard step >= 0 && step < executionSteps.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            animatingStep = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentStep = step
            sliderValue = Double(step)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                animatingStep = false
            }
        }
    }
    
    private func startPlayback() {
        stopPlayback() // Ensure any existing timer is invalidated
        
        let interval = 1.0 / (viewModel.animationSpeed * executionSpeed)
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if currentStep < executionSteps.count - 1 {
                goToStep(currentStep + 1)
            } else {
                stopPlayback()
            }
        }
    }
    
    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        isPlaying = false
    }
}

// Line to connect frames to objects
struct ConnectionLine: View {
    var from: CGRect
    var to: CGRect
    var color: Color
    var animate: Bool = false
    
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        Path { path in
            let fromPoint = CGPoint(
                x: from.maxX,
                y: from.midY
            )
            
            let toPoint = CGPoint(
                x: to.minX,
                y: to.midY
            )
            
            path.move(to: fromPoint)
            
            // Curved path with control points
            let controlPoint1 = CGPoint(
                x: fromPoint.x + min(100, (toPoint.x - fromPoint.x) / 2),
                y: fromPoint.y
            )
            
            let controlPoint2 = CGPoint(
                x: toPoint.x - min(100, (toPoint.x - fromPoint.x) / 2),
                y: toPoint.y
            )
            
            path.addCurve(to: toPoint, control1: controlPoint1, control2: controlPoint2)
        }
        .trim(from: 0, to: animate ? animationProgress : 1)
        .stroke(color, lineWidth: 2)
        .shadow(color: color.opacity(0.5), radius: 2)
        .onAppear {
            if animate {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
        .onChange(of: from) { _ in
            if animate {
                animationProgress = 0
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
    }
}

// Preview provider
struct PythonCodeVisualizer_Previews: PreviewProvider {
    static var previews: some View {
        PythonCodeVisualizer(codeExample: PythonCodeExample.recursiveSumExample)
    }
}

// Preference keys for capturing frame locations
struct FramePreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]
    
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

// Preference keys for capturing object locations
struct ObjectPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]
    
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
} 