import SwiftUI

struct JSMemoryVisualizerView: View {
    let executionState: JSExecutionState?
    @State private var variablePositions: [String: CGPoint] = [:]
    @State private var heapObjectPositions: [String: CGPoint] = [:]
    @State private var animationActive = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            if let state = executionState {
                ScrollView {
                    contentStack(state: state)
                }
            } else {
                emptyStateView
            }
        }
    }
    
    private var headerView: some View {
        Text("Execution Frames")
            .font(.headline)
            .padding(.horizontal)
    }
    
    private func contentStack(state: JSExecutionState) -> some View {
        ZStack {
            framesSection(state: state)
            heapSection(state: state)
            referenceArrows(state: state)
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.5)) {
                    animationActive = true
                }
            }
        }
        .onDisappear {
            animationActive = false
        }
    }
    
    private func framesSection(state: JSExecutionState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(state.frames) { frame in
                executionFrame(frame: frame, isActive: frame.id == state.activeFrameId)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            DispatchQueue.main.async {
                                for variable in frame.variables {
                                    variablePositions[variable.id.uuidString] = CGPoint(
                                        x: geo.frame(in: .global).maxX - 20,
                                        y: geo.frame(in: .global).minY + CGFloat(frame.variables.firstIndex(where: { $0.id == variable.id }) ?? 0) * 30 + 40
                                    )
                                }
                            }
                        }
                    })
            }
        }
        .padding(.bottom, calculateFramesHeight(frames: state.frames))
    }
    
    private func heapSection(state: JSExecutionState) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !state.heapObjects.isEmpty {
                Text("Objects")
                    .font(.headline)
                    .padding(.top, calculateFramesHeight(frames: state.frames) + 24)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(state.heapObjects) { object in
                        heapObjectView(object: object)
                            .background(GeometryReader { geo in
                                Color.clear.onAppear {
                                    DispatchQueue.main.async {
                                        heapObjectPositions[object.id] = CGPoint(
                                            x: geo.frame(in: .global).minX + 20,
                                            y: geo.frame(in: .global).midY
                                        )
                                    }
                                }
                            })
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No objects in memory")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, calculateFramesHeight(frames: state.frames) + 24)
                    .padding(.horizontal)
            }
        }
    }
    
    private func referenceArrows(state: JSExecutionState) -> some View {
        ForEach(getReferences(state: state)) { reference in
            if let sourcePoint = variablePositions[reference.sourceId],
               let targetPoint = heapObjectPositions[reference.targetId] {
                let controlPoint = CGPoint(
                    x: (sourcePoint.x + targetPoint.x) / 2,
                    y: min(sourcePoint.y, targetPoint.y) - 30
                )
                ReferenceArrow(start: sourcePoint, end: targetPoint, controlPoint: controlPoint)
                    .stroke(Color.blue, lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.5), value: sourcePoint)
                    .animation(.easeInOut(duration: 0.5), value: targetPoint)
                    .opacity(animationActive ? 1 : 0)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Run your code to see execution frames")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
    
    private func executionFrame(frame: JSExecutionFrame, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(frame.name)
                    .font(.headline)
                    .padding(.vertical, 6)
                
                Spacer()
                
                if isActive {
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            if frame.variables.isEmpty {
                Text("No variables in scope")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 6)
            } else {
                ForEach(frame.variables) { variable in
                    HStack(alignment: .top) {
                        Text(variable.name)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let reference = variable.reference {
                            referenceView(reference)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                                .id("var-\(variable.id)")
                        } else {
                            variableValueView(value: variable)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                                .id("var-\(variable.id)-\(variable.hashValue)")
                        }
                    }
                    .padding(.vertical, 2)
                    .padding(.trailing, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.green : Color.gray.opacity(0.3), lineWidth: isActive ? 2 : 1)
        )
        .padding(.horizontal)
        .animation(.spring(response: 0.3), value: isActive)
    }
    
    private func heapObjectView(object: JSHeapObject) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(object.type.name)
                    .font(.headline)
                    .padding(.vertical, 2)
                
                Spacer()
                
                Text(object.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 4) {
                ForEach(object.properties.indices, id: \.self) { index in
                    let property = object.properties[index]
                    HStack {
                        Text(property.name)
                            .font(.system(.body, design: .monospaced))
                        
                        Spacer()
                        
                        if let reference = property.value.reference {
                            referenceView(reference)
                        } else {
                            variableValueView(value: property.value)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func referenceView(_ reference: String) -> some View {
        HStack {
            Text("ref")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
            
            Text(reference)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.blue)
        }
    }
    
    private func variableValueView(value: JSVariableValue) -> some View {
        Group {
            switch value.type {
            case .number:
                Text(value.stringValue)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.orange)
            case .string:
                Text("\"\(value.stringValue)\"")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
            case .boolean:
                Text(value.stringValue)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.purple)
            case .undefined:
                Text("undefined")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
                    .italic()
            case .null:
                Text("null")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.red)
                    .italic()
            case .function:
                Text("ƒ()")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
            default:
                Text(value.stringValue)
                    .font(.system(.body, design: .monospaced))
            }
        }
    }
    
    private func calculateFramesHeight(frames: [JSExecutionFrame]) -> CGFloat {
        var height: CGFloat = 0
        for frame in frames {
            // Base height for frame container
            let baseHeight: CGFloat = 80
            // Height per variable
            let variableHeight: CGFloat = max(CGFloat(frame.variables.count) * 30, 30)
            height += baseHeight + variableHeight
        }
        return height
    }
    
    private func getReferences(state: JSExecutionState) -> [ReferenceInfo] {
        var references: [ReferenceInfo] = []
        
        for frame in state.frames {
            for variable in frame.variables {
                if let ref = variable.reference {
                    references.append(ReferenceInfo(
                        id: "\(frame.id)-\(variable.id)-\(ref)",
                        sourceId: variable.id.uuidString,
                        targetId: ref,
                        sourceType: .variable
                    ))
                }
            }
        }
        
        return references
    }
}

// MARK: - Reference Arrow

struct ReferenceArrow: Shape {
    let start: CGPoint
    let end: CGPoint
    let controlPoint: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start the path
        path.move(to: start)
        
        // Curved line to end
        path.addQuadCurve(to: end, control: controlPoint)
        
        // Calculate arrow head
        let arrowLength: CGFloat = 10.0
        let arrowAngle: CGFloat = .pi / 8
        
        // Vector from end to the point before it
        let dx = end.x - controlPoint.x
        let dy = end.y - controlPoint.y
        
        // Normalize the vector
        let length = sqrt(dx * dx + dy * dy)
        let normalizedDx = dx / length
        let normalizedDy = dy / length
        
        // Calculate arrow head points
        let arrowPoint1 = CGPoint(
            x: end.x - arrowLength * (normalizedDx * cos(arrowAngle) - normalizedDy * sin(arrowAngle)),
            y: end.y - arrowLength * (normalizedDx * sin(arrowAngle) + normalizedDy * cos(arrowAngle))
        )
        
        let arrowPoint2 = CGPoint(
            x: end.x - arrowLength * (normalizedDx * cos(-arrowAngle) - normalizedDy * sin(-arrowAngle)),
            y: end.y - arrowLength * (normalizedDx * sin(-arrowAngle) + normalizedDy * cos(-arrowAngle))
        )
        
        // Draw arrow head
        path.move(to: end)
        path.addLine(to: arrowPoint1)
        path.move(to: end)
        path.addLine(to: arrowPoint2)
        
        return path
    }
}

// MARK: - Position Tracking

struct ViewPosition: Equatable {
    let id: String
    let position: CGPoint
}

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [ViewPosition] = []
    
    static func reduce(value: inout [ViewPosition], nextValue: () -> [ViewPosition]) {
        value.append(contentsOf: nextValue())
    }
}

struct ReferenceInfo: Identifiable {
    let id: String
    let sourceId: String
    let targetId: String
    let sourceType: ReferenceSourceType
}

enum ReferenceSourceType {
    case variable
    case arrayIndex
}

// Extension to get center point of CGRect
extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
} 