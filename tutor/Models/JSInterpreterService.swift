import Foundation
import JavaScriptCore

class JSInterpreterService {
    private var jsContext: JSContext?
    
    // Function to instrument code for step-by-step execution
    func instrumentCode(_ code: String) -> String {
        // This is a simplified version of what Python Tutor does
        // In a production app, you'd need a more sophisticated JavaScript parser and instrumenter
        
        // Add logging before each line
        var lines = code.components(separatedBy: .newlines)
        var instrumentedCode = ""
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("//") || trimmedLine.hasPrefix("/*") {
                instrumentedCode += line + "\n"
                continue
            }
            
            // Inject logging before the line
            let logLine = "_visualizer_log(\(index + 1));\n"
            instrumentedCode += logLine + line + "\n"
        }
        
        // Add visualizer logging framework at the beginning
        let loggingFramework = """
        var _visualizer_states = [];
        var _visualizer_current_line = 0;
        var _visualizer_heap = {};
        var _visualizer_frames = [{ name: "Global Execution Context", variables: {}, isGlobal: true }];
        
        function _visualizer_log(lineNumber) {
            _visualizer_current_line = lineNumber;
            
            // Capture current state
            var state = {
                line: lineNumber,
                heap: JSON.parse(JSON.stringify(_visualizer_heap)),
                frames: JSON.parse(JSON.stringify(_visualizer_frames)),
                output: _visualizer_console_output.slice()
            };
            
            _visualizer_states.push(state);
        }
        
        // Override console.log to capture output
        var _visualizer_console_output = [];
        var _original_console_log = console.log;
        console.log = function() {
            var args = Array.prototype.slice.call(arguments);
            var message = args.map(function(arg) {
                return (arg === null) ? 'null' : 
                      (arg === undefined) ? 'undefined' : 
                      (typeof arg === 'object') ? JSON.stringify(arg) : String(arg);
            }).join(' ');
            
            _visualizer_console_output.push(message);
            _original_console_log.apply(console, arguments);
        };
        
        // Helper to register variables
        function _visualizer_register_var(name, value, frameIndex) {
            if (frameIndex === undefined) {
                frameIndex = 0;
            }
            
            var valueType = typeof value;
            var displayValue = String(value);
            var isReference = false;
            var refId = null;
            
            if (value !== null && valueType === 'object') {
                // Generate a unique ID for heap objects
                refId = '_obj_' + Math.random().toString(36).substr(2, 9);
                _visualizer_heap[refId] = value;
                isReference = true;
            }
            
            _visualizer_frames[frameIndex].variables[name] = {
                value: displayValue,
                type: valueType,
                isReference: isReference,
                refId: refId
            };
        }
        
        // Helper to create new frame for function calls
        function _visualizer_push_frame(name) {
            _visualizer_frames.push({
                name: name,
                variables: {},
                isGlobal: false
            });
            
            return _visualizer_frames.length - 1;
        }
        
        // Helper to remove frame after function returns
        function _visualizer_pop_frame() {
            if (_visualizer_frames.length > 1) {
                _visualizer_frames.pop();
            }
        }
        
        """
        
        return loggingFramework + instrumentedCode + "\n_visualizer_states;"
    }
    
    func executeCode(_ code: String) -> [JSExecutionState] {
        jsContext = JSContext()
        setupErrorHandling()
        
        let instrumentedCode = instrumentCode(code)
        let result = jsContext?.evaluateScript(instrumentedCode)
        
        // Parse execution states from result
        guard let statesArray = result?.toArray() else {
            return []
        }
        
        return parseExecutionStates(statesArray)
    }
    
    private func setupErrorHandling() {
        jsContext?.exceptionHandler = { context, exception in
            print("JS Error: \(exception?.toString() ?? "Unknown error")")
        }
    }
    
    private func parseExecutionStates(_ statesArray: [Any]) -> [JSExecutionState] {
        var executionStates: [JSExecutionState] = []
        
        for (index, stateObj) in statesArray.enumerated() {
            guard let stateDict = stateObj as? [String: Any] else { continue }
            
            let lineNumber = stateDict["line"] as? Int ?? 0
            let consoleOutput = stateDict["output"] as? [String] ?? []
            
            let framesArray = stateDict["frames"] as? [[String: Any]] ?? []
            let executionFrames = parseFrames(framesArray)
            
            let heapDict = stateDict["heap"] as? [String: Any] ?? [:]
            let heapObjects = parseHeapObjects(heapDict)
            
            // Get the active frame ID
            let activeFrameId = executionFrames.first(where: { $0.isActive })?.id ?? executionFrames.first?.id ?? UUID()
            
            let state = JSExecutionState(
                step: index + 1,
                frames: executionFrames,
                heapObjects: heapObjects,
                activeFrameId: activeFrameId,
                currentLine: lineNumber - 1, // Adjust for 0-based indexing in UI
                consoleOutput: consoleOutput,
                explanation: "Executing line \(lineNumber)",
                hasError: false,
                errorMessage: nil
            )
            
            executionStates.append(state)
        }
        
        return executionStates
    }
    
    private func parseFrames(_ framesArray: [[String: Any]]) -> [JSExecutionFrame] {
        var frames: [JSExecutionFrame] = []
        
        for (index, frameDict) in framesArray.enumerated() {
            let name = frameDict["name"] as? String ?? "Frame \(index)"
            let isGlobal = frameDict["isGlobal"] as? Bool ?? false
            let variablesDict = frameDict["variables"] as? [String: [String: Any]] ?? [:]
            
            var variables: [JSVariableValue] = []
            
            for (varName, varProperties) in variablesDict {
                let value = varProperties["value"] as? String ?? "undefined"
                let typeStr = varProperties["type"] as? String ?? "undefined"
                let isReference = varProperties["isReference"] as? Bool ?? false
                let refId = varProperties["refId"] as? String
                
                let type = jsTypeToDataType(typeStr)
                
                let variable = JSVariableValue(
                    name: varName,
                    value: value,
                    stringValue: value,
                    type: type,
                    isNew: false, // We can't easily track this in this simplified version
                    isModified: false,
                    reference: isReference ? refId : nil,
                    references: isReference && refId != nil ? [refId!] : nil
                )
                
                variables.append(variable)
            }
            
            let frame = JSExecutionFrame(
                name: name,
                isGlobal: isGlobal,
                variables: variables,
                lineNumber: 0, // We don't track this in the simplified version
                isActive: index == 0 // Consider the topmost frame as active
            )
            
            frames.append(frame)
        }
        
        return frames
    }
    
    private func parseHeapObjects(_ heapDict: [String: Any]) -> [JSHeapObject] {
        var heapObjects: [JSHeapObject] = []
        
        for (objId, objValue) in heapDict {
            var properties: [(name: String, value: JSVariableValue)] = []
            var objectType: JSDataType = .object
            
            if let objDict = objValue as? [String: Any] {
                // It's an object with properties
                for (propName, propValue) in objDict {
                    let valueStr = String(describing: propValue)
                    let dataType = jsValueToDataType(propValue)
                    
                    let variable = JSVariableValue(
                        name: propName,
                        value: valueStr,
                        stringValue: valueStr,
                        type: dataType,
                        isNew: false,
                        isModified: false,
                        reference: nil,
                        references: nil
                    )
                    
                    properties.append((name: propName, value: variable))
                }
            } else if let objArray = objValue as? [Any] {
                // It's an array
                objectType = .array
                for (index, element) in objArray.enumerated() {
                    let valueStr = String(describing: element)
                    let dataType = jsValueToDataType(element)
                    
                    let variable = JSVariableValue(
                        name: String(index),
                        value: valueStr,
                        stringValue: valueStr,
                        type: dataType,
                        isNew: false,
                        isModified: false,
                        reference: nil,
                        references: nil
                    )
                    
                    properties.append((name: String(index), value: variable))
                }
            }
            
            let heapObject = JSHeapObject(
                id: objId,
                type: objectType,
                properties: properties,
                isNew: false
            )
            
            heapObjects.append(heapObject)
        }
        
        return heapObjects
    }
    
    private func jsTypeToDataType(_ typeString: String) -> JSDataType {
        switch typeString {
        case "number": return .number
        case "string": return .string
        case "boolean": return .boolean
        case "object":
            // Could be object, array, or null - would need more context
            return .object
        case "function": return .function
        case "undefined": return .undefined
        default: return .undefined
        }
    }
    
    private func jsValueToDataType(_ value: Any) -> JSDataType {
        if value is Int || value is Double || value is Float {
            return .number
        } else if value is String {
            return .string
        } else if value is Bool {
            return .boolean
        } else if value is [Any] {
            return .array
        } else if value is [String: Any] {
            return .object
        } else if value is NSNull {
            return .null
        } else {
            return .undefined
        }
    }
} 
