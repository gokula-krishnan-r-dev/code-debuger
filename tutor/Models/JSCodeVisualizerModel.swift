import Foundation
import SwiftUI

enum JSDataType {
    case number
    case string
    case boolean
    case array
    case object
    case function
    case undefined
    case null
    
    var color: Color {
        switch self {
        case .number: return .blue
        case .string: return .green
        case .boolean: return .purple
        case .array, .object: return .orange
        case .function: return .red
        case .undefined, .null: return .gray
        }
    }
    
    var name: String {
        switch self {
        case .number: return "Number"
        case .string: return "String"
        case .boolean: return "Boolean"
        case .array: return "Array"
        case .object: return "Object"
        case .function: return "Function"
        case .undefined: return "undefined"
        case .null: return "null"
        }
    }
}

struct JSVariableValue: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let value: String
    let stringValue: String
    let type: JSDataType
    let isNew: Bool
    let isModified: Bool
    let reference: String?
    let references: [String]?
    
    static func == (lhs: JSVariableValue, rhs: JSVariableValue) -> Bool {
        lhs.id == rhs.id
    }
    
    var hashValue: Int {
        stringValue.hashValue
    }
}

struct JSExecutionState: Identifiable, Equatable {
    let id = UUID()
    let step: Int
    let frames: [JSExecutionFrame]
    let heapObjects: [JSHeapObject]
    let activeFrameId: UUID
    let currentLine: Int
    let consoleOutput: [String]
    let explanation: String
    let hasError: Bool
    let errorMessage: String?
    
    static func == (lhs: JSExecutionState, rhs: JSExecutionState) -> Bool {
        lhs.id == rhs.id
    }
}

struct JSHeapObject: Identifiable {
    let id: String
    let type: JSDataType
    let properties: [(name: String, value: JSVariableValue)]
    let isNew: Bool
    
    static func == (lhs: JSHeapObject, rhs: JSHeapObject) -> Bool {
        lhs.id == rhs.id
    }
}

struct JSExecutionFrame: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let isGlobal: Bool
    let variables: [JSVariableValue]
    let lineNumber: Int
    let isActive: Bool
    
    static func == (lhs: JSExecutionFrame, rhs: JSExecutionFrame) -> Bool {
        lhs.id == rhs.id
    }
}

class JSCode {
    let sourceCode: String
    let displayName: String
    
    init(sourceCode: String, displayName: String) {
        self.sourceCode = sourceCode
        self.displayName = displayName
    }
    
    // Parse code into lines
    var lines: [String] {
        sourceCode.components(separatedBy: .newlines)
    }
}

// Example built-in programs
extension JSCode {
    static let generateParentheses = JSCode(
        sourceCode: """
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
        displayName: "Generate Parentheses"
    )
    
    static let twoSum = JSCode(
        sourceCode: """
var twoSum = function(nums, target) {
    const map = new Map();
    
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        
        if (map.has(complement)) {
            return [map.get(complement), i];
        }
        
        map.set(nums[i], i);
    }
    
    return [];
};
""",
        displayName: "Two Sum"
    )
    
    static let fibonacci = JSCode(
        sourceCode: """
function fibonacci(n) {
    if (n <= 1) {
        return n;
    }
    
    return fibonacci(n - 1) + fibonacci(n - 2);
}
""",
        displayName: "Fibonacci"
    )
    
    static let sorting = JSCode(
        sourceCode: """
function bubbleSort(arr) {
    const n = arr.length;
    
    for (let i = 0; i < n - 1; i++) {
        for (let j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                // Swap arr[j] and arr[j + 1]
                [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
            }
        }
    }
    
    return arr;
}
""",
        displayName: "Bubble Sort"
    )
    
    static let samples: [JSCode] = [generateParentheses, twoSum, fibonacci, sorting]
} 