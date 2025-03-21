import SwiftUI

struct CodeStepVisualizer: View {
    let codeExample: JSCodeExample
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var currentStep = 0
    @State private var totalSteps = 0
    @State private var executionSteps: [ExecutionStep] = []
    @State private var sliderValue: Double = 0
    @State private var showConnections = true
    @State private var animatingStep = false
    
    // Execution model
    struct ExecutionStep {
        let lineNumber: Int
        let nextLineNumber: Int
        let variables: [VariableState]
        let frames: [FrameState]
        let objects: [ObjectState]
        let explanation: String
    }
    
    struct VariableState: Identifiable {
        let id = UUID()
        let name: String
        let value: String
        let isNew: Bool
        let isChanged: Bool
        let objectReference: String? // Reference to an object if applicable
    }
    
    struct FrameState: Identifiable {
        let id = UUID()
        let name: String
        let variables: [VariableState]
        let isActive: Bool
    }
    
    struct ObjectState: Identifiable {
        let id = UUID()
        let identifier: String
        let content: String
        let type: ObjectType
    }
    
    enum ObjectType {
        case function
        case array
        case object
        case primitive
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("JavaScript (\(codeExample.title))")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
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
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Main content with horizontal split
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left side - Code
                    codeView
                        .frame(width: geometry.size.width / 2)
                    
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
                            memoryView
                                .opacity(animatingStep ? 0 : 1)
                            
                            if currentStep < executionSteps.count {
                                let step = executionSteps[currentStep]
                                Text(step.explanation)
                                    .font(.footnote)
                                    .padding(8)
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            }
                        }
                    }
                    .frame(width: geometry.size.width / 2)
                }
            }
            
            // Navigation controls
            VStack(spacing: 2) {
                // Slider for quick navigation
                Slider(value: $sliderValue, in: 0...Double(max(totalSteps - 1, 1)), step: 1)
                    .padding(.horizontal)
                    .onChange(of: sliderValue) { newValue in
                        if !animatingStep {
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
                
                HStack {
                    // Step info
                    HStack(spacing: 4) {
                        Image(systemName: "arrowtriangle.right.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("line that just executed")
                            .font(.caption)
                        
                        Image(systemName: "arrowtriangle.right.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 12)
                        Text("next line to execute")
                            .font(.caption)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack(spacing: 8) {
                        Button(action: {
                            // First step
                            navigateTo(step: 0)
                        }) {
                            Label("<< First", systemImage: "backward.end.fill")
                                .labelStyle(.iconOnly)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .disabled(currentStep <= 0)
                        .buttonStyle(.bordered)
                        
                        Button(action: previousStep) {
                            Label("< Prev", systemImage: "chevron.left")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .disabled(currentStep <= 0)
                        .buttonStyle(.bordered)
                        
                        Button(action: nextStep) {
                            Label("Next >", systemImage: "chevron.right")
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .disabled(currentStep >= totalSteps - 1)
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            // Last step
                            navigateTo(step: totalSteps - 1)
                        }) {
                            Label("Last >>", systemImage: "forward.end.fill")
                                .labelStyle(.iconOnly)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .disabled(currentStep >= totalSteps - 1)
                        .buttonStyle(.bordered)
                    }
                    .padding(.trailing)
                }
                
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .padding(.bottom, 8)
            }
            .padding(.top, 8)
            .background(Color(.systemBackground))
        }
        .onAppear {
            generateExecutionSteps()
            totalSteps = executionSteps.count
        }
    }
    
    // Code display with line numbers and highlighting
    private var codeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        let codeLines = codeExample.code.components(separatedBy: "\n")
                        ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                            HStack(spacing: 0) {
                                // Line number
                                Text("\(index + 1)")
                                    .frame(width: 40, alignment: .trailing)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                                
                                // Arrow indicators for current and next lines
                                Group {
                                    if currentStep < executionSteps.count {
                                        if index + 1 == executionSteps[currentStep].lineNumber {
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundColor(.green)
                                                .frame(width: 20)
                                        } else if index + 1 == executionSteps[currentStep].nextLineNumber {
                                            Image(systemName: "arrowtriangle.right.fill")
                                                .foregroundColor(.red)
                                                .frame(width: 20)
                                        } else {
                                            Text("").frame(width: 20)
                                        }
                                    } else {
                                        Text("").frame(width: 20)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                                .id("arrow-\(index)")
                                
                                // Line content
                                Text(line)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        currentStep < executionSteps.count && (index + 1 == executionSteps[currentStep].lineNumber) ? 
                                            Color.green.opacity(0.1) : Color.clear
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                            .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: currentStep) { _ in
                    if currentStep < executionSteps.count {
                        withAnimation {
                            scrollView.scrollTo(max(0, executionSteps[currentStep].lineNumber - 5), anchor: .top)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    // Memory state view with frames and objects
    private var memoryView: some View {
        GeometryReader { geometry in
            ScrollView {
                if currentStep < executionSteps.count {
                    let step = executionSteps[currentStep]
                    
                    ZStack {
                        // Draw connections first (if any)
                        if showConnections {
                            ForEach(step.frames) { frame in
                                ForEach(frame.variables) { variable in
                                    if let objectRef = variable.objectReference {
                                        if let object = step.objects.first(where: { $0.identifier == objectRef }) {
                                            ConnectionLine(
                                                fromID: variable.id.uuidString,
                                                toID: object.id.uuidString,
                                                color: connectionColor(for: object.type)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 0) {
                            // Frames column
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(step.frames) { frame in
                                    FrameView(frame: frame)
                                        .id(frame.id)
                                        .transition(.asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                            }
                            .frame(width: geometry.size.width / 2)
                            .padding()
                            
                            Spacer()
                            
                            // Objects column
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(step.objects) { object in
                                    ObjectView(object: object)
                                        .id(object.id)
                                        .frame(maxWidth: .infinity)
                                        .transition(.asymmetric(
                                            insertion: .slide.combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                }
                            }
                            .frame(width: geometry.size.width / 2)
                            .padding()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                } else {
                    Text("No execution data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private func connectionColor(for type: ObjectType) -> Color {
        switch type {
        case .function:
            return .blue
        case .array:
            return .green
        case .object:
            return .orange
        case .primitive:
            return .gray
        }
    }
    
    struct FrameView: View {
        let frame: FrameState
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(frame.name)
                    .font(.headline)
                    .foregroundColor(frame.isActive ? .primary : .secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(frame.isActive ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(4)
                
                // Variables in frame
                ForEach(frame.variables) { variable in
                    HStack(alignment: .center) {
                        Text(variable.name)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(variable.isNew ? .green : (variable.isChanged ? .orange : .primary))
                            .id("\(variable.id.uuidString)-name")
                        
                        Spacer()
                        
                        // Value
                        Text(variable.value)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .id("\(variable.id.uuidString)")
                    }
                    .padding(.horizontal)
                    .id("\(variable.id.uuidString)-row")
                    .transition(.slide.combined(with: .opacity))
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(8)
        }
    }
    
    struct ObjectView: View {
        let object: ObjectState
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    objectIcon
                    Text(objectTitle)
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(objectColor.opacity(0.1))
                .cornerRadius(4)
                
                Text(object.content)
                    .font(.system(.body, design: .monospaced))
                    .padding(10)
                    .id("\(object.id.uuidString)")
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray5))
            )
        }
        
        private var objectTitle: String {
            switch object.type {
            case .function:
                return "function \(object.identifier)"
            case .array:
                return "array"
            case .object:
                return "object"
            case .primitive:
                return "value"
            }
        }
        
        private var objectIcon: some View {
            let iconName: String
            
            switch object.type {
            case .function:
                iconName = "f.cursive"
            case .array:
                iconName = "bracket.square"
            case .object:
                iconName = "curlybraces"
            case .primitive:
                iconName = "number"
            }
            
            return Image(systemName: iconName)
                .foregroundColor(objectColor)
        }
        
        private var objectColor: Color {
            switch object.type {
            case .function:
                return .blue
            case .array:
                return .green
            case .object:
                return .orange
            case .primitive:
                return .gray
            }
        }
    }
    
    struct ConnectionLine: View {
        let fromID: String
        let toID: String
        let color: Color
        
        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    guard let fromCenter = findCenter(for: fromID, in: geometry),
                          let toCenter = findCenter(for: toID, in: geometry) else {
                        return
                    }
                    
                    let controlPoint1 = CGPoint(
                        x: fromCenter.x + 50,
                        y: fromCenter.y
                    )
                    let controlPoint2 = CGPoint(
                        x: toCenter.x - 50,
                        y: toCenter.y
                    )
                    
                    path.move(to: fromCenter)
                    path.addCurve(to: toCenter, control1: controlPoint1, control2: controlPoint2)
                }
                .stroke(color, lineWidth: 1.5)
            }
        }
        
        private func findCenter(for id: String, in geometry: GeometryProxy) -> CGPoint? {
            // Find view with matching ID
            guard let frame = getViewFrame(for: id, in: geometry) else {
                return nil
            }
            
            return CGPoint(
                x: frame.midX,
                y: frame.midY
            )
        }
        
        private func getViewFrame(for id: String, in geometry: GeometryProxy) -> CGRect? {
            // This is just a placeholder since we can't properly implement view finding without namespace
            // In a real implementation, we'd use PreferenceKey to track view frames
            return nil
        }
    }
    
    // Navigation functions
    private func nextStep() {
        if currentStep < totalSteps - 1 {
            navigateTo(step: currentStep + 1)
        }
    }
    
    private func previousStep() {
        if currentStep > 0 {
            navigateTo(step: currentStep - 1)
        }
    }
    
    private func navigateTo(step: Int) {
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
    
    // Generate execution steps for the code example
    private func generateExecutionSteps() {
        // This would ideally be generated by a code interpreter
        // For now, we'll create some sample execution steps for demonstration
        
        let sampleSteps: [ExecutionStep]
        
        if codeExample.title.contains("Two Sum") {
            sampleSteps = generateTwoSumSteps()
        } else if codeExample.title.contains("Generate Parenthesis") {
            sampleSteps = generateParenthesisSteps()
        } else if codeExample.title.contains("Working with Bits") {
            sampleSteps = generateBitManipulationSteps()
        } else {
            // Generate generic execution steps based on code analysis
            sampleSteps = generateGenericSteps()
        }
        
        executionSteps = sampleSteps
        totalSteps = sampleSteps.count
    }
    
    // Generate sample execution steps for two sum algorithm
    private func generateTwoSumSteps() -> [ExecutionStep] {
        // Sample execution steps for Two Sum algorithm
        var steps: [ExecutionStep] = []
        
        // Step 1: Function definition
        steps.append(ExecutionStep(
            lineNumber: 1,
            nextLineNumber: 6,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "twoSum", value: "function", isNew: true, isChanged: false, objectReference: "func_twoSum")
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(

                    identifier: "func_twoSum",
                    content: "function twoSum(nums, target) {\n    // Function body\n}",
                    type: .function
                )
            ],
            explanation: "The twoSum function is defined in the global scope."
        ))
        
        // Step 2: Function call with parameters
        steps.append(ExecutionStep(
            lineNumber: 30,
            nextLineNumber: 2,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "twoSum", value: "function", isNew: false, isChanged: false, objectReference: "func_twoSum"),
                        VariableState(name: "nums", value: "[2, 7, 11, 15]", isNew: true, isChanged: false, objectReference: "array_nums"),
                        VariableState(name: "target", value: "9", isNew: true, isChanged: false, objectReference: nil)
                    ],
                    isActive: false
                ),
                FrameState(
                    name: "twoSum",
                    variables: [
                        VariableState(name: "nums", value: "[2, 7, 11, 15]", isNew: true, isChanged: false, objectReference: "array_nums"),
                        VariableState(name: "target", value: "9", isNew: true, isChanged: false, objectReference: nil)
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(

                    identifier: "func_twoSum",
                    content: "function twoSum(nums, target) {\n    // Function body\n}",
                    type: .function
                ),
                ObjectState(

                    identifier: "array_nums",
                    content: "[2, 7, 11, 15]",
                    type: .array
                )
            ],
            explanation: "The twoSum function is called with nums=[2, 7, 11, 15] and target=9."
        ))
        
        // Step 3: Create map
        steps.append(ExecutionStep(
            lineNumber: 6,
            nextLineNumber: 9,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "twoSum", value: "function", isNew: false, isChanged: false, objectReference: "func_twoSum"),
                        VariableState(name: "nums", value: "[2, 7, 11, 15]", isNew: false, isChanged: false, objectReference: "array_nums"),
                        VariableState(name: "target", value: "9", isNew: false, isChanged: false, objectReference: nil)
                    ],
                    isActive: false
                ),
                FrameState(
                    name: "twoSum",
                    variables: [
                        VariableState(name: "nums", value: "[2, 7, 11, 15]", isNew: false, isChanged: false, objectReference: "array_nums"),
                        VariableState(name: "target", value: "9", isNew: false, isChanged: false, objectReference: nil),
                        VariableState(name: "map", value: "Map(0)", isNew: true, isChanged: false, objectReference: "obj_map")
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(
                    
                    identifier: "func_twoSum",
                    content: "function twoSum(nums, target) {\n    // Function body\n}",
                    type: .function
                ),
                ObjectState(
                   
                    identifier: "array_nums",
                    content: "[2, 7, 11, 15]",
                    type: .array
                ),
                ObjectState(
                   
                    identifier: "obj_map",
                    content: "empty Map",
                    type: .object
                )
            ],
            explanation: "Create an empty Map to store values and their indices."
        ))
        
        // Add more steps with objects and connections similar to the image reference
        // Continue with additional steps...
        
        return steps
    }
    
    // Generate sample execution steps for parenthesis generation
    private func generateParenthesisSteps() -> [ExecutionStep] {
        // Sample execution steps for the generateParenthesis algorithm from the image
        var steps: [ExecutionStep] = []
        
        // Step 1: Function definition
        steps.append(ExecutionStep(
            lineNumber: 1,
            nextLineNumber: 2,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "generateParenthesis", value: "function", isNew: true, isChanged: false, objectReference: "func_generateParenthesis")
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(
                   
                    identifier: "func_generateParenthesis",
                    content: "function (n) {\n    const res = [];\n    function dfs(openP, closeP, s) {\n        // function body\n    }\n    return res;\n}",
                    type: .function
                )
            ],
            explanation: "The generateParenthesis function is defined in the global scope."
        ))
        
        // Step 2: Initialize res array
        steps.append(ExecutionStep(
            lineNumber: 2,
            nextLineNumber: 3,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "generateParenthesis", value: "function", isNew: false, isChanged: false, objectReference: "func_generateParenthesis")
                    ],
                    isActive: false
                ),
                FrameState(
                    name: "generateParenthesis",
                    variables: [
                        VariableState(name: "n", value: "3", isNew: true, isChanged: false, objectReference: nil),
                        VariableState(name: "res", value: "[]", isNew: true, isChanged: false, objectReference: "array_res")
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(
                   
                    identifier: "func_generateParenthesis",
                    content: "function (n) {\n    const res = [];\n    function dfs(openP, closeP, s) {\n        // function body\n    }\n    return res;\n}",
                    type: .function
                ),
                ObjectState(
                   
                    identifier: "array_res",
                    content: "[]",
                    type: .array
                )
            ],
            explanation: "Initialize an empty array to store the results."
        ))
        
        // Step 3: Define inner dfs function
        steps.append(ExecutionStep(
            lineNumber: 4,
            nextLineNumber: 19,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "generateParenthesis", value: "function", isNew: false, isChanged: false, objectReference: "func_generateParenthesis")
                    ],
                    isActive: false
                ),
                FrameState(
                    name: "generateParenthesis",
                    variables: [
                        VariableState(name: "n", value: "3", isNew: false, isChanged: false, objectReference: nil),
                        VariableState(name: "res", value: "[]", isNew: false, isChanged: false, objectReference: "array_res"),
                        VariableState(name: "dfs", value: "function", isNew: true, isChanged: false, objectReference: "func_dfs")
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(
                   
                    identifier: "func_generateParenthesis",
                    content: "function (n) {\n    const res = [];\n    function dfs(openP, closeP, s) {\n        // function body\n    }\n    return res;\n}",
                    type: .function
                ),
                ObjectState(
                   
                    identifier: "array_res",
                    content: "[]",
                    type: .array
                ),
                ObjectState(
                   
                    identifier: "func_dfs",
                    content: "function dfs(openP, closeP, s) {\n    if (openP === closeP && openP + closeP === n * 2) {\n        res.push(s);\n        return;\n    }\n    if (openP < n) {\n        dfs(openP + 1, closeP, s + \"(\");\n    }\n    if (closeP < openP) {\n        dfs(openP, closeP + 1, s + \")\");\n    }\n}",
                    type: .function
                )
            ],
            explanation: "Define the recursive DFS function that will generate all valid combinations."
        ))
        
        // Step 4: Initial call to dfs
        steps.append(ExecutionStep(
            lineNumber: 19,
            nextLineNumber: 5,
            variables: [],
            frames: [
                FrameState(
                    name: "Global frame",
                    variables: [
                        VariableState(name: "generateParenthesis", value: "function", isNew: false, isChanged: false, objectReference: "func_generateParenthesis")
                    ],
                    isActive: false
                ),
                FrameState(
                    name: "generateParenthesis",
                    variables: [
                        VariableState(name: "n", value: "3", isNew: false, isChanged: false, objectReference: nil),
                        VariableState(name: "res", value: "[]", isNew: false, isChanged: false, objectReference: "array_res"),
                        VariableState(name: "dfs", value: "function", isNew: false, isChanged: false, objectReference: "func_dfs")
                    ],
                    isActive: true
                ),
                FrameState(
                    name: "dfs",
                    variables: [
                        VariableState(name: "openP", value: "0", isNew: true, isChanged: false, objectReference: nil),
                        VariableState(name: "closeP", value: "0", isNew: true, isChanged: false, objectReference: nil),
                        VariableState(name: "s", value: "\"\"", isNew: true, isChanged: false, objectReference: nil)
                    ],
                    isActive: true
                )
            ],
            objects: [
                ObjectState(
                   
                    identifier: "func_generateParenthesis",
                    content: "function (n) {\n    const res = [];\n    function dfs(openP, closeP, s) {\n        // function body\n    }\n    return res;\n}",
                    type: .function
                ),
                ObjectState(
                   
                    identifier: "array_res",
                    content: "[]",
                    type: .array
                ),
                ObjectState(
                   
                    identifier: "func_dfs",
                    content: "function dfs(openP, closeP, s) {\n    if (openP === closeP && openP + closeP === n * 2) {\n        res.push(s);\n        return;\n    }\n    if (openP < n) {\n        dfs(openP + 1, closeP, s + \"(\");\n    }\n    if (closeP < openP) {\n        dfs(openP, closeP + 1, s + \")\");\n    }\n}",
                    type: .function
                )
            ],
            explanation: "Make the initial call to dfs with 0 open parentheses, 0 closed parentheses, and an empty string."
        ))
        
        return steps
    }
    
    // Additional execution step generation methods...
    
    // Generate sample execution steps for bit manipulation
    private func generateBitManipulationSteps() -> [ExecutionStep] {
        // Placeholder implementation
        return []
    }
    
    // Generate generic execution steps based on code analysis
    private func generateGenericSteps() -> [ExecutionStep] {
        // Placeholder implementation
        return []
    }
}

// Preview provider
struct CodeStepVisualizer_Previews: PreviewProvider {
    static var previews: some View {
        let example = JSCodeExample(
            title: "Generate Parenthesis",
            code: """
            var generateParenthesis = function(n) {
                const res = [];
                
                function dfs(openP, closeP, s) {
                    if (openP === closeP && openP + closeP === n * 2) {
                        res.push(s);
                        return;
                    }
                    
                    if (openP < n) {
                        dfs(openP + 1, closeP, s + "(");
                    }
                    
                    if (closeP < openP) {
                        dfs(openP, closeP + 1, s + ")");
                    }
                }
                
                dfs(0, 0, "");
                return res;
            }
            """,
            explanation: "This algorithm generates all combinations of well-formed parentheses."
        )
        
        CodeStepVisualizer(codeExample: example)
            .preferredColorScheme(.dark)
    }
}

// Use a namespace for view identification
@available(iOS 14.0, *)
struct ViewPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

// Extend View to add view IDs for connection lines
extension View {
    func viewId(_ id: String) -> some View {
        self.modifier(ViewIdModifier(id: id))
    }
}

struct ViewIdModifier: ViewModifier {
    let id: String
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ViewPreferenceKey.self, value: [id: geometry.frame(in: .global)])
                }
            )
    }
}

// Extend JSCodeExample to include known limitations
extension JSCodeExample {
    var knownLimitations: String? {
        // This would be added to the model but for now we'll return nil
        return nil
    }
} 
