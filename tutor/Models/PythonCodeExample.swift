import Foundation

struct PythonCodeExample: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let code: String
    let difficulty: Difficulty
    let category: PythonCategory
    let knownLimitations: String?
    let isInteractive: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PythonCodeExample, rhs: PythonCodeExample) -> Bool {
        lhs.id == rhs.id
    }
    
    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
    
    // Sample examples
    static let recursiveSumExample = PythonCodeExample(
        title: "Recursive List Sum",
        description: "A function that demonstrates recursion by summing elements in a nested list structure.",
        code: """
def listSum(numbers):
    if not numbers:
        return 0
    else:
        (f, rest) = numbers
        return f + listSum(rest)

myList = (1, (2, (3, None)))
total = listSum(myList)
print(total)  # Should print 6
""",
        difficulty: .intermediate,
        category: .recursion,
        knownLimitations: "Only works with proper tuple-structured lists.",
        isInteractive: true
    )
    
    static let enhancedListSumExample = PythonCodeExample(
        title: "Enhanced Recursive List Sum",
        description: "An improved recursive function that handles various list types and nested structures.",
        code: """
def enhancedListSum(data):
    # Base cases
    if data is None:
        return 0
    if isinstance(data, (int, float)):
        return data
    
    # Handle different collection types
    if isinstance(data, (list, tuple)):
        total = 0
        for item in data:
            total += enhancedListSum(item)
        return total
    
    # Unsupported type
    return 0

# Test with various structures
nested_list = [1, [2, 3], [4, [5, 6]], None, 7]
print(enhancedListSum(nested_list))  # Should print 28
""",
        difficulty: .intermediate,
        category: .recursion,
        knownLimitations: nil,
        isInteractive: true
    )
    
    static let allExamples: [PythonCodeExample] = [
        recursiveSumExample,
        enhancedListSumExample
    ]
}

enum PythonCategory: String, CaseIterable, Identifiable {
    case basics = "Python Basics"
    case functions = "Functions"
    case dataStructures = "Data Structures"
    case recursion = "Recursion"
    case objectOriented = "Object-Oriented Programming"
    case algorithms = "Algorithms"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .basics: return "1.square"
        case .functions: return "function"
        case .dataStructures: return "square.stack.3d.up"
        case .recursion: return "arrow.triangle.branch"
        case .objectOriented: return "cube"
        case .algorithms: return "chart.bar.xaxis"
        }
    }
}

// Import missing dependency for Color
import SwiftUI 