//
//  MathRenderBestPracticeView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//

import SwiftUI
import SwiftMath

struct RenderResult: Identifiable {
    let id = UUID()
    let mode: String // "Sequential" or "Parallel"
    let latex: String
    let renderTimeMs: Double
}

enum BenchmarkState: String {
    case cold = "Cold"
    case warm = "Warm"
}

struct MathRenderBestPracticeView: View {
    let equation: [String] = [
        "\\colorbox{#FFFF00}{\\sqrt{a+\\frac{3}{x^2}}}\\int_0^1\\sum_{i=0}^{n+a+b+c} \\left(\\frac{\\displaystyle\\int y^3+\\frac{x}{5}-1}{\\int x^3-4\\sqrt[3]{x}+\\frac{5+\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}=\\int \\lim_{x\\to\\infty}\\cos x 😃dx\\right)",
        "\\sqrt[3]{a+\\frac{3}{x^2}}\\int_0^1\\frac{{\\int y}^3+\\frac{x}{5}-1}{x^4-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}= \\int_0^1 a \\cos x 😃dx",
        "12x3^{\\int 2}+\\frac{\\int a}{b}-\\sqrt[n]{x+y^2-\\frac{\\frac{z}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}+\\int_0^1 \\sum aa+3a" ,
         "\\begin{pmatrix} 1 & 2 & 3\\\\ a & b & c  \\end{pmatrix}",
        "12x3^{\\int 2}+\\frac{\\int a}{b}-\\sqrt[n]{x+y^2-\\frac{\\frac{z}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}+\\int_0^1 \\sum aa+3a",
        "\\sum \\frac{\\int x^5+ \\frac{3}{\\frac{y}{3-z}}-1}{x^5-3x^5 +\\frac{3+\\frac{3+x}{4-y}}{\\frac{9v}{1+\\frac{ 2}{3}+{3}+6y}}}=\\int \\cos^2 x +2dx",
        "A+\\int_0^1 a😃日+x^{{y+x}^3}",
        "\\begin{pmatrix} 1 & -5\\frac 2u \\\\ e& x\\\\ -\\frac{\\sqrt x}{3} & d \\end{pmatrix}\\begin{pmatrix} a & -2\\frac bc \\\\ -\\frac{\\sqrt x}{3} & d \\\\\\end{pmatrix}",
        "\\sqrt{a+\\frac{3 }{x^2}}\\int_0^1\\color{#0000FF}{\\sum_{i=1}^{n+1+a+b}}\\left(\\frac{{\\int y}^3+\\color{#FFFF00}{\\frac{x}{5}}-1}{x-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}=\\int^{2x} \\cos x 😃dx\\right)",
        "E = mc^2",
        "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}",
        "\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}",
        "\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}",
        "e^{i\\pi} + 1 = 0",
        "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}",
        "\\frac{d}{dx}\\left(\\int_{a}^{x} f(t) dt\\right) = f(x)",
        "\\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}"
    ]
    
    var equations: [String] {
        Array(repeating: equation, count: 4).flatMap { $0 }
    }
    @State private var fontSize: CGFloat = 20
    @State private var results: [RenderResult] = []
    @State private var isLoading: Bool = false
    @State private var totalTimeMs: Double = 0
    @State private var lastMode: String = ""
    @State private var state: BenchmarkState = .cold
    @State private var warmUpDone: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Slider(value: $fontSize, in: 12...32, step: 2) {
                    Text("Font Size")
                }
                Text("Font size: \(Int(fontSize))")
                    .font(.caption)

                HStack {
                    Button("Warm Up (Run dummy batch)") {
                        isLoading = true
                        results = []
                        lastMode = ""
                        totalTimeMs = 0
                        Task {
                            // Run dummy parallel batch (could be sequential too) to warm up caches
                            _ = await parallelRender(equations: equations, fontSize: fontSize)
                            warmUpDone = true
                            state = .warm
                            isLoading = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                    Text(warmUpDone ? "State: Warm" : "State: Cold")
                        .font(.caption)
                        .foregroundColor(warmUpDone ? .blue : .gray)
                }

                HStack {
                    Button("Sequential Render") {
                        isLoading = true
                        results = []
                        lastMode = "Sequential"
                        totalTimeMs = 0
                        Task {
                            let (seqResults, total) = sequentialRender(equations: equations, fontSize: fontSize)
                            results.append(contentsOf: seqResults)
                            totalTimeMs = total
                            isLoading = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                    Button("Parallel Render") {
                        isLoading = true
                        results = []
                        lastMode = "Parallel"
                        totalTimeMs = 0
                        Task {
                            let (parResults, total) = await parallelRender(equations: equations, fontSize: fontSize)
                            results.append(contentsOf: parResults)
                            totalTimeMs = total
                            isLoading = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }

                if isLoading {
                    ProgressView()
                }
                if !results.isEmpty {
                    Text("Total \(lastMode) render time (\(state.rawValue) Start): \(String(format: "%.2f", totalTimeMs)) ms")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 6)
                }
                List(results) { result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(result.mode): \(result.latex)")
                            .font(.caption2)
                        Text("Render time: \(String(format: "%.2f", result.renderTimeMs)) ms")
                            .font(.caption)
                            .foregroundColor(result.mode == "Parallel" ? .blue : .green)
                    }
                }
                Divider()
                Text("""
                     Best Practice:
                     - For COLD tests, run after app launch (before Warm Up).
                     - For WARM tests, tap 'Warm Up' first, then run either mode.
                     """)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationTitle("Batch Render Benchmark")
        }
    }

    // Sequential rendering (one after another)
    func sequentialRender(equations: [String], fontSize: CGFloat) -> ([RenderResult], Double) {
        let batchStart = CFAbsoluteTimeGetCurrent()
        let results = equations.map { eq -> RenderResult in
            let start = CFAbsoluteTimeGetCurrent()
            let label = MTMathUILabel()
            label.fontSize = fontSize
            label.latex = eq
            label.sizeToFit()
            let end = CFAbsoluteTimeGetCurrent()
            let ms = (end - start) * 1000
            return RenderResult(mode: "Sequential", latex: eq, renderTimeMs: ms)
        }
        let batchEnd = CFAbsoluteTimeGetCurrent()
        let totalMs = (batchEnd - batchStart) * 1000
        return (results, totalMs)
    }

    // Parallel rendering (using concurrency)
    func parallelRender(equations: [String], fontSize: CGFloat) async -> ([RenderResult], Double) {
        let batchStart = CFAbsoluteTimeGetCurrent()
        let results = await withTaskGroup(of: RenderResult.self) { group in
            for eq in equations {
                group.addTask { @MainActor in
                    let start = CFAbsoluteTimeGetCurrent()
                    let label = MTMathUILabel()
                    //label.fontSize = fontSize
                    label.latex = eq
                    label.sizeToFit()
                    let end = CFAbsoluteTimeGetCurrent()
                    let ms = (end - start) * 1000
                    return RenderResult(mode: "Parallel", latex: eq, renderTimeMs: ms)
                }
            }
            var arr: [RenderResult] = []
            for await result in group {
                arr.append(result)
            }
            return arr
        }
        let batchEnd = CFAbsoluteTimeGetCurrent()
        let totalMs = (batchEnd - batchStart) * 1000
        return (results, totalMs)
    }
}
