import Foundation

// Model representing a step in code execution
struct JSExecutionStep: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let codeHighlight: JSExecutionStep.CodeHighlightType
    let scope: String // "Global", "Function", etc.
    let variables: [JSVariableState]
    let output: String? // Console output
    let explanation: String
    let nextStepHint: String?
    
    enum CodeHighlightType {
        case executing
        case nextToExecute
        case completed
        case error
    }
}

// Model representing a variable during execution
struct JSVariableState: Identifiable {
    let id = UUID()
    let name: String
    let value: JSValue
    let isNew: Bool // Highlight newly created variables
    let isChanged: Bool // Highlight recently changed variables
}

// Representation of JavaScript values
enum JSValue: Equatable {
    case string(String)
    case number(Double)
    case boolean(Bool)
    case null
    case undefined
    case array([JSValue])
    case object([String: JSValue])
    case function(String) // Function name or description
    
    // String representation for display
    var displayValue: String {
        switch self {
        case .string(let value):
            return "\"\(value)\""
        case .number(let value):
            return value.truncatingRemainder(dividingBy: 1) == 0 ? 
                String(format: "%.0f", value) : String(value)
        case .boolean(let value):
            return value ? "true" : "false"
        case .null:
            return "null"
        case .undefined:
            return "undefined"
        case .array(let values):
            let elements = values.map { $0.displayValue }.joined(separator: ", ")
            return "[\(elements)]"
        case .object(let dict):
            let entries = dict.map { "\"\($0.key)\": \($0.value.displayValue)" }.joined(separator: ", ")
            return "{\(entries)}"
        case .function(let desc):
            return "function \(desc)"
        }
    }
    
    // Color for display
    var displayColor: String {
        switch self {
        case .string: return "green"
        case .number: return "blue"
        case .boolean: return "purple"
        case .null, .undefined: return "gray"
        case .array, .object: return "orange"
        case .function: return "red"
        }
    }
}

// Represents a full code execution visualization
struct JSCodeExecution {
    let code: String
    let steps: [JSExecutionStep]
    let title: String
    let description: String
}

// Sample code executions for the app
extension JSCodeExecution {
    static let variablesExecution = JSCodeExecution(
        code: """
        // Variables example
        let name = "JavaScript";
        const version = 2023;
        var isAwesome = true;
        
        console.log(name);
        console.log(version);
        console.log(isAwesome);
        """,
        steps: [
            JSExecutionStep(
                lineNumber: 1,
                codeHighlight: .executing,
                scope: "Global",
                variables: [],
                output: nil,
                explanation: "The code begins execution. This is a comment, so no action is taken.",
                nextStepHint: "Declaring a variable with let"
            ),
            JSExecutionStep(
                lineNumber: 2,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A variable 'name' is declared with let and assigned the string value 'JavaScript'.",
                nextStepHint: "Declaring a constant with const"
            ),
            JSExecutionStep(
                lineNumber: 3,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "version",
                        value: .number(2023),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A constant 'version' is declared with const and assigned the numeric value 2023.",
                nextStepHint: "Declaring a variable with var"
            ),
            JSExecutionStep(
                lineNumber: 4,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "version",
                        value: .number(2023),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "isAwesome",
                        value: .boolean(true),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A variable 'isAwesome' is declared with var and assigned the boolean value true.",
                nextStepHint: "Using console.log to output values"
            ),
            JSExecutionStep(
                lineNumber: 6,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "version",
                        value: .number(2023),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "isAwesome",
                        value: .boolean(true),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "JavaScript",
                explanation: "The value of the 'name' variable is output to the console.",
                nextStepHint: "Logging a numeric value"
            ),
            JSExecutionStep(
                lineNumber: 7,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "version",
                        value: .number(2023),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "isAwesome",
                        value: .boolean(true),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "2023",
                explanation: "The value of the 'version' constant is output to the console.",
                nextStepHint: "Logging a boolean value"
            ),
            JSExecutionStep(
                lineNumber: 8,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "name",
                        value: .string("JavaScript"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "version",
                        value: .number(2023),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "isAwesome",
                        value: .boolean(true),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "true",
                explanation: "The value of the 'isAwesome' variable is output to the console.",
                nextStepHint: "Execution complete"
            )
        ],
        title: "Variable Declaration and Console Output",
        description: "This example demonstrates how to declare variables using let, const, and var, and how to output their values to the console."
    )
    
    static let functionExecution = JSCodeExecution(
        code: """
        // Function example
        function add(a, b) {
            const sum = a + b;
            return sum;
        }
        
        const result = add(5, 3);
        console.log(result);
        """,
        steps: [
            JSExecutionStep(
                lineNumber: 1,
                codeHighlight: .executing,
                scope: "Global",
                variables: [],
                output: nil,
                explanation: "The code begins execution. This is a comment, so no action is taken.",
                nextStepHint: "Defining a function"
            ),
            JSExecutionStep(
                lineNumber: 2,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "add",
                        value: .function("add(a, b)"),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A function named 'add' is defined, which takes two parameters: 'a' and 'b'.",
                nextStepHint: "Calling the function"
            ),
            JSExecutionStep(
                lineNumber: 6,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "add",
                        value: .function("add(a, b)"),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "We're about to call the 'add' function with arguments 5 and 3.",
                nextStepHint: "Entering function execution"
            ),
            JSExecutionStep(
                lineNumber: 2,
                codeHighlight: .executing,
                scope: "Function: add",
                variables: [
                    JSVariableState(
                        name: "a",
                        value: .number(5),
                        isNew: true,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "b",
                        value: .number(3),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "The function is called with arguments 5 and 3. Parameters 'a' and 'b' are assigned these values.",
                nextStepHint: "Adding the parameters"
            ),
            JSExecutionStep(
                lineNumber: 3,
                codeHighlight: .executing,
                scope: "Function: add",
                variables: [
                    JSVariableState(
                        name: "a",
                        value: .number(5),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "b",
                        value: .number(3),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "sum",
                        value: .number(8),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A constant 'sum' is declared and assigned the result of adding 'a' and 'b' (5 + 3 = 8).",
                nextStepHint: "Returning the result"
            ),
            JSExecutionStep(
                lineNumber: 4,
                codeHighlight: .executing,
                scope: "Function: add",
                variables: [
                    JSVariableState(
                        name: "a",
                        value: .number(5),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "b",
                        value: .number(3),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "sum",
                        value: .number(8),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "The function returns the value of 'sum', which is 8.",
                nextStepHint: "Returning to the calling code"
            ),
            JSExecutionStep(
                lineNumber: 6,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "add",
                        value: .function("add(a, b)"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "result",
                        value: .number(8),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "The constant 'result' is assigned the return value of the add function, which is 8.",
                nextStepHint: "Logging the result"
            ),
            JSExecutionStep(
                lineNumber: 7,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "add",
                        value: .function("add(a, b)"),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "result",
                        value: .number(8),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "8",
                explanation: "The value of 'result' (8) is output to the console.",
                nextStepHint: "Execution complete"
            )
        ],
        title: "Function Definition and Execution",
        description: "This example demonstrates how to define a function, call it with arguments, and use its return value."
    )
    
    static let arrayExecution = JSCodeExecution(
        code: """
        // Array methods example
        const numbers = [1, 2, 3, 4, 5];
        
        // Map: multiply each element by 2
        const doubled = numbers.map(num => num * 2);
        console.log(doubled);
        
        // Filter: keep only even numbers
        const evenNumbers = numbers.filter(num => num % 2 === 0);
        console.log(evenNumbers);
        """,
        steps: [
            JSExecutionStep(
                lineNumber: 1,
                codeHighlight: .executing,
                scope: "Global",
                variables: [],
                output: nil,
                explanation: "The code begins execution. This is a comment, so no action is taken.",
                nextStepHint: "Creating an array"
            ),
            JSExecutionStep(
                lineNumber: 2,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "numbers",
                        value: .array([.number(1), .number(2), .number(3), .number(4), .number(5)]),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "A constant 'numbers' is declared and assigned an array with values [1, 2, 3, 4, 5].",
                nextStepHint: "Using the map method"
            ),
            JSExecutionStep(
                lineNumber: 4,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "numbers",
                        value: .array([.number(1), .number(2), .number(3), .number(4), .number(5)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "doubled",
                        value: .array([.number(2), .number(4), .number(6), .number(8), .number(10)]),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "The map method creates a new array by applying the function 'num => num * 2' to each element of the 'numbers' array. Each value is multiplied by 2.",
                nextStepHint: "Logging the mapped array"
            ),
            JSExecutionStep(
                lineNumber: 5,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "numbers",
                        value: .array([.number(1), .number(2), .number(3), .number(4), .number(5)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "doubled",
                        value: .array([.number(2), .number(4), .number(6), .number(8), .number(10)]),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "[2, 4, 6, 8, 10]",
                explanation: "The 'doubled' array is output to the console.",
                nextStepHint: "Using the filter method"
            ),
            JSExecutionStep(
                lineNumber: 7,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "numbers",
                        value: .array([.number(1), .number(2), .number(3), .number(4), .number(5)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "doubled",
                        value: .array([.number(2), .number(4), .number(6), .number(8), .number(10)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "evenNumbers",
                        value: .array([.number(2), .number(4)]),
                        isNew: true,
                        isChanged: false
                    )
                ],
                output: nil,
                explanation: "The filter method creates a new array with only the elements that pass the test function 'num => num % 2 === 0'. Only even numbers (2 and 4) are included.",
                nextStepHint: "Logging the filtered array"
            ),
            JSExecutionStep(
                lineNumber: 8,
                codeHighlight: .executing,
                scope: "Global",
                variables: [
                    JSVariableState(
                        name: "numbers",
                        value: .array([.number(1), .number(2), .number(3), .number(4), .number(5)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "doubled",
                        value: .array([.number(2), .number(4), .number(6), .number(8), .number(10)]),
                        isNew: false,
                        isChanged: false
                    ),
                    JSVariableState(
                        name: "evenNumbers",
                        value: .array([.number(2), .number(4)]),
                        isNew: false,
                        isChanged: false
                    )
                ],
                output: "[2, 4]",
                explanation: "The 'evenNumbers' array is output to the console.",
                nextStepHint: "Execution complete"
            )
        ],
        title: "Array Methods: Map and Filter",
        description: "This example demonstrates how to use array methods to transform and filter data."
    )
    
    // List of all available executions
    static let allExecutions = [
        variablesExecution,
        functionExecution,
        arrayExecution
    ]
} 