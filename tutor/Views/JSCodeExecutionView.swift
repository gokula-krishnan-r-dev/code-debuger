import SwiftUI

struct JSCodeExecutionView: View {
    @State private var currentExecution: JSCodeExecution
    @State private var currentStepIndex: Int = 0
    @StateObject private var viewModel = JSCodeViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    init(execution: JSCodeExecution) {
        _currentExecution = State(initialValue: execution)
    }
    
    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayout
        } else {
            phoneLayout
        }
    }
    
    private var currentStep: JSExecutionStep {
        currentExecution.steps[currentStepIndex]
    }
    
    private var phoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerView
                
                executionControlsView
                
                codeView
                    .frame(height: 300)
                
                consoleView
                
                memoryView
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var iPadLayout: some View {
        HStack(spacing: 0) {
            // Code panel (1/2 width)
            VStack {
                headerView
                    .padding()
                
                codeView
                
                executionControlsView
                    .padding()
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
            
            // Console and memory panels (1/2 width)
            VStack {
                consoleView
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                
                Divider()
                
                memoryView
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentExecution.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(currentExecution.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var executionControlsView: some View {
        VStack(spacing: 16) {
            // Step description
            VStack(alignment: .leading, spacing: 8) {
                Text("Step \(currentStepIndex + 1) of \(currentExecution.steps.count)")
                    .font(.headline)
                
                Text(currentStep.explanation)
                    .font(.body)
                
                if let hint = currentStep.nextStepHint {
                    Text("Next: \(hint)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(8)
            .shadow(radius: 2)
            
            // Controls
            HStack {
                Button(action: previousStep) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .disabled(currentStepIndex == 0)
                .opacity(currentStepIndex == 0 ? 0.5 : 1)
                
                Spacer()
                
                Button(action: resetExecution) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .opacity(currentStepIndex == 0 ? 0.5 : 1)
                .disabled(currentStepIndex == 0)
                
                Spacer()
                
                Button(action: nextStep) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .disabled(currentStepIndex >= currentExecution.steps.count - 1)
                .opacity(currentStepIndex >= currentExecution.steps.count - 1 ? 0.5 : 1)
            }
            .padding(.horizontal)
        }
    }
    
    private var codeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                let codeLines = currentExecution.code.components(separatedBy: .newlines)
                
                ForEach(0..<codeLines.count, id: \.self) { index in
                    HStack(spacing: 0) {
                        // Line number
                        Text("\(index + 1)")
                            .padding(.horizontal, 8)
                            .frame(width: 40, alignment: .trailing)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        // Line highlight
                        Rectangle()
                            .fill(highlightColorForLine(index + 1))
                            .frame(width: 4)
                        
                        // Actual code with syntax highlighting
                        getHighlightedCode(codeLines[index])
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(backgroundColorForLine(index + 1))
                    }
                }
            }
            .padding(.vertical, 8)
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
    
    private var consoleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Console Output")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0...currentStepIndex, id: \.self) { index in
                        if let output = currentExecution.steps[index].output {
                            Text(output)
                                .font(.system(.body, design: .monospaced))
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.tertiarySystemBackground))
                                .cornerRadius(4)
                        }
                    }
                    
                    if !hasConsoleOutput {
                        Text("No output yet")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var hasConsoleOutput: Bool {
        (0...currentStepIndex).contains { index in
            currentExecution.steps[index].output != nil
        }
    }
    
    private var memoryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memory State")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Execution scope
                    HStack {
                        Text("Scope:")
                            .fontWeight(.semibold)
                        Text(currentStep.scope)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    // Variables in current step
                    if currentStep.variables.isEmpty {
                        Text("No variables in scope")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(currentStep.variables) { variable in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(variable.name)
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    if variable.isNew {
                                        Text("NEW")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    } else if variable.isChanged {
                                        Text("CHANGED")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Text(variable.value.displayValue)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(colorForValue(variable.value))
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.tertiarySystemBackground))
                                    .cornerRadius(4)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func highlightColorForLine(_ line: Int) -> Color {
        if line == currentStep.lineNumber {
            switch currentStep.codeHighlight {
            case .executing:
                return .blue
            case .nextToExecute:
                return .gray
            case .completed:
                return .green
            case .error:
                return .red
            }
        }
        return .clear
    }
    
    private func backgroundColorForLine(_ line: Int) -> Color {
        if line == currentStep.lineNumber {
            switch currentStep.codeHighlight {
            case .executing:
                return .blue.opacity(0.1)
            case .nextToExecute:
                return .gray.opacity(0.1)
            case .completed:
                return .green.opacity(0.1)
            case .error:
                return .red.opacity(0.1)
            }
        }
        return .clear
    }
    
    private func getHighlightedCode(_ line: String) -> Text {
        viewModel.getHighlightedCode(line)
    }
    
    private func colorForValue(_ value: JSValue) -> Color {
        switch value {
        case .string:
            return .green
        case .number:
            return .blue
        case .boolean:
            return .purple
        case .null, .undefined:
            return .gray
        case .array, .object:
            return .orange
        case .function:
            return .red
        }
    }
    
    private func nextStep() {
        if currentStepIndex < currentExecution.steps.count - 1 {
            withAnimation {
                currentStepIndex += 1
            }
        }
    }
    
    private func previousStep() {
        if currentStepIndex > 0 {
            withAnimation {
                currentStepIndex -= 1
            }
        }
    }
    
    private func resetExecution() {
        withAnimation {
            currentStepIndex = 0
        }
    }
}

// MARK: - Preview
struct JSCodeExecutionView_Previews: PreviewProvider {
    static var previews: some View {
        JSCodeExecutionView(execution: JSCodeExecution.variablesExecution)
    }
}

// MARK: - Helper Accessors for iPad Layout Integration
extension JSCodeExecutionView {
    var codeContentView: some View {
        VStack {
            headerView
                .padding()
            
            codeView
            
            executionControlsView
                .padding()
        }
    }
    
    var memoryContentView: some View {
        memoryView
    }
    
    var consoleContentView: some View {
        consoleView
    }
} 