import Foundation
import SwiftUI
import JavaScriptCore

class JSCodeVisualizerViewModel: ObservableObject {
    // Current code and execution state
    @Published var code: JSCode
    @Published var codeText: String
    @Published var currentExecutionState: JSExecutionState?
    @Published var executionStates: [JSExecutionState] = []
    @Published var currentStepIndex: Int = 0
    @Published var isExecuting: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String = ""
    @Published var consoleOutput: [String] = []
    @Published var animationSpeed: Double = 1.0
    @Published var showLineNumbers: Bool = true
    @Published var highlightSyntax: Bool = true
    @Published var autoVisualizeCode: Bool = true
    
    // UI state
    @Published var editorIsFocused: Bool = false
    @Published var showExamplesPanel: Bool = false
    @Published var selectedTab: Int = 0 // 0: Code, 1: Output, 2: Both
    @Published var showSettings: Bool = false
    @Published var isLoading: Bool = false
    
    // Layout settings
    @Published var splitRatio: Double = 0.5
    
    // Example code snippets for the visualizer
    let codeExamples: [(title: String, code: String)] = [
        (
            "Basic Variables",
            """
            // Basic variable examples
            let number = 42;
            let text = "Hello, world!";
            let boolean = true;
            
            // Using variables
            let sum = number + 10;
            let message = text + " The answer is " + number;
            console.log(message);
            """
        ),
        (
            "Object References",
            """
            // Object example showing references
            let person = {
                name: "Alice",
                age: 28,
                skills: ["JavaScript", "SwiftUI"]
            };
            
            // Create a reference to the same object
            let anotherPerson = person;
            
            // Modify through the reference
            anotherPerson.age = 29;
            
            // Both references point to the same object
            console.log(person.age);  // Will show 29
            """
        ),
        (
            "Function Calls",
            """
            // Function definition
            function calculateArea(width, height) {
                let area = width * height;
                return area;
            }
            
            // Function calls
            let rectangleArea = calculateArea(5, 10);
            let squareArea = calculateArea(4, 4);
            
            console.log("Rectangle area:", rectangleArea);
            console.log("Square area:", squareArea);
            """
        ),
        (
            "Recursive Factorial",
            """
            // Recursive function example
            function factorial(n) {
                // Base case
                if (n <= 1) {
                    return 1;
                }
                
                // Recursive case
                return n * factorial(n - 1);
            }
            
            // Calculate factorials
            let result1 = factorial(3);
            let result2 = factorial(4);
            
            console.log("3! =", result1);
            console.log("4! =", result2);
            """
        ),
        (
            "Arrays and Loops",
            """
            // Array operations
            let numbers = [1, 2, 3, 4, 5];
            let sum = 0;
            
            // For loop to calculate sum
            for (let i = 0; i < numbers.length; i++) {
                sum += numbers[i];
                console.log("Current sum:", sum);
            }
            
            // Map to create a new array
            let doubled = numbers.map(function(num) {
                return num * 2;
            });
            
            console.log("Original:", numbers);
            console.log("Doubled:", doubled);
            """
        ),
        (
            "Closures",
            """
            // Closure example
            function createCounter() {
                let count = 0;
                
                // Return a function that has access to count
                return function() {
                    count += 1;
                    return count;
                };
            }
            
            // Create two separate counters
            let counter1 = createCounter();
            let counter2 = createCounter();
            
            // Use the counters
            console.log(counter1()); // 1
            console.log(counter1()); // 2
            console.log(counter2()); // 1 - separate closure
            """
        )
    ]
    
    // Services
    private let interpreterService = JSInterpreterService()
    private var executionTimer: Timer?
    
    init(code: JSCode = JSCode.generateParentheses) {
        self.code = code
        self.codeText = code.sourceCode
    }
    
    // MARK: - Code Execution
    
    func executeCode() {
        resetExecution()
        isLoading = true
        
        // Use a background thread for code execution to keep UI responsive
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Execute code with the interpreter service
                let states = self.interpreterService.executeCode(self.codeText)
                
                if states.isEmpty {
                    // No states returned, probably an error
                    DispatchQueue.main.async {
                        self.hasError = true
                        self.errorMessage = "Failed to generate execution states. Check your code for syntax errors."
                        self.isLoading = false
                    }
                    return
                }
                
                // Process the states to add better explanations
                let enhancedStates = self.enhanceExecutionStates(states)
                
                DispatchQueue.main.async {
                    self.executionStates = enhancedStates
                    self.currentStepIndex = 0
                    self.currentExecutionState = self.executionStates.first
                    self.updateConsoleOutput()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorMessage = "Error executing code: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func resetExecution() {
        pauseExecution()
        hasError = false
        errorMessage = ""
        consoleOutput = []
        executionStates = []
        currentStepIndex = 0
        currentExecutionState = nil
    }
    
    // MARK: - Animation Control
    
    func startExecution() {
        if executionStates.isEmpty && !isLoading {
            executeCode()
            return
        }
        
        isExecuting = true
        scheduleNextStep()
    }
    
    func pauseExecution() {
        isExecuting = false
        executionTimer?.invalidate()
        executionTimer = nil
    }
    
    func stepForward() {
        guard currentStepIndex < executionStates.count - 1 else {
            isExecuting = false
            return
        }
        
        currentStepIndex += 1
        currentExecutionState = executionStates[currentStepIndex]
        updateConsoleOutput()
        
        if isExecuting {
            scheduleNextStep()
        }
    }
    
    func stepBackward() {
        guard currentStepIndex > 0 else { return }
        
        currentStepIndex -= 1
        currentExecutionState = executionStates[currentStepIndex]
        updateConsoleOutput()
    }
    
    private func scheduleNextStep() {
        executionTimer?.invalidate()
        
        let delay = 1.0 / animationSpeed
        executionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self = self, self.isExecuting else { return }
            self.stepForward()
        }
    }
    
    // MARK: - Code Examples
    
    func selectCodeExample(index: Int) {
        if index >= 0 && index < codeExamples.count {
            resetExecution()
            codeText = codeExamples[index].code
            if autoVisualizeCode {
                executeCode()
            }
        }
    }
    
    func updateCode(_ newCode: String) {
        codeText = newCode
        resetExecution()
    }
    
    // MARK: - Execution State Processing
    
    private func updateConsoleOutput() {
        // Update console output for the current state
        if let state = currentExecutionState {
            consoleOutput = state.consoleOutput
        } else {
            consoleOutput = []
        }
    }
    
    private func processExecutionState(_ state: JSExecutionState) {
        currentExecutionState = state
        currentStepIndex = state.step
        
        // Update console output
        if !state.consoleOutput.isEmpty {
            consoleOutput = state.consoleOutput
        }
        
        // Handle errors
        if state.hasError {
//            isError = true
            errorMessage = state.errorMessage ?? "An error occurred during execution"
        }
    }
    
    private func createInitialState() -> JSExecutionState {
        let globalFrame = JSExecutionFrame(
            name: "Global Execution Context",
            isGlobal: true,
            variables: [],
            lineNumber: 0,
            isActive: true
        )
        
        return updateExecutionState(
            frames: [globalFrame],
            step: 0,
            currentLine: 0,
            consoleOutput: [],
            explanation: "Program execution started"
        )
    }
    
    private func enhanceExecutionStates(_ states: [JSExecutionState]) -> [JSExecutionState] {
        var previousState: JSExecutionState?
        
        return states.enumerated().map { index, state in
            var frames = state.frames
            
            if let previous = previousState {
                // Compare variables to detect changes
                frames = frames.map { frame in
                    let previousFrame = previous.frames.first { $0.name == frame.name }
                    let variables = previousFrame.map { compareVariables(oldVars: $0.variables, newVars: frame.variables) } ?? frame.variables
                    
                    return JSExecutionFrame(

                        name: frame.name,
                        isGlobal: frame.isGlobal,
                        variables: variables,
                        lineNumber: frame.lineNumber,
                        isActive: frame.isActive
                    )
                }
            }
            
            previousState = state
            
            return JSExecutionState(
                step: index,
                frames: frames,
                heapObjects: state.heapObjects,
                activeFrameId: state.activeFrameId,
                currentLine: state.currentLine,
                consoleOutput: state.consoleOutput,
                explanation: state.explanation,
                hasError: state.hasError,
                errorMessage: state.errorMessage
            )
        }
    }
    
    private func compareVariables(oldVars: [JSVariableValue], newVars: [JSVariableValue]) -> [JSVariableValue] {
        return newVars.map { newVar in
            let oldVar = oldVars.first { $0.name == newVar.name }
            return JSVariableValue(
                name: newVar.name,
                value: newVar.value,
                stringValue: newVar.stringValue,
                type: newVar.type,
                isNew: oldVar == nil,
                isModified: oldVar != nil && oldVar?.value != newVar.value,
                reference: newVar.reference,
                references: newVar.references
            )
        }
    }
    
    private func updateExecutionState(frames: [JSExecutionFrame], step: Int, currentLine: Int, consoleOutput: [String], explanation: String, hasError: Bool = false, errorMessage: String? = nil) -> JSExecutionState {
        let activeFrame = frames.first(where: { $0.isActive }) ?? frames.first
        
        return JSExecutionState(
            step: step,
            frames: frames,
            heapObjects: [], // This will be populated by the interpreter
            activeFrameId: activeFrame?.id ?? UUID(),
            currentLine: currentLine,
            consoleOutput: consoleOutput,
            explanation: explanation,
            hasError: hasError,
            errorMessage: errorMessage
        )
    }
} 
