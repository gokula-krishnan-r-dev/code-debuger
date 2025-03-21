import SwiftUI

struct JSCodeAnimationView: View {
    @ObservedObject var viewModel: JSCodeViewModel
    let codeExample: JSCodeExample
    
    @State private var currentLineIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var memoryValues: [String: Any] = [:]
    @State private var output: [String] = []
    @State private var animationSpeed: Double = 1.0
    
    // Parse code into lines for animation
    private var codeLines: [String] {
        codeExample.code.components(separatedBy: "\n")
    }
    
    // Variables detected in the code
    private var detectedVariables: [String] {
        let variableRegex = try! NSRegularExpression(pattern: "(let|var|const)\\s+([a-zA-Z_$][a-zA-Z0-9_$]*)\\s*=", options: [])
        
        var variables: [String] = []
        
        for line in codeLines {
            let nsString = line as NSString
            let matches = variableRegex.matches(in: line, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges >= 3 {
                    let variableName = nsString.substring(with: match.range(at: 2))
                    variables.append(variableName)
                }
            }
        }
        
        return variables
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Code section with highlighted current line
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                        HStack(spacing: 0) {
                            // Line numbers
                            Text("\(index + 1)")
                                .frame(width: 40, alignment: .trailing)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                            
                            // Line content
                            Text(line)
                                .font(.system(.body, design: .monospaced))
                                .padding(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(index == currentLineIndex && isAnimating ? Color.yellow.opacity(0.3) : Color.clear)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground).opacity(0.8))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
            
            // Memory visualization
            VStack(alignment: .leading, spacing: 8) {
                Text("Memory State")
                    .font(.headline)
                
                if memoryValues.isEmpty {
                    Text("No variables in memory yet")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(memoryValues.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                VStack(alignment: .leading) {
                                    Text(key)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.primary)
                                    
                                    Text("\(String(describing: value))")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(8)
                                .background(Color(key == memoryValues.keys.sorted().last ? .systemBlue : .systemGray5).opacity(0.2))
                                .cornerRadius(6)
                                .animation(.easeInOut(duration: 0.3), value: key == memoryValues.keys.sorted().last)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Console output
            VStack(alignment: .leading, spacing: 8) {
                Text("Console Output")
                    .font(.headline)
                
                if output.isEmpty {
                    Text("No output yet")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(output.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .frame(maxHeight: 150)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Controls
            HStack {
                Button(action: {
                    if isAnimating {
                        pauseAnimation()
                    } else {
                        if currentLineIndex >= codeLines.count - 1 {
                            resetAnimation()
                        }
                        startAnimation()
                    }
                }) {
                    Label(isAnimating ? "Pause" : "Run", systemImage: isAnimating ? "pause.fill" : "play.fill")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: resetAnimation) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(minWidth: 100)
                }
                .buttonStyle(.bordered)
                
                Slider(value: $animationSpeed, in: 0.5...2.0, step: 0.25) {
                    Text("Speed")
                } minimumValueLabel: {
                    Image(systemName: "tortoise")
                } maximumValueLabel: {
                    Image(systemName: "hare")
                }
                .frame(maxWidth: 200)
            }
            .padding()
        }
        .padding()
        .onAppear {
            // Initialize with some sample variables
            setupInitialState()
        }
    }
    
    // Animation control functions
    private func startAnimation() {
        isAnimating = true
        advanceAnimation()
    }
    
    private func pauseAnimation() {
        isAnimating = false
    }
    
    private func resetAnimation() {
        isAnimating = false
        currentLineIndex = 0
        memoryValues = [:]
        output = []
        setupInitialState()
    }
    
    private func setupInitialState() {
        // Extract variable declarations from the code and initialize them
        // This is a simplified simulation - in a real app, you'd need a JavaScript interpreter
        if codeExample.title.contains("Two Sum") {
            memoryValues = ["nums": [2, 7, 11, 15], "target": 9]
        } else if codeExample.title.contains("Substring") {
            memoryValues = ["s": "abcabcbb", "maxLength": 0]
        } else if codeExample.title.contains("Grid Traversal") {
            memoryValues = ["grid": [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]]
        }
    }
    
    private func advanceAnimation() {
        guard isAnimating, currentLineIndex < codeLines.count else {
            if currentLineIndex >= codeLines.count {
                isAnimating = false
            }
            return
        }
        
        // Process the current line
        let line = codeLines[currentLineIndex]
        processCodeLine(line)
        
        // Schedule the next line after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + (1.0 / animationSpeed)) {
            currentLineIndex += 1
            advanceAnimation()
        }
    }
    
    private func processCodeLine(_ line: String) {
        // This is a simplified simulation of code execution
        // In a real app, you'd need a JavaScript interpreter
        
        // Check for variable assignments
        if line.contains("=") && (line.contains("let ") || line.contains("var ") || line.contains("const ")) {
            let parts = line.components(separatedBy: "=")
            if parts.count >= 2 {
                var variableName = parts[0]
                    .replacingOccurrences(of: "let ", with: "")
                    .replacingOccurrences(of: "var ", with: "")
                    .replacingOccurrences(of: "const ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Extract array from bracket notation like arr[i]
                if variableName.contains("[") && variableName.contains("]") {
                    variableName = String(variableName.split(separator: "[")[0])
                }
                
                let valueString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Simulate variable value
                if valueString.contains("new Map()") {
                    memoryValues[variableName] = "Map(0)"
                } else if valueString.contains("new Set()") {
                    memoryValues[variableName] = "Set(0)"
                } else if valueString.hasPrefix("[") {
                    // Array literal
                    let cleanValue = valueString
                        .replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                        .replacingOccurrences(of: ";", with: "")
                    
                    let arrayItems = cleanValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    memoryValues[variableName] = arrayItems
                } else if let intValue = Int(valueString.replacingOccurrences(of: ";", with: "")) {
                    memoryValues[variableName] = intValue
                } else if valueString == "0;" || valueString == "0" {
                    memoryValues[variableName] = 0
                } else if valueString == "true;" || valueString == "true" {
                    memoryValues[variableName] = true
                } else if valueString == "false;" || valueString == "false" {
                    memoryValues[variableName] = false
                } else if valueString.hasPrefix("\"") || valueString.hasPrefix("'") {
                    // String value
                    memoryValues[variableName] = valueString.replacingOccurrences(of: "\"", with: "")
                        .replacingOccurrences(of: "'", with: "")
                        .replacingOccurrences(of: ";", with: "")
                } else {
                    // Use placeholder for complex expressions
                    memoryValues[variableName] = "<computed value>"
                }
            }
        }
        
        // Check for console logs
        if line.contains("console.log(") {
            let start = line.range(of: "console.log(")!.upperBound
            let substring = line[start...]
            let end = substring.firstIndex(of: ")")!
            let content = substring[..<end].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Very basic simulation of output
            output.append("> " + content.replacingOccurrences(of: "\"", with: "")
                .replacingOccurrences(of: "'", with: ""))
        }
        
        // Special case for Two Sum function to show output
        if line.contains("return [map.get(complement), i];") && codeExample.title.contains("Two Sum") {
            output.append("> [0, 1]")
        }
        
        // Special case for animated progress
        if line.contains("this.progressElement.style.width = `${width}%`;") {
            memoryValues["width"] = Int.random(in: 0...100)
            memoryValues["progress"] = Double.random(in: 0...1).rounded(to: 2)
        }
    }
}

// Helper extension for rounding doubles
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// Preview
struct JSCodeAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = JSCodeViewModel()
        let example = JSCodeExample(

            title: "Sample Code",
            code: """
            // Example code
            function greet(name) {
                let message = "Hello, " + name + "!";
                console.log(message);
                return message;
            }
            
            greet("World");
            """,
            explanation: "This is a sample code explanation."
        )
        
        JSCodeAnimationView(viewModel: viewModel, codeExample: example)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
} 
