import Foundation

// MARK: - Tutorial Category
enum TutorialCategory: String, CaseIterable {
    case basics = "Basics"
    case functions = "Functions"
    case objects = "Objects & Arrays"
    case dom = "DOM"
    case async = "Async JS"
    case python = "ES6 & Modern JS"
}

// MARK: - Tutorial Model
struct Tutorial: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: TutorialCategory
    let content: String
    let difficulty: Int // 1-5
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Tutorial, rhs: Tutorial) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data
extension Tutorial {
    // Sample tutorials
    static let sampleTutorials: [Tutorial] = [
        // Basics
        Tutorial(
            title: "JavaScript Variables",
            description: "Learn about declaring variables in JavaScript using var, let, and const",
            category: .basics,
            content: """
            # JavaScript Variables
            
            JavaScript provides three ways to declare variables:
            
            ```javascript
            // Using var (function scoped)
            var name = "John";
            
            // Using let (block scoped, can be reassigned)
            let age = 30;
            
            // Using const (block scoped, cannot be reassigned)
            const PI = 3.14159;
            ```
            
            ## Scope and Hoisting
            
            Variables declared with `var` are function-scoped and are hoisted to the top of their scope.
            Variables declared with `let` and `const` are block-scoped and are not hoisted.
            """,
            difficulty: 1
        ),
        
        // Functions
        Tutorial(
            title: "JavaScript Functions",
            description: "Learn about function declarations, expressions, and arrow functions",
            category: .functions,
            content: """
            # JavaScript Functions
            
            ## Function Declaration
            
            ```javascript
            function greet(name) {
                return "Hello, " + name + "!";
            }
            ```
            
            ## Function Expression
            
            ```javascript
            const greet = function(name) {
                return "Hello, " + name + "!";
            };
            ```
            
            ## Arrow Function
            
            ```javascript
            const greet = (name) => {
                return "Hello, " + name + "!";
            };
            
            // Short syntax for single expressions
            const greet = name => "Hello, " + name + "!";
            ```
            """,
            difficulty: 2
        ),
        
        // Objects & Arrays
        Tutorial(
            title: "Objects and Arrays",
            description: "Working with JavaScript objects and arrays",
            category: .objects,
            content: """
            # JavaScript Objects and Arrays
            
            ## Objects
            
            ```javascript
            // Object literal
            const person = {
                name: "John",
                age: 30,
                isEmployed: true,
                greet: function() {
                    return "Hello, I'm " + this.name;
                }
            };
            
            // Accessing properties
            console.log(person.name);        // "John"
            console.log(person["age"]);      // 30
            console.log(person.greet());     // "Hello, I'm John"
            ```
            
            ## Arrays
            
            ```javascript
            // Array literal
            const numbers = [1, 2, 3, 4, 5];
            
            // Array methods
            numbers.push(6);                     // [1, 2, 3, 4, 5, 6]
            numbers.pop();                       // [1, 2, 3, 4, 5]
            numbers.map(n => n * 2);             // [2, 4, 6, 8, 10]
            numbers.filter(n => n % 2 === 0);    // [2, 4]
            numbers.reduce((sum, n) => sum + n, 0); // 15
            ```
            """,
            difficulty: 2
        ),
        
        // DOM
        Tutorial(
            title: "DOM Manipulation",
            description: "Learn how to manipulate the Document Object Model (DOM)",
            category: .dom,
            content: """
            # DOM Manipulation
            
            ## Selecting Elements
            
            ```javascript
            // By ID
            const element = document.getElementById("myElement");
            
            // By class name
            const elements = document.getElementsByClassName("myClass");
            
            // By tag name
            const paragraphs = document.getElementsByTagName("p");
            
            // Using CSS selectors
            const element = document.querySelector(".myClass");
            const elements = document.querySelectorAll("p.intro");
            ```
            
            ## Modifying Elements
            
            ```javascript
            // Changing content
            element.textContent = "New text content";
            element.innerHTML = "<span>HTML content</span>";
            
            // Changing attributes
            element.setAttribute("class", "newClass");
            element.id = "newId";
            
            // Changing styles
            element.style.color = "red";
            element.style.backgroundColor = "black";
            
            // Adding/removing classes
            element.classList.add("active");
            element.classList.remove("inactive");
            element.classList.toggle("highlighted");
            ```
            """,
            difficulty: 3
        ),
        
        // Async JS
        Tutorial(
            title: "Asynchronous JavaScript",
            description: "Learn about callbacks, promises, and async/await",
            category: .async,
            content: """
            # Asynchronous JavaScript
            
            ## Callbacks
            
            ```javascript
            function fetchData(callback) {
                setTimeout(() => {
                    const data = { name: "John", age: 30 };
                    callback(data);
                }, 1000);
            }
            
            fetchData(data => {
                console.log(data); // { name: "John", age: 30 }
            });
            ```
            
            ## Promises
            
            ```javascript
            function fetchData() {
                return new Promise((resolve, reject) => {
                    setTimeout(() => {
                        const data = { name: "John", age: 30 };
                        resolve(data);
                        // or reject(new Error("Failed to fetch data"));
                    }, 1000);
                });
            }
            
            fetchData()
                .then(data => {
                    console.log(data);
                    return processData(data);
                })
                .then(processedData => {
                    console.log(processedData);
                })
                .catch(error => {
                    console.error(error);
                });
            ```
            
            ## Async/Await
            
            ```javascript
            async function getData() {
                try {
                    const data = await fetchData();
                    const processedData = await processData(data);
                    return processedData;
                } catch (error) {
                    console.error(error);
                }
            }
            
            // Using the async function
            getData().then(result => {
                console.log(result);
            });
            ```
            """,
            difficulty: 4
        ),
        
        // ES6 & Modern JS
        Tutorial(
            title: "Modern JavaScript (ES6+)",
            description: "Explore the modern features of JavaScript since ES6",
            category: .python,
            content: """
            # Modern JavaScript (ES6+)
            
            ## Template Literals
            
            ```javascript
            const name = "John";
            const greeting = `Hello, ${name}!`;
            
            const multiline = `
                This is a
                multiline string
                in JavaScript
            `;
            ```
            
            ## Destructuring
            
            ```javascript
            // Array destructuring
            const [a, b, ...rest] = [1, 2, 3, 4, 5];
            console.log(a);     // 1
            console.log(b);     // 2
            console.log(rest);  // [3, 4, 5]
            
            // Object destructuring
            const { name, age, country = "USA" } = { name: "John", age: 30 };
            console.log(name);     // "John"
            console.log(age);      // 30
            console.log(country);  // "USA" (default value)
            ```
            
            ## Spread Operator
            
            ```javascript
            // Arrays
            const arr1 = [1, 2, 3];
            const arr2 = [...arr1, 4, 5];  // [1, 2, 3, 4, 5]
            
            // Objects
            const obj1 = { a: 1, b: 2 };
            const obj2 = { ...obj1, c: 3 }; // { a: 1, b: 2, c: 3 }
            ```
            
            ## Modules
            
            ```javascript
            // Exporting
            export const PI = 3.14159;
            export function square(x) {
                return x * x;
            }
            
            // Importing
            import { PI, square } from './math.js';
            import * as math from './math.js';
            import defaultExport from './module.js';
            ```
            """,
            difficulty: 3
        )
    ]
} 