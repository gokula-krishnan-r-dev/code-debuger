import Foundation

struct JSCodeExample: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let code: String
    let explanation: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: JSCodeExample, rhs: JSCodeExample) -> Bool {
        return lhs.id == rhs.id
    }
}

struct JavaScriptTutorial: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: JSCategory
    let examples: [JSCodeExample]
    let level: Level
    
    // Add hash and == functions
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: JavaScriptTutorial, rhs: JavaScriptTutorial) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum Level: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

enum JSCategory: String, CaseIterable {
    case basics = "Basics"
    case functions = "Functions"
    case objects = "Objects & Arrays"
    case arrays = "Arrays"
    case async = "Async"
    case es6 = "ES6 Features"
}

// Sample JavaScript tutorials
extension JavaScriptTutorial {
    static let sampleTutorials: [JavaScriptTutorial] = [
        // Basics
        JavaScriptTutorial(
            title: "Variables & Data Types",
            description: "Learn how to declare variables and work with different data types in JavaScript",
            category: .basics,
            examples: [
                JSCodeExample(
                    title: "Variable Declaration",
                    code: """
                    // Variables can be declared using let, const, or var
                    let name = "JavaScript";
                    const version = 2023;
                    var isAwesome = true;
                    
                    console.log(name);      // "JavaScript"
                    console.log(version);   // 2023
                    console.log(isAwesome); // true
                    """,
                    explanation: "In modern JavaScript, we use 'let' for variables that can change, 'const' for variables that should remain constant, and 'var' is the older way of declaring variables."
                ),
                JSCodeExample(
                    title: "Data Types",
                    code: """
                    // JavaScript has several primitive types
                    const text = "Hello";         // String
                    const number = 42;            // Number
                    const decimal = 3.14;         // Number (floating-point)
                    const isTrue = true;          // Boolean
                    const nothing = null;         // Null
                    const notDefined = undefined; // Undefined
                    const bigInt = 9007199254740991n; // BigInt
                    const uniqueSymbol = Symbol("id"); // Symbol
                    
                    // And one complex type with many faces
                    const array = [1, 2, 3];                // Array
                    const object = { key: "value" };        // Object
                    const today = new Date();               // Date object
                    const greeting = function() { return "Hello"; }; // Function
                    """,
                    explanation: "JavaScript is dynamically typed and supports various data types. Primitive types include String, Number, Boolean, Null, Undefined, BigInt, and Symbol. Object is the non-primitive type which includes Arrays, Functions, Dates and regular Objects."
                )
            ],
            level: .beginner
        ),
        
        // Functions
        JavaScriptTutorial(
            title: "Functions",
            description: "Master JavaScript functions including declarations, expressions, and arrow functions",
            category: .functions,
            examples: [
                JSCodeExample(
                    title: "Function Declaration",
                    code: """
                    // Function declaration
                    function add(a, b) {
                        return a + b;
                    }
                    
                    // Function call
                    const sum = add(5, 3);
                    console.log(sum); // 8
                    """,
                    explanation: "Function declarations are hoisted, meaning they can be called before they're defined in the code."
                ),
                JSCodeExample(
                    title: "Function Expression",
                    code: """
                    // Function expression
                    const multiply = function(a, b) {
                        return a * b;
                    };
                    
                    // Function call
                    const product = multiply(4, 2);
                    console.log(product); // 8
                    """,
                    explanation: "Function expressions are not hoisted, so they can only be called after they're defined."
                ),
                JSCodeExample(
                    title: "Arrow Functions",
                    code: """
                    // Arrow function (ES6)
                    const divide = (a, b) => a / b;
                    
                    // Function call
                    const quotient = divide(10, 2);
                    console.log(quotient); // 5
                    
                    // Multiline arrow function
                    const calculateArea = (width, height) => {
                        const area = width * height;
                        return area;
                    };
                    """,
                    explanation: "Arrow functions were introduced in ES6 and provide a concise syntax. They don't have their own 'this' context, which makes them ideal for callbacks."
                )
            ],
            level: .beginner
        ),
        
        // Objects & Arrays
        JavaScriptTutorial(
            title: "Objects & Arrays",
            description: "Work with objects and arrays to organize and manipulate data effectively",
            category: .objects,
            examples: [
                JSCodeExample(
                    title: "Creating and Using Objects",
                    code: """
                    // Object literal syntax
                    const person = {
                        firstName: "John",
                        lastName: "Doe",
                        age: 30,
                        greet: function() {
                            return `Hello, my name is ${this.firstName} ${this.lastName}`;
                        }
                    };
                    
                    // Accessing properties
                    console.log(person.firstName); // "John"
                    console.log(person["lastName"]); // "Doe"
                    
                    // Using object methods
                    console.log(person.greet()); // "Hello, my name is John Doe"
                    
                    // Adding new properties
                    person.email = "john@example.com";
                    """,
                    explanation: "Objects store multiple values as key-value pairs. Properties can be accessed using dot notation or square bracket notation, and can be added or modified dynamically."
                ),
                JSCodeExample(
                    title: "Working with Arrays",
                    code: """
                    // Creating an array
                    const fruits = ["Apple", "Banana", "Orange"];
                    
                    // Accessing elements
                    console.log(fruits[0]); // "Apple"
                    
                    // Adding elements
                    fruits.push("Mango"); // Add to end
                    fruits.unshift("Strawberry"); // Add to beginning
                    
                    // Removing elements
                    const lastFruit = fruits.pop(); // Remove from end
                    const firstFruit = fruits.shift(); // Remove from beginning
                    
                    // Array methods
                    const numbers = [1, 2, 3, 4, 5];
                    
                    // map - creates a new array with the results of calling a function on every element
                    const doubled = numbers.map(num => num * 2);
                    console.log(doubled); // [2, 4, 6, 8, 10]
                    
                    // filter - creates a new array with elements that pass a test
                    const evenNumbers = numbers.filter(num => num % 2 === 0);
                    console.log(evenNumbers); // [2, 4]
                    
                    // reduce - executes a reducer function on each element, resulting in a single value
                    const sum = numbers.reduce((total, current) => total + current, 0);
                    console.log(sum); // 15
                    """,
                    explanation: "Arrays are ordered collections of values. JavaScript provides a wealth of methods for working with arrays, including ways to add, remove, transform, and analyze array data."
                )
            ],
            level: .intermediate
        ),
        
        // Async Programming
        JavaScriptTutorial(
            title: "Asynchronous JavaScript",
            description: "Master promises, async/await and other patterns for handling asynchronous operations",
            category: .async,
            examples: [
                JSCodeExample(
                    title: "Promises",
                    code: """
                    // Creating a promise
                    const fetchData = new Promise((resolve, reject) => {
                        // Simulating an API call
                        setTimeout(() => {
                            const success = true;
                            if (success) {
                                resolve("Data fetched successfully");
                            } else {
                                reject("Error fetching data");
                            }
                        }, 2000);
                    });
                    
                    // Using promises
                    fetchData
                        .then(data => {
                            console.log(data); // "Data fetched successfully"
                            return "Processed: " + data;
                        })
                        .then(processedData => {
                            console.log(processedData); // "Processed: Data fetched successfully"
                        })
                        .catch(error => {
                            console.error(error);
                        })
                        .finally(() => {
                            console.log("Operation completed");
                        });
                    """,
                    explanation: "Promises represent the eventual completion (or failure) of an asynchronous operation and its resulting value. They allow you to chain operations and handle errors more gracefully than callbacks."
                ),
                JSCodeExample(
                    title: "Async/Await",
                    code: """
                    // Function returning a promise
                    function fetchUser(id) {
                        return new Promise((resolve, reject) => {
                            setTimeout(() => {
                                // Simulate database lookup
                                if (id > 0) {
                                    resolve({ id, name: `User ${id}` });
                                } else {
                                    reject("Invalid user ID");
                                }
                            }, 1000);
                        });
                    }
                    
                    // Using async/await
                    async function getUserData() {
                        try {
                            // Await pauses execution until the promise resolves
                            const user = await fetchUser(1);
                            console.log("User:", user);
                            
                            // You can await multiple promises
                            const [profile, posts] = await Promise.all([
                                fetchUserProfile(user.id),
                                fetchUserPosts(user.id)
                            ]);
                            
                            return { user, profile, posts };
                        } catch (error) {
                            console.error("Error:", error);
                        }
                    }
                    
                    // Call the async function
                    getUserData().then(data => {
                        console.log("All data:", data);
                    });
                    
                    function fetchUserProfile(id) {
                        return Promise.resolve({ bio: "JavaScript enthusiast" });
                    }
                    
                    function fetchUserPosts(id) {
                        return Promise.resolve([
                            { title: "JavaScript is awesome" },
                            { title: "Promises explained" }
                        ]);
                    }
                    """,
                    explanation: "Async/await is syntactic sugar on top of Promises, making asynchronous code look and behave more like synchronous code. The 'async' keyword marks a function that returns a Promise, and 'await' pauses execution until a Promise is resolved or rejected."
                )
            ],
            level: .advanced
        ),
        
        // ES6 Features
        JavaScriptTutorial(
            title: "Modern JavaScript (ES6+)",
            description: "Explore the powerful features of modern JavaScript that make your code cleaner and more expressive",
            category: .es6,
            examples: [
                JSCodeExample(
                    title: "Destructuring",
                    code: """
                    // Array destructuring
                    const numbers = [1, 2, 3, 4, 5];
                    const [first, second, ...rest] = numbers;
                    
                    console.log(first);  // 1
                    console.log(second); // 2
                    console.log(rest);   // [3, 4, 5]
                    
                    // Object destructuring
                    const person = {
                        name: "Alice",
                        age: 28,
                        location: "New York",
                        job: "Developer"
                    };
                    
                    const { name, age, ...details } = person;
                    
                    console.log(name);    // "Alice"
                    console.log(age);     // 28
                    console.log(details); // { location: "New York", job: "Developer" }
                    
                    // Function parameter destructuring
                    function printUserInfo({ name, age, location = "Unknown" }) {
                        console.log(`${name}, ${age} years old, from ${location}`);
                    }
                    
                    printUserInfo(person); // "Alice, 28 years old, from New York"
                    """,
                    explanation: "Destructuring allows you to extract values from arrays and properties from objects in a concise way, saving you from writing repetitive access code."
                ),
                JSCodeExample(
                    title: "Template Literals",
                    code: """
                    // Basic template literals
                    const name = "World";
                    const greeting = `Hello, ${name}!`;
                    console.log(greeting); // "Hello, World!"
                    
                    // Multiline strings
                    const multiline = `
                        This is a multiline string.
                        It can span multiple lines
                        without special characters.
                    `;
                    
                    // Expression evaluation
                    const a = 5;
                    const b = 10;
                    console.log(`Sum: ${a + b}, Product: ${a * b}`); // "Sum: 15, Product: 50"
                    
                    // Tagged templates
                    function highlight(strings, ...values) {
                        return strings.reduce((result, str, i) => {
                            const value = i < values.length ? `<strong>${values[i]}</strong>` : '';
                            return result + str + value;
                        }, '');
                    }
                    
                    const name2 = "JavaScript";
                    const version = "ES6";
                    const highlighted = highlight`I love ${name2} especially ${version} features!`;
                    // "I love <strong>JavaScript</strong> especially <strong>ES6</strong> features!"
                    """,
                    explanation: "Template literals provide a powerful way to work with strings, allowing for multiline strings, expression interpolation, and even advanced string processing with tagged templates."
                )
            ],
            level: .intermediate
        )
    ]
}

// Move the static properties into an extension block
extension JavaScriptTutorial {
    // Algorithm tutorials (medium difficulty)
    static let algorithmTutorials: [JavaScriptTutorial] = [
        JavaScriptTutorial(
            title: "Two Sum Problem",
            description: "Solve the classic Two Sum problem using hash maps for O(n) time complexity",
            category: .arrays,
            examples: [
                JSCodeExample(
                    title: "Hash Map Solution",
                    code: """
                    /**
                     * Given an array of integers nums and an integer target,
                     * return indices of the two numbers such that they add up to target.
                     */
                    function twoSum(nums, target) {
                        // Create a hash map to store values and their indices
                        const map = new Map();
                        
                        // Iterate through the array once
                        for (let i = 0; i < nums.length; i++) {
                            const complement = target - nums[i];
                            
                            // Check if the complement exists in our map
                            if (map.has(complement)) {
                                // Return the indices of the two numbers
                                return [map.get(complement), i];
                            }
                            
                            // Store the current number and its index
                            map.set(nums[i], i);
                        }
                        
                        // No solution found
                        return [];
                    }

                    // Example usage
                    const nums = [2, 7, 11, 15];
                    const target = 9;
                    console.log(twoSum(nums, target)); // Output: [0, 1]
                    """,
                    explanation: "This solution uses a hash map to achieve O(n) time complexity. As we iterate through the array, we check if the complement (target - current number) exists in our map. If it does, we've found our solution. Otherwise, we add the current number and its index to the map and continue iterating."
                )
            ],
            level: .intermediate
        ),
        
        JavaScriptTutorial(
            title: "Longest Substring Without Repeating Characters",
            description: "Find the length of the longest substring without repeating characters using sliding window technique",
            category: .arrays,
            examples: [
                JSCodeExample(
                    title: "Sliding Window Approach",
                    code: """
                    /**
                     * Given a string, find the length of the longest substring
                     * without repeating characters.
                     */
                    function lengthOfLongestSubstring(s) {
                        // Track the characters in our current window
                        const charSet = new Set();
                        
                        let left = 0; // Left pointer of the window
                        let maxLength = 0; // Result - longest substring length
                        
                        // Expand the window to the right
                        for (let right = 0; right < s.length; right++) {
                            // If we find a repeating character
                            while (charSet.has(s[right])) {
                                // Remove leftmost character from the set and shrink window
                                charSet.delete(s[left]);
                                left++;
                            }
                            
                            // Add current character to the set
                            charSet.add(s[right]);
                            
                            // Update the maximum length found so far
                            maxLength = Math.max(maxLength, right - left + 1);
                        }
                        
                        return maxLength;
                    }

                    // Example usage
                    console.log(lengthOfLongestSubstring("abcabcbb")); // Output: 3 ("abc")
                    console.log(lengthOfLongestSubstring("bbbbb"));    // Output: 1 ("b")
                    console.log(lengthOfLongestSubstring("pwwkew"));   // Output: 3 ("wke")
                    """,
                    explanation: "This solution uses the sliding window technique to efficiently find the longest substring without repeating characters. We maintain a window bounded by left and right pointers. As we expand the window to the right, we check if the new character creates a duplicate. If it does, we shrink the window from the left until we remove the duplicate. We keep track of the maximum window size throughout the process."
                )
            ],
            level: .intermediate
        ),
        
        // Animation examples
        JavaScriptTutorial(
            title: "JavaScript Animations with requestAnimationFrame",
            description: "Learn how to create smooth animations using requestAnimationFrame",
            category: .async,
            examples: [
                JSCodeExample(
                    title: "Smooth Animation Loop",
                    code: """
                    /**
                     * Create a smooth animation using requestAnimationFrame
                     * This example animates a box moving across the screen
                     */
                    
                    // Element to animate
                    const box = document.getElementById('animatedBox');
                    let position = 0;
                    let animationId = null;
                    
                    // Animation function
                    function animate() {
                        // Update position
                        position += 2;
                        
                        // Apply the new position
                        box.style.transform = `translateX(${position}px)`;
                        
                        // Stop when reaching the end (e.g., 300px)
                        if (position < 300) {
                            // Continue the animation
                            animationId = requestAnimationFrame(animate);
                        }
                    }
                    
                    // Start the animation
                    function startAnimation() {
                        // Reset position if needed
                        if (position >= 300) position = 0;
                        
                        // Start the animation loop
                        animationId = requestAnimationFrame(animate);
                    }
                    
                    // Stop the animation
                    function stopAnimation() {
                        if (animationId) {
                            cancelAnimationFrame(animationId);
                            animationId = null;
                        }
                    }
                    
                    // HTML: <div id="animatedBox" style="width:50px;height:50px;background:red;"></div>
                    // HTML: <button onclick="startAnimation()">Start</button>
                    // HTML: <button onclick="stopAnimation()">Stop</button>
                    """,
                    explanation: "This example demonstrates how to create smooth animations in JavaScript using requestAnimationFrame, which syncs with the browser's refresh rate. The animation loop updates the position of an element and continues until it reaches a certain point. This approach is more efficient than using setInterval for animations because it optimizes for the browser's rendering cycle and pauses when the tab is not active."
                ),
                
                JSCodeExample(
                    title: "Animated Progress Bar",
                    code: """
                    /**
                     * Create an animated progress bar
                     */
                    class ProgressBar {
                        constructor(element, duration = 3000) {
                            this.progressElement = element;
                            this.duration = duration;
                            this.startTime = null;
                            this.animationId = null;
                        }
                        
                        start() {
                            // Reset if already complete
                            this.progressElement.style.width = '0%';
                            this.startTime = performance.now();
                            this.animate();
                        }
                        
                        animate(currentTime) {
                            if (!this.startTime) this.startTime = currentTime;
                            
                            // Calculate progress based on elapsed time
                            const elapsedTime = currentTime - this.startTime;
                            const progress = Math.min(elapsedTime / this.duration, 1);
                            const width = progress * 100;
                            
                            // Update the progress bar width
                            this.progressElement.style.width = `${width}%`;
                            
                            // Continue animation if not complete
                            if (progress < 1) {
                                this.animationId = requestAnimationFrame(this.animate.bind(this));
                            }
                        }
                        
                        stop() {
                            if (this.animationId) {
                                cancelAnimationFrame(this.animationId);
                                this.animationId = null;
                            }
                        }
                    }

                    // Usage example:
                    // HTML: <div class="progress-container" style="width:300px;height:20px;background:#eee;border-radius:10px;">
                    //         <div id="progress" style="height:100%;background:blue;width:0%;border-radius:10px;"></div>
                    //       </div>
                    // HTML: <button id="startBtn">Start Progress</button>

                    const progressElement = document.getElementById('progress');
                    const progressBar = new ProgressBar(progressElement, 2000); // 2 seconds

                    document.getElementById('startBtn').addEventListener('click', () => {
                        progressBar.start();
                    });
                    """,
                    explanation: "This example creates a reusable ProgressBar class that animates a progress bar over a specified duration. The animation uses requestAnimationFrame to smoothly update the progress. The class keeps track of the start time and calculates the progress based on the elapsed time, creating a smooth linear animation. This pattern is useful for loading indicators, form submission feedback, or any visual progress indication."
                )
            ],
            level: .intermediate
        ),
        
        // Low-level JavaScript examples
        JavaScriptTutorial(
            title: "Bit Manipulation in JavaScript",
            description: "Learn how to use bitwise operators for efficient low-level operations",
            category: .basics,
            examples: [
                JSCodeExample(
                    title: "Working with Bits",
                    code: """
                    /**
                     * Bit manipulation examples using JavaScript's bitwise operators
                     */
                    
                    // 1. Check if a number is even or odd
                    function isEven(num) {
                        return (num & 1) === 0;
                    }
                    
                    // 2. Calculate the power of 2
                    function isPowerOfTwo(num) {
                        return num > 0 && (num & (num - 1)) === 0;
                    }
                    
                    // 3. Swap two numbers without a temporary variable
                    function swapBitwise(a, b) {
                        console.log(`Before swap: a = ${a}, b = ${b}`);
                        
                        a = a ^ b;
                        b = a ^ b;
                        a = a ^ b;
                        
                        console.log(`After swap: a = ${a}, b = ${b}`);
                        return [a, b];
                    }
                    
                    // 4. Count the number of set bits (1's) in a number
                    function countSetBits(num) {
                        let count = 0;
                        while (num > 0) {
                            count += num & 1;
                            num >>>= 1; // Unsigned right shift
                        }
                        return count;
                    }
                    
                    // 5. Get the rightmost set bit position
                    function getRightmostSetBitPos(num) {
                        if (num === 0) return -1;
                        
                        let position = 1;
                        let mask = 1;
                        
                        while ((num & mask) === 0) {
                            mask <<= 1;
                            position++;
                        }
                        
                        return position;
                    }
                    
                    // Examples
                    console.log("Is 10 even?", isEven(10)); // true
                    console.log("Is 7 even?", isEven(7));   // false
                    
                    console.log("Is 16 a power of 2?", isPowerOfTwo(16)); // true
                    console.log("Is 24 a power of 2?", isPowerOfTwo(24)); // false
                    
                    swapBitwise(5, 9); // Swaps 5 and 9 without a temp variable
                    
                    console.log("Number of set bits in 13:", countSetBits(13)); // 3 (1101 has three 1's)
                    
                    console.log("Rightmost set bit position of 12:", getRightmostSetBitPos(12)); // 3 (1100 - the first 1 is at position 3)
                    """,
                    explanation: "This tutorial demonstrates low-level bit manipulation in JavaScript. Bitwise operations are extremely efficient as they work directly with the binary representation of numbers. The examples show practical applications like checking if a number is even or a power of 2, swapping values without a temporary variable, counting set bits, and finding bit positions. While JavaScript is a high-level language, these techniques give you access to low-level optimizations typically found in languages like C or C++."
                )
            ],
            level: .advanced
        ),
        
        // For loop patterns and optimizations
        JavaScriptTutorial(
            title: "Advanced For Loop Patterns",
            description: "Explore different for loop patterns and optimizations in JavaScript",
            category: .basics,
            examples: [
                JSCodeExample(
                    title: "Loop Performance Optimization",
                    code: """
                    /**
                     * Different types of loops and their performance characteristics
                     */
                    
                    // Setup a large array for testing
                    const size = 1000000;
                    const largeArray = Array(size).fill(1);
                    
                    // 1. Classic for loop with cached length
                    function classicForLoop() {
                        console.time('Classic for loop');
                        let sum = 0;
                        // Cache the length to avoid recalculating in each iteration
                        for (let i = 0, len = largeArray.length; i < len; i++) {
                            sum += largeArray[i];
                        }
                        console.timeEnd('Classic for loop');
                        return sum;
                    }
                    
                    // 2. Decrementing for loop
                    function decrementingForLoop() {
                        console.time('Decrementing for loop');
                        let sum = 0;
                        // Decrementing can be faster in some JS engines
                        for (let i = largeArray.length - 1; i >= 0; i--) {
                            sum += largeArray[i];
                        }
                        console.timeEnd('Decrementing for loop');
                        return sum;
                    }
                    
                    // 3. For-of loop (ES6)
                    function forOfLoop() {
                        console.time('For-of loop');
                        let sum = 0;
                        // Cleaner syntax, but potentially slower for large arrays
                        for (const value of largeArray) {
                            sum += value;
                        }
                        console.timeEnd('For-of loop');
                        return sum;
                    }
                    
                    // 4. forEach method
                    function forEachMethod() {
                        console.time('forEach method');
                        let sum = 0;
                        largeArray.forEach(value => {
                            sum += value;
                        });
                        console.timeEnd('forEach method');
                        return sum;
                    }
                    
                    // 5. Duff's device - loop unrolling
                    function duffsDevice() {
                        console.time("Duff's device");
                        let sum = 0;
                        let i = 0;
                        const len = largeArray.length;
                        
                        // Process 8 items at once
                        const iterations = Math.floor(len / 8);
                        const remainder = len % 8;
                        
                        let n = iterations;
                        
                        // Handle the remainder first
                        if (remainder > 0) {
                            do {
                                sum += largeArray[i++];
                            } while (--remainder > 0);
                        }
                        
                        // Process in chunks of 8
                        if (n > 0) {
                            do {
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                                sum += largeArray[i++];
                            } while (--n > 0);
                        }
                        
                        console.timeEnd("Duff's device");
                        return sum;
                    }
                    
                    // Run all methods and compare
                    function compareLoopPerformance() {
                        const results = {
                            classic: classicForLoop(),
                            decrementing: decrementingForLoop(),
                            forOf: forOfLoop(),
                            forEach: forEachMethod(),
                            duffs: duffsDevice()
                        };
                        
                        console.log('All methods returned the same result:', 
                            results.classic === results.decrementing && 
                            results.decrementing === results.forOf &&
                            results.forOf === results.forEach &&
                            results.forEach === results.duffs);
                        
                        return results;
                    }
                    
                    // Run the comparison
                    // compareLoopPerformance();
                    
                    // Note: Loop performance can vary significantly between browsers
                    // and JavaScript engines. Always benchmark in your target environment.
                    """,
                    explanation: "This tutorial explores different loop patterns in JavaScript and their performance characteristics. The classic for loop with cached length is often the most efficient for large arrays. Decrementing loops can be faster in some JS engines. For-of loops offer cleaner syntax but might be slower for large arrays. The forEach method is convenient but adds function call overhead. Duff's device is an advanced technique that uses loop unrolling to process multiple items per iteration. For critical code paths, choosing the right loop pattern can significantly impact performance, but always measure in your specific environment as JavaScript engines constantly evolve."
                ),
                
                JSCodeExample(
                    title: "2D Grid Traversal Patterns",
                    code: """
                    /**
                     * Various patterns for traversing 2D grids
                     */
                    
                    // Sample 2D grid
                    const grid = [
                        [1, 2, 3, 4],
                        [5, 6, 7, 8],
                        [9, 10, 11, 12],
                        [13, 14, 15, 16]
                    ];
                    
                    // 1. Row-by-row traversal
                    function rowByRowTraversal(grid) {
                        const result = [];
                        const rows = grid.length;
                        const cols = grid[0].length;
                        
                        for (let i = 0; i < rows; i++) {
                            for (let j = 0; j < cols; j++) {
                                result.push(grid[i][j]);
                            }
                        }
                        
                        return result;
                    }
                    
                    // 2. Column-by-column traversal
                    function columnByColumnTraversal(grid) {
                        const result = [];
                        const rows = grid.length;
                        const cols = grid[0].length;
                        
                        for (let j = 0; j < cols; j++) {
                            for (let i = 0; i < rows; i++) {
                                result.push(grid[i][j]);
                            }
                        }
                        
                        return result;
                    }
                    
                    // 3. Spiral traversal
                    function spiralTraversal(grid) {
                        const result = [];
                        if (grid.length === 0) return result;
                        
                        let top = 0;
                        let bottom = grid.length - 1;
                        let left = 0;
                        let right = grid[0].length - 1;
                        let direction = 0;
                        
                        while (top <= bottom && left <= right) {
                            if (direction === 0) { // Move right
                                for (let i = left; i <= right; i++) {
                                    result.push(grid[top][i]);
                                }
                                top++;
                            } else if (direction === 1) { // Move down
                                for (let i = top; i <= bottom; i++) {
                                    result.push(grid[i][right]);
                                }
                                right--;
                            } else if (direction === 2) { // Move left
                                for (let i = right; i >= left; i--) {
                                    result.push(grid[bottom][i]);
                                }
                                bottom--;
                            } else if (direction === 3) { // Move up
                                for (let i = bottom; i >= top; i--) {
                                    result.push(grid[i][left]);
                                }
                                left++;
                            }
                            
                            direction = (direction + 1) % 4;
                        }
                        
                        return result;
                    }
                    
                    // 4. Zigzag traversal
                    function zigzagTraversal(grid) {
                        const result = [];
                        const rows = grid.length;
                        if (rows === 0) return result;
                        const cols = grid[0].length;
                        
                        for (let sum = 0; sum <= rows + cols - 2; sum++) {
                            // For even diagonal, go up-right
                            if (sum % 2 === 0) {
                                for (let i = Math.min(sum, rows - 1); i >= 0 && sum - i < cols; i--) {
                                    result.push(grid[i][sum - i]);
                                }
                            } else { // For odd diagonal, go down-left
                                for (let i = Math.min(sum, cols - 1); i >= 0 && sum - i < rows; i--) {
                                    result.push(grid[sum - i][i]);
                                }
                            }
                        }
                        
                        return result;
                    }
                    
                    // Test all traversal methods
                    console.log("Row-by-row:", rowByRowTraversal(grid));
                    console.log("Column-by-column:", columnByColumnTraversal(grid));
                    console.log("Spiral:", spiralTraversal(grid));
                    console.log("Zigzag:", zigzagTraversal(grid));
                    """,
                    explanation: "This tutorial showcases different patterns for traversing 2D grids using nested for loops. Row-by-row traversal scans each row from left to right, moving down. Column-by-column traversal scans each column from top to bottom, moving right. Spiral traversal moves around the edges of the grid in a spiral pattern, gradually moving inward. Zigzag traversal moves diagonally, alternating between going up-right and down-left. These traversal patterns are commonly used in image processing, game development, and algorithms that work with matrices."
                )
            ],
            level: .intermediate
        )
    ]
    
    // Update the existing sampleTutorials instead of redeclaring it
    static var allTutorials: [JavaScriptTutorial] {
        return sampleTutorials + algorithmTutorials
    }
}
