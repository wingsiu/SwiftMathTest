//
//  MathDisplayView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//

import SwiftUI
import SwiftMath

struct MathDisplayView: View {
    let mathExample = [
        ("Comlex 1", "\\colorbox{#FFFF00}{\\sqrt{a+\\frac{3}{x^2}}}\\int_0^1\\sum_{i=0}^{n+a+b+c} \\left(\\frac{\\displaystyle\\int y^3+\\frac{x}{5}-1}{\\int x^3-4\\sqrt[3]{x}+\\frac{5+\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}=\\int \\lim_{x\\to\\infty}\\cos x 😃dx\\right)"),
        ("Complex 2","\\sqrt[3]{a+\\frac{3}{x^2}}\\int_0^1\\frac{{\\int y}^3+\\frac{x}{5}-1}{x^4-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}= \\int_0^1 a \\cos x 😃dx"),
        ("complex 3","12x3^{\\int 2}+\\frac{\\int a}{b}-\\sqrt[n]{x+y^2-\\frac{\\frac{z}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}+\\int_0^1 \\sum aa+3a" ),
        ("Complex 4", "\\begin{pmatrix} 1 & 2 & 3\\\\ a & b & c  \\end{pmatrix}"),
        ("Complex 5", "12x3^{\\int 2}+\\frac{\\int a}{b}-\\sqrt[n]{x+y^2-\\frac{\\frac{z}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}+\\int_0^1 \\sum aa+3a"),
        ("Complex 6","\\sum \\frac{\\int x^5+ \\frac{3}{\\frac{y}{3-z}}-1}{x^5-3x^5 +\\frac{3+\\frac{3+x}{4-y}}{\\frac{9v}{1+\\frac{ 2}{3}+{3}+6y}}}=\\int \\cos^2 x +2dx"),
        ("Complex 7","A+\\int_0^1 a😃日+x^{{y+x}^3}"),
        ("Complex 8","\\begin{pmatrix} 1 & -5\\frac 2u \\\\ e& x\\\\ -\\frac{\\sqrt x}{3} & d \\end{pmatrix}\\begin{pmatrix} a & -2\\frac bc \\\\ -\\frac{\\sqrt x}{3} & d \\\\\\end{pmatrix}"),
        ("Complex 9","\\sqrt{a+\\frac{3 }{x^2}}\\int_0^1\\color{#0000FF}{\\sum_{i=1}^{n+1+a+b}}\\left(\\frac{{\\int y}^3+\\color{#FFFF00}{\\frac{x}{5}}-1}{x-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}=\\int^{2x} \\cos x 😃dx\\right)"),
        ("Einstein's Mass-Energy", "E = mc^2"),
        ("Quadratic Formula", "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"),
        ("Gaussian Integral", "\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}"),
        ("Basel Problem", "\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}"),
        ("Euler's Identity", "e^{i\\pi} + 1 = 0"),
        ("Matrix Example", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"),
        ("Derivative", "\\frac{d}{dx}\\left(\\int_{a}^{x} f(t) dt\\right) = f(x)"),
        ("Limit Definition", "\\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}")
        
    ]
    
    var mathExamples: [(String, String)] {
        Array(repeating: mathExample, count: 4).flatMap { $0 }
    }
    
    
    @State private var selectedFontSize: CGFloat = 20
    //@State private var renderingTimes: [String: Double] = [:]
    @State private var renderingTimes: [Int: Double] = [:]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                // Font size selector
                VStack {
                    Text("Font Size: \(Int(selectedFontSize))")
                        .font(.headline)
                    
                    Slider(value: $selectedFontSize, in: 12...32, step: 2)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Performance test button
                Button("Measure All Rendering Times") {
                    tryTokenize()
                    //measureRenderingStagePerformance()
                    //measureRenderingPerformance()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                // Math examples
                ForEach(mathExamples.indices, id: \.self) { index in
                    let (title, equation) = mathExamples[index]
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Rendered math equation
                        MathView(equation, fontSize: selectedFontSize)
                            .frame(minHeight: 40)
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color.blue : Color.blue.opacity(0.05))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                        
                        // LaTeX source
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LaTeX Source:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(equation)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        // Performance info (if available)
                        //                       if let renderTime = renderingTimes[equation] {
                        if let renderTime = renderingTimes[index] {
                            Text("Render time: \(String(format: "%.2f", renderTime))ms")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                
            }
            .padding()
        }
        .navigationTitle("Math Display")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func tryTokenize() {
        for (_, equation) in mathExamples.enumerated() {
            let input = equation.1
            let tokenizer = LatexTokenizer(input)
            var tokens: [LatexToken] = []
            var tok: LatexToken
            repeat {
                tok = tokenizer.nextToken()
                tokens.append(tok)
            } while tok != .eof
            print("Equation: \(input) \n")
            let parser = LatexParser(input)
            let ast = parser.parse()
            print(ast)
            //print(tokens)
        }
    }
    
    func measureRenderingPerformance() {
        renderingTimes.removeAll()
        
        //ForEach(mathExamples.indices, id: \.self) { index in
        //  let (title, equation) = mathExamples[index]
        //for (_, equation) in mathExamples {
        for (index, equation) in mathExamples.enumerated() {
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Create a temporary view to measure rendering time
            let mathLabel = MTMathUILabel()
            mathLabel.latex = equation.1
            mathLabel.fontSize = selectedFontSize
            mathLabel.sizeToFit()
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let renderTime = (endTime - startTime) * 1000 // Convert to milliseconds
            
            //renderingTimes[equation] = renderTime
            renderingTimes[index] = renderTime
            print("Rendered \(equation.1) in \(renderTime) ms")
            
            
        }
    }
    
    func measureRenderingStagePerformance() {
        for (_, equation) in mathExamples.enumerated() {
            print("Profiling \(equation.1)")
            MathRenderProfiler.profileStages(latex: equation.1)
        }
    }

    
}



#Preview {
    NavigationView {
        MathDisplayView()
    }
}
