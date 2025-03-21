import Foundation

struct CodeExecution: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let nextLineNumber: Int
    let frameState: [FrameState]
    let explanation: String
}

struct FrameState: Identifiable {
    let id = UUID()
    let name: String
    let variables: [VariableState]
}

struct VariableState: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let reference: String? // For visualizing references to objects
}

extension Tutorial {
    static let forLoopTutorial = Tutorial(
        title: "For Loop Iteration",
        description: "Learn how a for loop executes step by step",
        category: .basics,
        content: """
        def process_numbers():
            numbers = [1, 2, 3, 4, 5]
            sum = 0
            
            for num in numbers:
                sum += num
                if num % 2 == 0:
                    print(f"{num} is even")
                else:
                    print(f"{num} is odd")
                    
            return sum
            
        result = process_numbers()
        """,
        difficulty: 2
    )
    
    static let forLoopExecutionSteps: [CodeExecution] = [
        CodeExecution(
            lineNumber: 1,
            nextLineNumber: 2,
            frameState: [
                FrameState(name: "Global", variables: [])
            ],
            explanation: "We begin by defining the process_numbers function."
        ),
        CodeExecution(
            lineNumber: 11,
            nextLineNumber: 1,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ])
            ],
            explanation: "The function is defined and we're about to call it."
        ),
        CodeExecution(
            lineNumber: 1,
            nextLineNumber: 2,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [])
            ],
            explanation: "We enter the process_numbers function."
        ),
        CodeExecution(
            lineNumber: 2,
            nextLineNumber: 3,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1")
                ])
            ],
            explanation: "We initialize the numbers list with values 1 through 5."
        ),
        CodeExecution(
            lineNumber: 3,
            nextLineNumber: 4,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "0", reference: nil)
                ])
            ],
            explanation: "We initialize the sum variable to 0."
        ),
        CodeExecution(
            lineNumber: 4,
            nextLineNumber: 5,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "0", reference: nil),
                    VariableState(name: "num", value: "1", reference: nil)
                ])
            ],
            explanation: "We begin the first iteration of the for loop with num = 1."
        ),
        CodeExecution(
            lineNumber: 5,
            nextLineNumber: 6,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "1", reference: nil),
                    VariableState(name: "num", value: "1", reference: nil)
                ])
            ],
            explanation: "We add num (1) to sum, making sum = 1."
        ),
        CodeExecution(
            lineNumber: 6,
            nextLineNumber: 8,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "1", reference: nil),
                    VariableState(name: "num", value: "1", reference: nil)
                ])
            ],
            explanation: "We check if num (1) is even. 1 % 2 = 1, so it's not even."
        ),
        CodeExecution(
            lineNumber: 8,
            nextLineNumber: 4,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "1", reference: nil),
                    VariableState(name: "num", value: "1", reference: nil)
                ])
            ],
            explanation: "We print \"1 is odd\" and continue to the next iteration."
        ),
        CodeExecution(
            lineNumber: 4,
            nextLineNumber: 5,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "1", reference: nil),
                    VariableState(name: "num", value: "2", reference: nil)
                ])
            ],
            explanation: "We begin the second iteration of the for loop with num = 2."
        ),
        CodeExecution(
            lineNumber: 5,
            nextLineNumber: 6,
            frameState: [
                FrameState(name: "Global", variables: [
                    VariableState(name: "process_numbers", value: "function", reference: nil)
                ]),
                FrameState(name: "process_numbers", variables: [
                    VariableState(name: "numbers", value: "[1, 2, 3, 4, 5]", reference: "list1"),
                    VariableState(name: "sum", value: "3", reference: nil),
                    VariableState(name: "num", value: "2", reference: nil)
                ])
            ],
            explanation: "We add num (2) to sum (1), making sum = 3."
        )
    ]
} 
