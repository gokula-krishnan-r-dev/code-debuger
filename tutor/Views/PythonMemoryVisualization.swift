import SwiftUI

struct PythonMemoryVisualization: View {
    let objects: [PythonObjectState]
    let showReferences: Bool
    @State private var showConnections = true
    @State private var animateConnections = false
    @State private var hoveredObjectId: String? = nil
    @State private var highlightedConnections: [String: Bool] = [:]
    @State private var objectScales: [String: CGFloat] = [:]
    
    var body: some View {
        ZStack {
            // Optional connections between objects
            if showReferences && showConnections {
                connectionLines
                    .opacity(0.7)
                    .animation(.easeInOut(duration: 0.5), value: animateConnections)
            }
            
            // Objects
            VStack(spacing: 16) {
                ForEach(objects) { object in
                    objectVisual(for: object)
                        .id(object.identifier)
                        .scaleEffect(objectScales[object.identifier] ?? 1.0)
                        .onHover { isHovered in
                            withAnimation(.spring(response: 0.3)) {
                                if isHovered {
                                    hoveredObjectId = object.identifier
                                    objectScales[object.identifier] = 1.05
                                    updateHighlightedConnections(object)
                                } else {
                                    if hoveredObjectId == object.identifier {
                                        hoveredObjectId = nil
                                        highlightedConnections = [:]
                                    }
                                    objectScales[object.identifier] = 1.0
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            // Set initial scales
            for object in objects {
                objectScales[object.identifier] = 1.0
            }
            
            // Animate connections after a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateConnections = true
                }
            }
        }
        .onChange(of: objects) { newObjects in
            // Reset scales for new objects
            for object in newObjects {
                if objectScales[object.identifier] == nil {
                    objectScales[object.identifier] = 1.0
                }
            }
            
            // Reset animations
            animateConnections = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateConnections = true
                }
            }
        }
    }
    
    // References tracking
    @State private var objectLocations: [String: CGRect] = [:]
    
    private var connectionLines: some View {
        ZStack {
            ForEach(objects) { source in
                ForEach(objects) { target in
                    if shouldConnect(from: source, to: target) {
                        let isHighlighted = hoveredObjectId != nil && 
                            (highlightedConnections["\(source.identifier)-\(target.identifier)"] == true)
                        
                        ObjectConnectionLine(
                            from: objectLocations[source.identifier] ?? .zero,
                            to: objectLocations[target.identifier] ?? .zero,
                            color: isHighlighted ? connectionColor(from: source, to: target) : connectionColor(from: source, to: target).opacity(0.5),
                            animate: animateConnections,
                            lineWidth: isHighlighted ? 3 : 2,
                            dashPattern: isHighlighted ? [] : [5, 3]
                        )
                    }
                }
            }
        }
    }
    
    private func updateHighlightedConnections(_ hoveredObject: PythonObjectState) {
        // Reset highlighted connections
        highlightedConnections = [:]
        
        // Highlight connections from this object to others
        for target in objects {
            if shouldConnect(from: hoveredObject, to: target) {
                highlightedConnections["\(hoveredObject.identifier)-\(target.identifier)"] = true
            }
        }
        
        // Highlight connections from others to this object
        for source in objects {
            if shouldConnect(from: source, to: hoveredObject) {
                highlightedConnections["\(source.identifier)-\(hoveredObject.identifier)"] = true
            }
        }
    }
    
    private func shouldConnect(from: PythonObjectState, to: PythonObjectState) -> Bool {
        // In a real implementation, this would check the content to see if there's a reference
        // For this example, we'll use some heuristics:
        
        // Connect nested structures (parent -> child)
        if from.identifier == "list1" && (to.identifier == "list2" || to.identifier == "list3" || to.identifier == "list4") {
            return true
        }
        
        if from.identifier == "list3" && to.identifier == "list4" {
            return true
        }
        
        // Functions don't connect to objects in this example
        if from.type == .function {
            return false
        }
        
        return false
    }
    
    private func connectionColor(from: PythonObjectState, to: PythonObjectState) -> Color {
        // You can customize colors based on relationship type
        switch (from.type, to.type) {
        case (.list, .list):
            return .blue
        case (.function, _):
            return .purple
        case (_, .function):
            return .purple
        default:
            return .gray
        }
    }
    
    @ViewBuilder
    private func objectVisual(for object: PythonObjectState) -> some View {
        switch object.type {
        case .tuple:
            tupleVisual(for: object)
                .background(preferenceViewCapture(for: object.identifier))
                .shadow(color: hoveredObjectId == object.identifier ? Color.primary.opacity(0.3) : Color.clear, radius: 5)
        case .list:
            listVisual(for: object)
                .background(preferenceViewCapture(for: object.identifier))
                .shadow(color: hoveredObjectId == object.identifier ? Color.primary.opacity(0.3) : Color.clear, radius: 5)
        case .dictionary:
            dictionaryVisual(for: object)
                .background(preferenceViewCapture(for: object.identifier))
                .shadow(color: hoveredObjectId == object.identifier ? Color.primary.opacity(0.3) : Color.clear, radius: 5)
        case .function:
            functionVisual(for: object)
                .background(preferenceViewCapture(for: object.identifier))
                .shadow(color: hoveredObjectId == object.identifier ? Color.primary.opacity(0.3) : Color.clear, radius: 5)
        case .string, .number, .none:
            primitiveVisual(for: object)
                .background(preferenceViewCapture(for: object.identifier))
                .shadow(color: hoveredObjectId == object.identifier ? Color.primary.opacity(0.3) : Color.clear, radius: 5)
        }
    }
    
    private func preferenceViewCapture(for id: String) -> some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ObjectLocationPreferenceKey.self, value: [id: geo.frame(in: .named("memorySpace"))])
                .onPreferenceChange(ObjectLocationPreferenceKey.self) { prefs in
                    for (key, bounds) in prefs {
                        objectLocations[key] = bounds
                    }
                }
        }
    }
    
    private func tupleVisual(for object: PythonObjectState) -> some View {
        let elements = parseTupleContent(object.content)
        
        return VStack(spacing: 4) {
            // Type label
            Text("Tuple")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            
            HStack(spacing: 0) {
                ForEach(0..<elements.count, id: \.self) { index in
                    VStack {
                        // Index
                        Text("\(index)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                        
                        // Value
                        Text(elements[index])
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .frame(minWidth: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.yellow.opacity(0.3))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    if index < elements.count - 1 {
                        Divider()
                            .frame(width: 1)
                            .background(Color.black.opacity(0.3))
                            .padding(.vertical, 4)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: hoveredObjectId == object.identifier ? 2 : 1)
                    .animation(.spring(), value: hoveredObjectId)
            )
        }
    }
    
    private func listVisual(for object: PythonObjectState) -> some View {
        let elements = parseListContent(object.content)
        
        return VStack(alignment: .leading, spacing: 2) {
            // Type label
            Text("List - \(elements.count) elements")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            // Visualize as a vertical stack
            VStack(spacing: 0) {
                ForEach(0..<elements.count, id: \.self) { index in
                    HStack {
                        // Index
                        Text("\(index)")
                            .frame(width: 40, alignment: .trailing)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 8)
                        
                        // Value
                        Text(elements[index])
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                    if index < elements.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: hoveredObjectId == object.identifier ? 2 : 1)
                    .animation(.spring(), value: hoveredObjectId)
            )
        }
    }
    
    private func dictionaryVisual(for object: PythonObjectState) -> some View {
        let pairs = parseDictionaryContent(object.content)
        
        return VStack(alignment: .leading, spacing: 2) {
            // Type label
            Text("Dictionary - \(pairs.count) key-value pairs")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            VStack(spacing: 0) {
                ForEach(0..<pairs.count, id: \.self) { index in
                    let pair = pairs[index]
                    
                    HStack {
                        // Key
                        Text(pair.key)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green.opacity(0.2))
                            )
                        
                        // Arrow
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                            .opacity(0.7)
                        
                        // Value
                        Text(pair.value)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    .padding(.vertical, 4)
                    .transition(.scale.combined(with: .opacity))
                    
                    if index < pairs.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green, lineWidth: hoveredObjectId == object.identifier ? 2 : 1)
                    .animation(.spring(), value: hoveredObjectId)
            )
        }
    }
    
    private func functionVisual(for object: PythonObjectState) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Type label
            Text("Function")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            
            Text(object.content)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple, lineWidth: hoveredObjectId == object.identifier ? 2 : 1)
                        .animation(.spring(), value: hoveredObjectId)
                )
                .shadow(radius: 1)
        }
    }
    
    private func primitiveVisual(for object: PythonObjectState) -> some View {
        HStack {
            Text(object.type.rawValue.capitalized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(object.content)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(primitiveColor(for: object.type))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(primitiveBorderColor(for: object.type), lineWidth: hoveredObjectId == object.identifier ? 2 : 1)
                        .animation(.spring(), value: hoveredObjectId)
                )
        }
    }
    
    private func primitiveColor(for type: PythonObjectType) -> Color {
        switch type {
        case .string:
            return Color.red.opacity(0.2)
        case .number:
            return Color.orange.opacity(0.2)
        case .none:
            return Color.gray.opacity(0.2)
        default:
            return Color.secondary.opacity(0.2)
        }
    }
    
    private func primitiveBorderColor(for type: PythonObjectType) -> Color {
        switch type {
        case .string:
            return Color.red
        case .number:
            return Color.orange
        case .none:
            return Color.gray
        default:
            return Color.secondary
        }
    }
    
    // Helper functions to parse content strings
    private func parseTupleContent(_ content: String) -> [String] {
        // Simple parsing for demonstration
        // In a real implementation, this would handle nested structures
        
        // Remove outer parentheses and split by comma
        let trimmed = content.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        return trimmed.components(separatedBy: ", ")
    }
    
    private func parseListContent(_ content: String) -> [String] {
        // Remove outer brackets and split by comma
        let trimmed = content.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        return trimmed.components(separatedBy: ", ")
    }
    
    private func parseDictionaryContent(_ content: String) -> [(key: String, value: String)] {
        // Simple parsing for demonstration
        // In a real implementation, this would handle nested structures
        
        // Remove outer brackets
        let trimmed = content.trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
        let pairs = trimmed.components(separatedBy: ", ")
        
        return pairs.compactMap { pair in
            let keyValue = pair.components(separatedBy: ": ")
            guard keyValue.count == 2 else { return nil }
            return (key: keyValue[0], value: keyValue[1])
        }
    }
}

// Extension to make PythonObjectType have String rawValues
extension PythonObjectType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "function": self = .function
        case "list": self = .list
        case "tuple": self = .tuple
        case "dictionary": self = .dictionary
        case "string": self = .string
        case "number": self = .number
        case "none": self = .none
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .function: return "function"
        case .list: return "list"
        case .tuple: return "tuple"
        case .dictionary: return "dictionary"
        case .string: return "string"
        case .number: return "number"
        case .none: return "none"
        }
    }
}

// Object location preference key
struct ObjectLocationPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]
    
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

// Connection line between objects
struct ObjectConnectionLine: View {
    var from: CGRect
    var to: CGRect
    var color: Color
    var animate: Bool = false
    var lineWidth: CGFloat = 2
    var dashPattern: [CGFloat] = []
    
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        Path { path in
            guard from != .zero && to != .zero else { return }
            
            let fromPoint = CGPoint(
                x: from.midX,
                y: from.maxY
            )
            
            let toPoint = CGPoint(
                x: to.midX,
                y: to.minY
            )
            
            path.move(to: fromPoint)
            
            // Create a curved path
            let midY = fromPoint.y + (toPoint.y - fromPoint.y) / 2
            
            let control1 = CGPoint(
                x: fromPoint.x,
                y: midY
            )
            
            let control2 = CGPoint(
                x: toPoint.x,
                y: midY
            )
            
            path.addCurve(to: toPoint, control1: control1, control2: control2)
        }
        .trim(from: 0, to: animate ? animationProgress : 1)
        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, dash: dashPattern))
        .shadow(color: color.opacity(0.3), radius: 2)
        .animation(.spring(), value: color)
        .animation(.spring(), value: lineWidth)
        .onAppear {
            if animate {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
        .onChange(of: animate) { newValue in
            if newValue {
                animationProgress = 0
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
    }
}

// Sample Preview
struct PythonMemoryVisualization_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            PythonMemoryVisualization(
                objects: [
                    PythonObjectState(
                        identifier: "tuple1",
                        content: "(1, 2, 3, None)",
                        type: .tuple
                    ),
                    PythonObjectState(
                        identifier: "list1",
                        content: "[1, 2, 3, 4, 5]",
                        type: .list
                    ),
                    PythonObjectState(
                        identifier: "dict1",
                        content: "{'name': 'John', 'age': 30, 'city': 'New York'}",
                        type: .dictionary
                    ),
                    PythonObjectState(
                        identifier: "func1",
                        content: "function listSum(numbers)",
                        type: .function
                    )
                ],
                showReferences: true
            )
            .padding()
            .frame(height: 600)
            .coordinateSpace(name: "memorySpace")
        }
    }
} 