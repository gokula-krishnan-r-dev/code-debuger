import Foundation

class TutorialViewModel: ObservableObject {
    @Published var tutorials: [Tutorial] = Tutorial.sampleTutorials + [Tutorial.forLoopTutorial]
    @Published var selectedCategory: TutorialCategory?
    @Published var selectedTutorial: Tutorial?
    @Published var currentExplanationIndex: Int = 0
    
    // Code execution state
    @Published var codeExecutionSteps: [CodeExecution] = Tutorial.forLoopExecutionSteps
    @Published var currentExecutionStep: Int = 0
    @Published var isExecutionMode: Bool = false
    
    var filteredTutorials: [Tutorial] {
        if let category = selectedCategory {
            return tutorials.filter { $0.category == category }
        }
        return tutorials
    }
    
    func nextExplanation() {
        if let tutorial = selectedTutorial {
            // The Tutorial model now uses 'content' instead of 'explanation'
            // Since content is a single string, we'll need to modify this approach
            // For now, we'll just disable this functionality
            // TODO: Implement pagination for content if needed
        }
    }
    
    func previousExplanation() {
        // The Tutorial model now uses 'content' instead of 'explanation'
        // For now, we'll just disable this functionality
        // TODO: Implement pagination for content if needed
    }
    
    func resetExplanationIndex() {
        currentExplanationIndex = 0
    }
    
    // Code execution controls
    func startExecution() {
        isExecutionMode = true
        currentExecutionStep = 0
    }
    
    func nextExecutionStep() {
        if currentExecutionStep < codeExecutionSteps.count - 1 {
            currentExecutionStep += 1
        }
    }
    
    func previousExecutionStep() {
        if currentExecutionStep > 0 {
            currentExecutionStep -= 1
        }
    }
    
    func resetExecution() {
        isExecutionMode = false
        currentExecutionStep = 0
    }
    
    var currentStep: CodeExecution? {
        if currentExecutionStep < codeExecutionSteps.count {
            return codeExecutionSteps[currentExecutionStep]
        }
        return nil
    }
} 