import SwiftUI

struct JSCodeEditorView: View {
    @Binding var code: String
    @Binding var selectedLine: Int
    var currentHighlightedLine: Int?
    var highlightColor: Color = .yellow
    var showLineNumbers: Bool = true
    var isEditable: Bool = true
    var fontSize: CGFloat = 14
    @Binding var editorFocused: Bool
    
    @State private var lines: [String] = []
    @State private var highlightedText: AttributedString = AttributedString("")
    @State private var scrollPosition: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme
    
    var onSubmit: (() -> Void)?
    
    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: 0) {
                if code.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                                HStack(spacing: 0) {
                                    if showLineNumbers {
                                        Text("\(index + 1)")
                                            .font(.system(size: fontSize, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .frame(width: 40, alignment: .trailing)
                                            .padding(.trailing, 8)
                                    }
                                    
                                    SyntaxHighlightedText(text: line, fontSize: fontSize)
                                        .padding(.trailing, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .id("line-\(index + 1)")
                                }
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .background(backgroundForLine(at: index + 1))
                                .onTapGesture {
                                    selectedLine = index + 1
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: selectedLine) { newValue in
                        withAnimation(.easeOut(duration: 0.3)) {
                            scrollView.scrollTo("line-\(newValue)", anchor: .center)
                        }
                    }
                }
            }
            .onChange(of: code) { newValue in
                parseCode(newValue)
            }
            .onChange(of: currentHighlightedLine) { newValue in
                if let line = newValue {
                    withAnimation(.easeOut(duration: 0.3)) {
                        scrollView.scrollTo("line-\(line)", anchor: .center)
                    }
                }
            }
            .onAppear {
                parseCode(code)
            }
        }
        .background(backgroundGradient)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Enter JavaScript code here")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if isEditable {
                Text("Tap to edit")
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .background(backgroundGradient)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(hex: "#1E1E1E") : Color(hex: "#FCFCFC"),
                colorScheme == .dark ? Color(hex: "#252525") : Color(hex: "#F8F8F8")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func backgroundForLine(at line: Int) -> some View {
        Group {
            if line == currentHighlightedLine {
                highlightColor.opacity(0.3)
                    .overlay(
                        Rectangle()
                            .frame(width: 3)
                            .foregroundColor(highlightColor)
                            .padding(.vertical, -2),
                        alignment: .leading
                    )
            } else if line == selectedLine {
                Color.blue.opacity(0.1)
            } else {
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentHighlightedLine)
    }
    
    private func parseCode(_ sourceCode: String) {
        lines = sourceCode.components(separatedBy: .newlines)
    }
}

// Extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// UITextView wrapper for editable code lines
struct UITextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var isFirstResponder: Bool
    var onFocus: (() -> Void)?
    var onSubmit: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.backgroundColor = .clear
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.spellCheckingType = .no
        textView.isScrollEnabled = false
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewRepresentable
        
        init(_ parent: UITextViewRepresentable) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocus?()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Handle return key
            if text == "\n" && parent.onSubmit != nil {
                parent.onSubmit?()
                return false
            }
            return true
        }
    }
}

// Simple syntax highlighting for JavaScript code
struct SyntaxHighlightedText: View {
    let text: String
    let fontSize: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            Text(AttributedString(highlightSyntax(text)))
                .font(.system(size: fontSize, design: .monospaced))
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func highlightSyntax(_ code: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        
        // Define color attributes
        let keywordColor = UIColor(red: 0.7, green: 0.2, blue: 0.5, alpha: 1.0) // purple
        let stringColor = UIColor(red: 0.2, green: 0.6, blue: 0.1, alpha: 1.0) // green
        let commentColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0) // gray
        let numberColor = UIColor(red: 0.9, green: 0.5, blue: 0.0, alpha: 1.0) // orange
        let functionColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0) // blue
        
        // Apply syntax highlighting
        
        // Comments
        let commentPattern = "//.*$"
        do {
            let regex = try NSRegularExpression(pattern: commentPattern, options: [])
            let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: commentColor, range: match.range)
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        // Keywords
        let keywords = ["function", "let", "var", "const", "if", "else", "for", "while", "return", "break", "continue", 
                       "case", "switch", "default", "try", "catch", "finally", "throw", "new", "delete", "typeof", 
                       "instanceof", "class", "this", "super", "extends", "import", "export", "async", "await", "yield"]
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                }
            } catch {
                print("Invalid regex: \(error.localizedDescription)")
            }
        }
        
        // String literals
        let stringPatterns = ["\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", "'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'"]
        for pattern in stringPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: stringColor, range: match.range)
                }
            } catch {
                print("Invalid regex: \(error.localizedDescription)")
            }
        }
        
        // Numbers
        let numberPattern = "\\b[-+]?\\d*\\.?\\d+([eE][-+]?\\d+)?\\b"
        do {
            let regex = try NSRegularExpression(pattern: numberPattern, options: [])
            let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: numberColor, range: match.range)
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        // Function calls
        let functionPattern = "\\b([a-zA-Z_$][a-zA-Z0-9_$]*)\\s*\\("
        do {
            let regex = try NSRegularExpression(pattern: functionPattern, options: [])
            let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
            for match in matches {
                if match.numberOfRanges > 1 {
                    attributedString.addAttribute(.foregroundColor, value: functionColor, range: match.range(at: 1))
                }
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        return attributedString
    }
} 