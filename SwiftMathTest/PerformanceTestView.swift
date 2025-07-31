import SwiftUI
import SwiftMath

struct PerformanceTestView: View {
    @State private var testResults: [String] = []
    @State private var isRunning = false
    
    let testEquations = [
        ("Simple", "x + y = z"),
        ("Quadratic", "ax^2 + bx + c = 0"),
        ("Fraction", "\\frac{a}{b} + \\frac{c}{d}"),
        ("Square Root", "\\sqrt{x^2 + y^2}"),
        ("Integration", "\\int_{0}^{\\infty} e^{-x} dx"),
        ("Summation", "\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}"),
        ("Complex", "\\frac{\\partial^2 u}{\\partial t^2} = c^2 \\nabla^2 u"),
        ("Matrix", "\\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}")
    ]
    
    var body: some View {
        VStack {
            if isRunning {
                VStack {
                    ProgressView("Running performance tests...")
                    Text("This may take a moment...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Button("Run Standard Performance Tests") {
                        runPerformanceTests()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("🔍 Test 1: First-Render Investigation") {
                        runFirstRenderTest()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("📝 Test 2: Font Size Impact") {
                        runFontSizeTest()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("♻️ Test 3: Cache Effectiveness") {
                        runCacheTest()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🚀 Test 4: Warmup Effect") {
                        runWarmupTest()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Copy Results to Console") {
                        copyResultsToConsole()
                    }
                    .buttonStyle(.bordered)
                    .disabled(testResults.isEmpty)
                }
                .padding()
            }
            
            List(testResults, id: \.self) { result in
                Text(result)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Performance Tests")
    }
    
    // MARK: - Standard Performance Test
    func runPerformanceTests() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== SwiftMath Performance Test ===")
            results.append("Date: \(Date().formatted())")
            results.append("")
            
            var totalTime: Double = 0
            var times: [Double] = []
            
            for (name, equation) in testEquations {
                let renderTime = measureEquationRenderTime(equation)
                totalTime += renderTime
                times.append(renderTime)
                
                results.append("\(name): \(String(format: "%.2f", renderTime))ms")
                results.append("  LaTeX: \(equation)")
                results.append("")
            }
            
            let averageTime = totalTime / Double(testEquations.count)
            let fastestTime = times.min() ?? 0
            let slowestTime = times.max() ?? 0
            
            results.append("--- Summary ---")
            results.append("Total equations: \(testEquations.count)")
            results.append("Total time: \(String(format: "%.2f", totalTime))ms")
            results.append("Average time: \(String(format: "%.2f", averageTime))ms")
            results.append("Fastest: \(String(format: "%.2f", fastestTime))ms")
            results.append("Slowest: \(String(format: "%.2f", slowestTime))ms")
            if fastestTime > 0 {
                results.append("Performance variance: \(String(format: "%.1f", slowestTime/fastestTime))x")
            }
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // MARK: - Test 1: First-Render Investigation
    func runFirstRenderTest() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== First-Render Investigation ===")
            results.append("Testing multiple simple equations in sequence")
            results.append("")
            
            let simpleEquations = [
                "a", "b", "c", "x", "y", "z",
                "1", "2", "3",
                "a + b", "x + y", "p + q"
            ]
            
            var times: [Double] = []
            
            for (index, equation) in simpleEquations.enumerated() {
                let renderTime = measureEquationRenderTime(equation)
                times.append(renderTime)
                
                let status = index == 0 ? " (FIRST - potential cold start)" : ""
                results.append("Equation \(index + 1): '\(equation)' = \(String(format: "%.2f", renderTime))ms\(status)")
            }
            
            results.append("")
            results.append("--- Analysis ---")
            if let firstTime = times.first, times.count > 1 {
                let restTimes = Array(times.dropFirst())
                let avgOfRest = restTimes.reduce(0, +) / Double(restTimes.count)
                results.append("First equation: \(String(format: "%.2f", firstTime))ms")
                results.append("Average of rest: \(String(format: "%.2f", avgOfRest))ms")
                if avgOfRest > 0 {
                    results.append("First vs Rest ratio: \(String(format: "%.1f", firstTime/avgOfRest))x")
                    results.append("Cold start penalty: \(String(format: "%.2f", firstTime - avgOfRest))ms")
                }
            }
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // MARK: - Test 2: Font Size Impact
    func runFontSizeTest() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== Font Size Impact Test ===")
            results.append("Testing same equation with different font sizes")
            results.append("")
            
            let testEquation = "\\frac{a}{b} + \\sqrt{x^2 + y^2}"
            let fontSizes: [CGFloat] = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36]
            
            results.append("Test equation: \(testEquation)")
            results.append("")
            
            var times: [Double] = []
            
            for fontSize in fontSizes {
                let renderTime = measureEquationRenderTime(testEquation, fontSize: fontSize)
                times.append(renderTime)
                
                results.append("Font size \(Int(fontSize)): \(String(format: "%.2f", renderTime))ms")
            }
            
            results.append("")
            results.append("--- Font Size Analysis ---")
            if let minTime = times.min(), let maxTime = times.max() {
                results.append("Smallest font (12pt): \(String(format: "%.2f", times.first ?? 0))ms")
                results.append("Largest font (36pt): \(String(format: "%.2f", times.last ?? 0))ms")
                results.append("Min time: \(String(format: "%.2f", minTime))ms")
                results.append("Max time: \(String(format: "%.2f", maxTime))ms")
                if minTime > 0 {
                    results.append("Font size impact: \(String(format: "%.1f", maxTime/minTime))x")
                }
            }
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // MARK: - Test 3: Cache Effectiveness
    func runCacheTest() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== Cache Effectiveness Test ===")
            results.append("Rendering same equation multiple times")
            results.append("")
            
            let testEquation = "\\int_{0}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}"
            let iterations = 10
            
            results.append("Test equation: \(testEquation)")
            results.append("Iterations: \(iterations)")
            results.append("")
            
            var times: [Double] = []
            
            for i in 0..<iterations {
                let renderTime = measureEquationRenderTime(testEquation)
                times.append(renderTime)
                
                let status = i == 0 ? " (FIRST)" : ""
                results.append("Iteration \(i + 1): \(String(format: "%.2f", renderTime))ms\(status)")
            }
            
            results.append("")
            results.append("--- Cache Analysis ---")
            if let firstTime = times.first, times.count > 1 {
                let restTimes = Array(times.dropFirst())
                let avgRest = restTimes.reduce(0, +) / Double(restTimes.count)
                let minRest = restTimes.min() ?? 0
                let maxRest = restTimes.max() ?? 0
                
                results.append("First render: \(String(format: "%.2f", firstTime))ms")
                results.append("Subsequent renders:")
                results.append("  Average: \(String(format: "%.2f", avgRest))ms")
                results.append("  Min: \(String(format: "%.2f", minRest))ms")
                results.append("  Max: \(String(format: "%.2f", maxRest))ms")
                
                if avgRest > 0 {
                    results.append("Cache effectiveness: \(String(format: "%.1f", firstTime/avgRest))x improvement")
                    let improvement = ((firstTime - avgRest) / firstTime) * 100
                    results.append("Performance improvement: \(String(format: "%.1f", improvement))%")
                }
            }
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // MARK: - Test 4: Warmup Effect
    func runWarmupTest() {
        isRunning = true
        testResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== Warmup Effect Test ===")
            results.append("Testing if system needs warming up")
            results.append("")
            
            // First, do a warmup with simple equations
            results.append("Phase 1: Warmup with simple equations")
            let warmupEquations = ["a", "b", "c"]
            for equation in warmupEquations {
                let time = measureEquationRenderTime(equation)
                results.append("Warmup '\(equation)': \(String(format: "%.2f", time))ms")
            }
            
            results.append("")
            results.append("Phase 2: Test complex equations after warmup")
            
            let complexEquations = [
                ("Integration", "\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}"),
                ("Summation", "\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}"),
                ("Matrix", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"),
                ("Complex", "\\frac{\\partial^2 u}{\\partial t^2} = c^2 \\nabla^2 u")
            ]
            
            var warmupTimes: [Double] = []
            
            for (name, equation) in complexEquations {
                let time = measureEquationRenderTime(equation)
                warmupTimes.append(time)
                results.append("\(name) (after warmup): \(String(format: "%.2f", time))ms")
            }
            
            results.append("")
            results.append("--- Warmup Analysis ---")
            let avgWarmedUp = warmupTimes.reduce(0, +) / Double(warmupTimes.count)
            results.append("Average after warmup: \(String(format: "%.2f", avgWarmedUp))ms")
            results.append("Compare this to your first cold-start results!")
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isRunning = false
            }
        }
    }
    
    // MARK: - Helper Functions
    func measureEquationRenderTime(_ equation: String, fontSize: CGFloat = 20) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let mathLabel = MTMathUILabel()
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.sizeToFit()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        return (endTime - startTime) * 1000 // Convert to milliseconds
    }
    
    func copyResultsToConsole() {
        printToConsole(testResults)
    }
    
    func printToConsole(_ results: [String]) {
        print("\n" + String(repeating: "=", count: 60))
        print("SWIFTMATH TEST RESULTS")
        print(String(repeating: "=", count: 60))
        for result in results {
            print(result)
        }
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    // Fixed function - removed the problematic getTimeFromResult function
    // The functionality it provided is now handled directly in the summary calculations above
}

#Preview {
    NavigationView {
        PerformanceTestView()
    }
}
