import SwiftUI
import SwiftMath

struct DetailedAnalysisView: View {
    @State private var analysisResults: [String] = []
    @State private var isRunning = false
    
    var body: some View {
        VStack {
            if isRunning {
                ProgressView("Running detailed analysis...")
                    .padding()
            } else {
                VStack(spacing: 12) {
                    Button("🔬 Run Complete Analysis Suite") {
                        runCompleteAnalysis()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("📊 LaTeX Complexity Analysis") {
                        runComplexityAnalysis()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("⚡ Performance Baseline") {
                        establishBaseline()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            
            List(analysisResults, id: \.self) { result in
                Text(result)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Detailed Analysis")
    }
    
    func runCompleteAnalysis() {
        isRunning = true
        analysisResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== COMPLETE SWIFTMATH ANALYSIS ===")
            results.append("Date: \(Date().formatted())")
            results.append("")
            
            // Test 1: System initialization
            results.append("1. SYSTEM INITIALIZATION TEST")
            results.append("   Testing cold start penalty...")
            let coldStart = measureEquationRenderTime("x")
            results.append("   First equation render: \(String(format: "%.2f", coldStart))ms")
            
            // Test 2: Warmup verification
            let warmup1 = measureEquationRenderTime("y")
            let warmup2 = measureEquationRenderTime("z")
            results.append("   Second equation render: \(String(format: "%.2f", warmup1))ms")
            results.append("   Third equation render: \(String(format: "%.2f", warmup2))ms")
            
            if coldStart > 0 {
                let improvement = ((coldStart - warmup1) / coldStart) * 100
                results.append("   Warmup improvement: \(String(format: "%.1f", improvement))%")
            }
            results.append("")
            
            // Test 3: LaTeX parser performance
            results.append("2. LATEX PARSER PERFORMANCE")
            let parserTests = [
                ("Simple variable", "x"),
                ("Addition", "a + b"),
                ("Exponent", "x^2"),
                ("Fraction", "\\frac{1}{2}"),
                ("Nested fraction", "\\frac{\\frac{a}{b}}{\\frac{c}{d}}"),
                ("Square root", "\\sqrt{x}"),
                ("Nested root", "\\sqrt{\\sqrt{x}}"),
                ("Integral", "\\int_0^1 x dx"),
                ("Complex integral", "\\int_{-\\infty}^{\\infty} e^{-x^2} dx"),
                ("Sum", "\\sum_{i=1}^n i"),
                ("Matrix 2x2", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"),
                ("Matrix 3x3", "\\begin{pmatrix} 1 & 2 & 3 \\\\ 4 & 5 & 6 \\\\ 7 & 8 & 9 \\end{pmatrix}")
            ]
            
            var parserTimes: [Double] = []
            for (name, latex) in parserTests {
                let time = measureEquationRenderTime(latex)
                parserTimes.append(time)
                results.append("   \(name): \(String(format: "%.2f", time))ms")
            }
            
            results.append("")
            results.append("   Parser Performance Summary:")
            results.append("   Fastest: \(String(format: "%.2f", parserTimes.min() ?? 0))ms")
            results.append("   Slowest: \(String(format: "%.2f", parserTimes.max() ?? 0))ms")
            if !parserTimes.isEmpty {
                results.append("   Average: \(String(format: "%.2f", parserTimes.reduce(0, +) / Double(parserTimes.count)))ms")
            }
            results.append("")
            
            // Test 4: Font size scaling
            results.append("3. FONT SIZE SCALING")
            let fontSizes: [CGFloat] = [10, 16, 20, 24, 32, 48]
            let scalingEquation = "\\frac{dy}{dx} = \\lim_{h \\to 0} \\frac{f(x+h)-f(x)}{h}"
            
            var fontTimes: [Double] = []
            for size in fontSizes {
                let time = measureEquationRenderTime(scalingEquation, fontSize: size)
                fontTimes.append(time)
                results.append("   Font \(Int(size))pt: \(String(format: "%.2f", time))ms")
            }
            
            results.append("")
            results.append("   Font Scaling Analysis:")
            if let minFontTime = fontTimes.min(), let maxFontTime = fontTimes.max(), minFontTime > 0 {
                results.append("   Font impact ratio: \(String(format: "%.1f", maxFontTime/minFontTime))x")
            }
            results.append("")
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.analysisResults = results
                self.isRunning = false
            }
        }
    }
    
    func runComplexityAnalysis() {
        isRunning = true
        analysisResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== LATEX COMPLEXITY ANALYSIS ===")
            results.append("")
            
            let complexityLevels = [
                ("Level 1 - Basic", [
                    "x", "y", "z", "a + b", "x - y", "2x", "x^2"
                ]),
                ("Level 2 - Intermediate", [
                    "\\frac{a}{b}", "\\sqrt{x}", "x^{2y}", "a_i", "\\alpha", "\\beta"
                ]),
                ("Level 3 - Advanced", [
                    "\\int_0^1 x dx", "\\sum_{i=1}^n i", "\\lim_{x \\to 0} f(x)", "\\frac{\\partial f}{\\partial x}"
                ]),
                ("Level 4 - Complex", [
                    "\\int_{-\\infty}^{\\infty} e^{-x^2} dx", "\\sum_{n=1}^{\\infty} \\frac{1}{n^2}", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"
                ]),
                ("Level 5 - Very Complex", [
                    "\\frac{\\partial^2 u}{\\partial t^2} = c^2 \\nabla^2 u",
                    "\\oint_{\\partial D} \\omega = \\int_D d\\omega",
                    "\\begin{pmatrix} 1 & 2 & 3 \\\\ 4 & 5 & 6 \\\\ 7 & 8 & 9 \\end{pmatrix}"
                ])
            ]
            
            var allLevelAverages: [Double] = []
            
            for (level, equations) in complexityLevels {
                results.append(level)
                var levelTimes: [Double] = []
                
                for equation in equations {
                    let time = measureEquationRenderTime(equation)
                    levelTimes.append(time)
                    results.append("  \(equation): \(String(format: "%.2f", time))ms")
                }
                
                if !levelTimes.isEmpty {
                    let avgTime = levelTimes.reduce(0, +) / Double(levelTimes.count)
                    allLevelAverages.append(avgTime)
                    results.append("  Level average: \(String(format: "%.2f", avgTime))ms")
                }
                results.append("")
            }
            
            // Overall complexity analysis
            results.append("--- COMPLEXITY IMPACT ANALYSIS ---")
            for (index, avg) in allLevelAverages.enumerated() {
                results.append("Level \(index + 1) average: \(String(format: "%.2f", avg))ms")
            }
            
            if let simpleAvg = allLevelAverages.first, let complexAvg = allLevelAverages.last, simpleAvg > 0 {
                results.append("Complexity impact: \(String(format: "%.1f", complexAvg/simpleAvg))x")
            }
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.analysisResults = results
                self.isRunning = false
            }
        }
    }
    
    func establishBaseline() {
        isRunning = true
        analysisResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== PERFORMANCE BASELINE ===")
            results.append("Establishing baseline for optimization comparison")
            results.append("")
            
            // Standard benchmark equations
            let benchmarkEquations = [
                ("Simple", "x + y"),
                ("Quadratic", "ax^2 + bx + c = 0"),
                ("Fraction", "\\frac{a}{b}"),
                ("Root", "\\sqrt{x^2 + y^2}"),
                ("Integration", "\\int_0^1 f(x) dx"),
                ("Sum", "\\sum_{i=1}^n x_i"),
                ("Matrix", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"),
                ("Derivative", "\\frac{df}{dx}"),
                ("Limit", "\\lim_{x \\to 0} \\frac{\\sin x}{x} = 1"),
                ("Complex", "e^{i\\theta} = \\cos\\theta + i\\sin\\theta")
            ]
            
            results.append("BASELINE MEASUREMENTS (Run multiple times for accuracy)")
            results.append("")
            
            var allTimes: [Double] = []
            
            for (name, equation) in benchmarkEquations {
                // Run each equation 3 times and take average
                var times: [Double] = []
                for _ in 0..<3 {
                    let time = measureEquationRenderTime(equation)
                    times.append(time)
                }
                
                let avgTime = times.reduce(0, +) / Double(times.count)
                allTimes.append(avgTime)
                
                results.append("\(name): \(String(format: "%.2f", avgTime))ms")
                results.append("  LaTeX: \(equation)")
                results.append("  Individual times: \(times.map { String(format: "%.2f", $0) }.joined(separator: "ms, "))ms")
                results.append("")
            }
            
            results.append("BASELINE SUMMARY")
            results.append("Total equations: \(benchmarkEquations.count)")
            if !allTimes.isEmpty {
                results.append("Average time: \(String(format: "%.2f", allTimes.reduce(0, +) / Double(allTimes.count)))ms")
            }
            results.append("Fastest: \(String(format: "%.2f", allTimes.min() ?? 0))ms")
            results.append("Slowest: \(String(format: "%.2f", allTimes.max() ?? 0))ms")
            results.append("")
            results.append("Use these numbers to compare against your optimized fork!")
            
            printToConsole(results)
            
            DispatchQueue.main.async {
                self.analysisResults = results
                self.isRunning = false
            }
        }
    }
    
    func measureEquationRenderTime(_ equation: String, fontSize: CGFloat = 20) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let mathLabel = MTMathUILabel()
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.sizeToFit()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        return (endTime - startTime) * 1000
    }
    
    func printToConsole(_ results: [String]) {
        print("\n" + String(repeating: "=", count: 60))
        print("DETAILED ANALYSIS RESULTS")
        print(String(repeating: "=", count: 60))
        for result in results {
            print(result)
        }
        print(String(repeating: "=", count: 60) + "\n")
    }
}

#Preview {
    NavigationView {
        DetailedAnalysisView()
    }
}
