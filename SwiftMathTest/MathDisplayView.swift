//
//  MathDisplayView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//

import SwiftUI
import SwiftMath

struct MathDisplayView: View {
    let mathExamples = [
        ("Einstein's Mass-Energy", "E = mc^2"),
        ("Quadratic Formula", "x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}"),
        ("Gaussian Integral", "\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}"),
        ("Basel Problem", "\\sum_{n=1}^{\\infty} \\frac{1}{n^2} = \\frac{\\pi^2}{6}"),
        ("Euler's Identity", "e^{i\\pi} + 1 = 0"),
        ("Matrix Example", "\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}"),
        ("Derivative", "\\frac{d}{dx}\\left(\\int_{a}^{x} f(t) dt\\right) = f(x)"),
        ("Limit Definition", "\\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}")
    ]
    
    @State private var selectedFontSize: CGFloat = 20
    @State private var renderingTimes: [String: Double] = [:]
    
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
                            .background(Color.blue.opacity(0.05))
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
                        if let renderTime = renderingTimes[equation] {
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
                
                // Performance test button
                Button("Measure All Rendering Times") {
                    measureRenderingPerformance()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Math Display")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func measureRenderingPerformance() {
        renderingTimes.removeAll()
        
        for (_, equation) in mathExamples {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            // Create a temporary view to measure rendering time
            let mathLabel = MTMathUILabel()
            mathLabel.latex = equation
            mathLabel.fontSize = selectedFontSize
            mathLabel.sizeToFit()
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let renderTime = (endTime - startTime) * 1000 // Convert to milliseconds
            
            renderingTimes[equation] = renderTime
        }
    }
}

#Preview {
    NavigationView {
        MathDisplayView()
    }
}
