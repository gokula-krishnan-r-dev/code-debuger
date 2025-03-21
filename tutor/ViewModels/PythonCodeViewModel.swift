import SwiftUI
import Combine

class PythonCodeViewModel: ObservableObject {
    @Published var selectedCategory: PythonCategory?
    @Published var selectedExample: PythonCodeExample?
    @Published var codeHighlighted: Bool = true
    @Published var isDarkMode: Bool = false
    @Published var showLineNumbers: Bool = true
    @Published var showMemoryAddresses: Bool = false
    @Published var animationSpeed: Double = 1.0  // 1.0 = normal, 0.5 = slower, 2.0 = faster
    
    var allExamples: [PythonCodeExample] {
        PythonCodeExample.allExamples
    }
    
    func examplesForCategory(_ category: PythonCategory) -> [PythonCodeExample] {
        allExamples.filter { $0.category == category }
    }
    
    // Simulation of Python code execution
    func simulateExecution(for example: PythonCodeExample) -> [PythonExecutionStep] {
        // This would normally be powered by a Python interpreter backend
        // For demonstration, we'll create sample execution steps
        
        switch example.title {
        case "Recursive List Sum":
            return createRecursiveSumExecutionSteps()
        case "Enhanced Recursive List Sum":
            return createEnhancedListSumExecutionSteps()
        default:
            return []
        }
    }
    
    private func createRecursiveSumExecutionSteps() -> [PythonExecutionStep] {
        // Mock execution steps similar to the Python Tutor visualization shown in the images
        var steps: [PythonExecutionStep] = []
        
        // Step 1: Function definition
        steps.append(PythonExecutionStep(
            lineNumber: 1,
            nextLineNumber: 8,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "listSum", value: "<function listSum>", isNew: true, isChanged: false, objectReference: "func1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function listSum(numbers)",
                    type: .function
                )
            ],
            explanation: "Defined function listSum"
        ))
        
        // Step 2: Create myList
        steps.append(PythonExecutionStep(
            lineNumber: 8,
            nextLineNumber: 9,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "listSum", value: "<function listSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "myList", value: "(1, (2, (3, None)))", isNew: true, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function listSum(numbers)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "tuple1",
                    content: "(1, (2, (3, None)))",
                    type: .tuple
                )
            ],
            explanation: "Created nested tuple structure myList"
        ))
        
        // Step 3: Call listSum(myList)
        steps.append(PythonExecutionStep(
            lineNumber: 9,
            nextLineNumber: 1,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "listSum", value: "<function listSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "myList", value: "(1, (2, (3, None)))", isNew: false, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: true
                ),
                PythonFrameState(
                    name: "listSum",
                    variables: [
                        PythonVariableState(name: "numbers", value: "(1, (2, (3, None)))", isNew: true, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: false
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function listSum(numbers)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "tuple1",
                    content: "(1, (2, (3, None)))",
                    type: .tuple
                )
            ],
            explanation: "Calling listSum with myList as argument"
        ))
        
        // Step 4: Enter first recursion
        steps.append(PythonExecutionStep(
            lineNumber: 2,
            nextLineNumber: 4,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "listSum", value: "<function listSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "myList", value: "(1, (2, (3, None)))", isNew: false, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "listSum",
                    variables: [
                        PythonVariableState(name: "numbers", value: "(1, (2, (3, None)))", isNew: false, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function listSum(numbers)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "tuple1",
                    content: "(1, (2, (3, None)))",
                    type: .tuple
                )
            ],
            explanation: "Checking if numbers is empty"
        ))
        
        // ... Add more steps for the complete execution
        
        // Step 5: First unpacking
        steps.append(PythonExecutionStep(
            lineNumber: 5,
            nextLineNumber: 6,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "listSum", value: "<function listSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "myList", value: "(1, (2, (3, None)))", isNew: false, isChanged: false, objectReference: "tuple1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "listSum",
                    variables: [
                        PythonVariableState(name: "numbers", value: "(1, (2, (3, None)))", isNew: false, isChanged: false, objectReference: "tuple1"),
                        PythonVariableState(name: "f", value: "1", isNew: true, isChanged: false, objectReference: nil),
                        PythonVariableState(name: "rest", value: "(2, (3, None))", isNew: true, isChanged: false, objectReference: "tuple2")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function listSum(numbers)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "tuple1",
                    content: "(1, (2, (3, None)))",
                    type: .tuple
                ),
                PythonObjectState(
                    identifier: "tuple2",
                    content: "(2, (3, None))",
                    type: .tuple
                )
            ],
            explanation: "Unpacked tuple into f=1 and rest=(2, (3, None))"
        ))
        
        // Additional steps would follow for the complete execution...
        
        return steps
    }
    
    private func createEnhancedListSumExecutionSteps() -> [PythonExecutionStep] {
        // Implementation for the enhanced version with more steps to handle different data types
        var steps: [PythonExecutionStep] = []
        
        // Step 1: Function definition
        steps.append(PythonExecutionStep(
            lineNumber: 1,
            nextLineNumber: 13,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: true, isChanged: false, objectReference: "func1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                )
            ],
            explanation: "Defined function enhancedListSum"
        ))
        
        // Step 2: Create nested_list
        steps.append(PythonExecutionStep(
            lineNumber: 13,
            nextLineNumber: 14,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: true, isChanged: false, objectReference: "list1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Created nested list structure with various elements"
        ))
        
        // Step 3: Call enhancedListSum(nested_list)
        steps.append(PythonExecutionStep(
            lineNumber: 14,
            nextLineNumber: 2,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "enhancedListSum [call 1]",
                    variables: [
                        PythonVariableState(name: "data", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: true, isChanged: false, objectReference: "list1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Called enhancedListSum with the nested list as argument"
        ))
        
        // Step 4: Check first base case (None check)
        steps.append(PythonExecutionStep(
            lineNumber: 3,
            nextLineNumber: 5,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "enhancedListSum [call 1]",
                    variables: [
                        PythonVariableState(name: "data", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Checking if data is None (it's not)"
        ))
        
        // Step 5: Check second base case (number check)
        steps.append(PythonExecutionStep(
            lineNumber: 5,
            nextLineNumber: 8,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "enhancedListSum [call 1]",
                    variables: [
                        PythonVariableState(name: "data", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Checking if data is a number (it's not, it's a list)"
        ))
        
        // Step 6: Collection check and process list
        steps.append(PythonExecutionStep(
            lineNumber: 9,
            nextLineNumber: 10,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "enhancedListSum [call 1]",
                    variables: [
                        PythonVariableState(name: "data", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1"),
                        PythonVariableState(name: "total", value: "0", isNew: true, isChanged: false, objectReference: nil)
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Initialized total = 0 for processing the list elements"
        ))
        
        // Step 7: Final step - return result
        steps.append(PythonExecutionStep(
            lineNumber: 11,
            nextLineNumber: 14,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1")
                    ],
                    isActive: false
                ),
                PythonFrameState(
                    name: "enhancedListSum [call 1]",
                    variables: [
                        PythonVariableState(name: "data", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1"),
                        PythonVariableState(name: "total", value: "28", isNew: false, isChanged: true, objectReference: nil)
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "All elements processed, returning final sum of 28"
        ))
        
        // Result output
        steps.append(PythonExecutionStep(
            lineNumber: 14,
            nextLineNumber: 14,
            variables: [],
            frames: [
                PythonFrameState(
                    name: "Global frame",
                    variables: [
                        PythonVariableState(name: "enhancedListSum", value: "<function enhancedListSum>", isNew: false, isChanged: false, objectReference: "func1"),
                        PythonVariableState(name: "nested_list", value: "[1, [2, 3], [4, [5, 6]], None, 7]", isNew: false, isChanged: false, objectReference: "list1"),
                        PythonVariableState(name: "result", value: "28", isNew: true, isChanged: false, objectReference: nil)
                    ],
                    isActive: true
                )
            ],
            objects: [
                PythonObjectState(
                    identifier: "func1",
                    content: "function enhancedListSum(data)",
                    type: .function
                ),
                PythonObjectState(
                    identifier: "list1",
                    content: "[1, [2, 3], [4, [5, 6]], None, 7]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list2",
                    content: "[2, 3]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list3",
                    content: "[4, [5, 6]]",
                    type: .list
                ),
                PythonObjectState(
                    identifier: "list4",
                    content: "[5, 6]",
                    type: .list
                )
            ],
            explanation: "Program output: 28"
        ))
        
        return steps
    }
}

// Model for Python execution steps
struct PythonExecutionStep {
    let lineNumber: Int
    let nextLineNumber: Int
    let variables: [PythonVariableState]
    let frames: [PythonFrameState]
    let objects: [PythonObjectState]
    let explanation: String
}

struct PythonVariableState: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let isNew: Bool
    let isChanged: Bool
    let objectReference: String?
}

struct PythonFrameState: Identifiable {
    let id = UUID()
    let name: String
    let variables: [PythonVariableState]
    let isActive: Bool
}

struct PythonObjectState: Identifiable, Equatable {
    let id = UUID()
    let identifier: String
    let content: String
    let type: PythonObjectType
    
    static func == (lhs: PythonObjectState, rhs: PythonObjectState) -> Bool {
        lhs.identifier == rhs.identifier && 
        lhs.content == rhs.content && 
        lhs.type == rhs.type
    }
}

enum PythonObjectType: Equatable {
    case function
    case list
    case tuple
    case dictionary
    case string
    case number
    case none
} 