import SwiftUI
import Combine

class JSCodeViewModel: ObservableObject {
    @Published var tutorials: [JavaScriptTutorial]
    @Published var selectedTutorial: JavaScriptTutorial?
    @Published var selectedExample: JSCodeExample?
    @Published var selectedCategory: JSCategory?
    @Published var codeHighlighted: Bool = true
    @Published var isDarkMode: Bool = false
    
    init() {
        // Initialize with tutorials from the model
        self.tutorials = JavaScriptTutorial.allTutorials
    }
    
    // MARK: - Tutorial Filtering
    
    func tutorialsForCategory(_ category: JSCategory) -> [JavaScriptTutorial] {
        tutorials.filter { $0.category == category }
    }
    
    func tutorialsForLevel(_ level: JavaScriptTutorial.Level) -> [JavaScriptTutorial] {
        tutorials.filter { $0.level == level }
    }
    
    // MARK: - Tutorial and Example Selection
    
    func selectTutorial(_ tutorial: JavaScriptTutorial) {
        selectedTutorial = tutorial
        if let firstExample = tutorial.examples.first {
            selectedExample = firstExample
        }
    }
    
    func selectExample(_ example: JSCodeExample) {
        selectedExample = example
    }
    
    func getCurrentExample() -> JSCodeExample? {
        return selectedExample
    }
    
    // MARK: - Code Highlighting
    
    func getHighlightedCode(_ code: String) -> Text {
        var result = Text("")
        
        // Regular expressions for different syntax elements
        let keywords = try! NSRegularExpression(pattern: "\\b(var|let|const|function|return|if|else|for|while|do|switch|case|break|continue|new|this|typeof|instanceof|true|false|null|undefined|class|extends|import|export|try|catch|finally|throw|async|await|yield)\\b", options: [])
        let strings = try! NSRegularExpression(pattern: "(\"|')(.*?)\\1", options: [])
        let numbers = try! NSRegularExpression(pattern: "\\b\\d+(\\.\\d+)?\\b", options: [])
        let comments = try! NSRegularExpression(pattern: "//.*?$|/\\*.*?\\*/", options: [.dotMatchesLineSeparators])
        let functions = try! NSRegularExpression(pattern: "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\s*\\(", options: [])
        
        let lines = code.components(separatedBy: "\n")
        
        for (index, line) in lines.enumerated() {
            var lineText = Text("")
            let nsLine = line as NSString
            var processedChars = Set<Int>()
            
            // Find comments (process these first to avoid overlap with other patterns)
            let commentMatches = comments.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            for match in commentMatches {
                let range = match.range
                for i in range.location..<(range.location + range.length) {
                    processedChars.insert(i)
                }
                let commentText = nsLine.substring(with: range)
                lineText = lineText + Text(commentText).foregroundColor(.gray)
            }
            
            // Find strings
            let stringMatches = strings.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            for match in stringMatches {
                let range = match.range
                var skip = false
                for i in range.location..<(range.location + range.length) {
                    if processedChars.contains(i) {
                        skip = true
                        break
                    }
                    processedChars.insert(i)
                }
                if !skip {
                    let stringText = nsLine.substring(with: range)
                    lineText = lineText + Text(stringText).foregroundColor(.green)
                }
            }
            
            // Find keywords
            let keywordMatches = keywords.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            for match in keywordMatches {
                let range = match.range
                var skip = false
                for i in range.location..<(range.location + range.length) {
                    if processedChars.contains(i) {
                        skip = true
                        break
                    }
                    processedChars.insert(i)
                }
                if !skip {
                    let keywordText = nsLine.substring(with: range)
                    lineText = lineText + Text(keywordText).foregroundColor(.blue).fontWeight(.bold)
                }
            }
            
            // Find numbers
            let numberMatches = numbers.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            for match in numberMatches {
                let range = match.range
                var skip = false
                for i in range.location..<(range.location + range.length) {
                    if processedChars.contains(i) {
                        skip = true
                        break
                    }
                    processedChars.insert(i)
                }
                if !skip {
                    let numberText = nsLine.substring(with: range)
                    lineText = lineText + Text(numberText).foregroundColor(.orange)
                }
            }
            
            // Find function calls
            let functionMatches = functions.matches(in: line, options: [], range: NSRange(location: 0, length: nsLine.length))
            for match in functionMatches {
                let range = NSRange(location: match.range.location, length: match.range.length - 1) // Exclude the '('
                var skip = false
                for i in range.location..<(range.location + range.length) {
                    if processedChars.contains(i) {
                        skip = true
                        break
                    }
                    processedChars.insert(i)
                }
                if !skip {
                    let functionText = nsLine.substring(with: range)
                    lineText = lineText + Text(functionText).foregroundColor(.purple)
                }
                // Add the '(' character
                if !processedChars.contains(range.location + range.length) {
                    lineText = lineText + Text("(")
                    processedChars.insert(range.location + range.length)
                }
            }
            
            // Add unprocessed characters as plain text
            for i in 0..<nsLine.length {
                if !processedChars.contains(i) {
                    let char = nsLine.substring(with: NSRange(location: i, length: 1))
                    lineText = lineText + Text(char)
                }
            }
            
            // Add new line after each line except the last one
            if index < lines.count - 1 {
                result = result + lineText + Text("\n")
            } else {
                result = result + lineText
            }
        }
        
        return codeHighlighted ? result : Text(code)
    }
    
    // MARK: - Toggle Features
    
    func toggleCodeHighlighting() {
        codeHighlighted.toggle()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    // Add this function to the JSCodeViewModel class to support code highlighting
    func highlightedCode(_ code: String) -> Text {
        let lines = code.components(separatedBy: "\n")
        
        var resultText = Text("")
        
        for (index, line) in lines.enumerated() {
            // Apply syntax highlighting for each line
            let highlightedLine = highlightSyntax(line)
            
            // Append the highlighted line to the result
            resultText = resultText + highlightedLine
            
            // Add a newline if not the last line
            if index < lines.count - 1 {
                resultText = resultText + Text("\n")
            }
        }
        
        return resultText
    }
    
    private func highlightSyntax(_ line: String) -> Text {
        // Regular expressions for common JavaScript syntax
        let keywordPattern = "\\b(function|return|if|else|for|while|do|switch|case|break|continue|try|catch|finally|var|let|const|new|this|class|extends|import|export|from|async|await|yield)\\b"
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        let stringPattern = "([\"'])(.*?)\\1"
        let commentPattern = "(\\/\\/.*)|(\\/\\*[\\s\\S]*?\\*\\/)"
        
        // Recursive function to parse and highlight tokens
        func parseAndHighlight(_ text: String, offset: Int = 0) -> [TextToken] {
            guard !text.isEmpty else { return [] }
            
            var tokens: [TextToken] = []
            var remainingText = text
            
            // Check for comments first (highest priority)
            if let match = remainingText.range(of: commentPattern, options: .regularExpression) {
                let beforeComment = String(remainingText[..<match.lowerBound])
                let comment = String(remainingText[match])
                let afterComment = String(remainingText[match.upperBound...])
                
                if !beforeComment.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(beforeComment, offset: offset))
                }
                
                tokens.append(TextToken(text: comment, color: .green))
                
                if !afterComment.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(afterComment, offset: offset + beforeComment.count + comment.count))
                }
                
                return tokens
            }
            
            // Check for strings
            if let match = remainingText.range(of: stringPattern, options: .regularExpression) {
                let beforeString = String(remainingText[..<match.lowerBound])
                let string = String(remainingText[match])
                let afterString = String(remainingText[match.upperBound...])
                
                if !beforeString.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(beforeString, offset: offset))
                }
                
                tokens.append(TextToken(text: string, color: .orange))
                
                if !afterString.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(afterString, offset: offset + beforeString.count + string.count))
                }
                
                return tokens
            }
            
            // Check for keywords
            if let match = remainingText.range(of: keywordPattern, options: .regularExpression) {
                let beforeKeyword = String(remainingText[..<match.lowerBound])
                let keyword = String(remainingText[match])
                let afterKeyword = String(remainingText[match.upperBound...])
                
                if !beforeKeyword.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(beforeKeyword, offset: offset))
                }
                
                tokens.append(TextToken(text: keyword, color: .purple))
                
                if !afterKeyword.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(afterKeyword, offset: offset + beforeKeyword.count + keyword.count))
                }
                
                return tokens
            }
            
            // Check for numbers
            if let match = remainingText.range(of: numberPattern, options: .regularExpression) {
                let beforeNumber = String(remainingText[..<match.lowerBound])
                let number = String(remainingText[match])
                let afterNumber = String(remainingText[match.upperBound...])
                
                if !beforeNumber.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(beforeNumber, offset: offset))
                }
                
                tokens.append(TextToken(text: number, color: .blue))
                
                if !afterNumber.isEmpty {
                    tokens.append(contentsOf: parseAndHighlight(afterNumber, offset: offset + beforeNumber.count + number.count))
                }
                
                return tokens
            }
            
            // Add the remaining text as-is
            tokens.append(TextToken(text: remainingText, color: .primary))
            
            return tokens
        }
        
        // Helper struct to represent a token with text and color
        struct TextToken {
            let text: String
            let color: Color
        }
        
        let tokens = parseAndHighlight(line)
        
        var result = Text("")
        
        for token in tokens {
            result = result + Text(token.text).foregroundColor(token.color)
        }
        
        return result
    }
} 