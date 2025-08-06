//
//  SwiftMathTestingApp.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//

import SwiftUI
import SwiftMath

@main
struct SwiftMathTestingApp: App {
    
    // Add initialization for SwiftMath performance optimization
    init() {
        // Preload fonts and warmup rendering engine
        MTFontManager.initializeFontSystem()
        // Pre-warm rendering engine for math labels synchronously
        //SwiftMathTestingApp.preWarmRenderingEngine()
        
//        let sizes: [CGFloat] = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36] // Add all you need
//        MathLabelCache.shared.preloadFonts(sizes: sizes)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Performance warmup for SwiftMath
extension SwiftMathTestingApp {
    /// Pre-warm the rendering engine by rendering simple equations at startup
    static func preWarmRenderingEngine() {
        let warmupEquations = ["a", "b", "c", "x", "y", "x^2+3", "\\sum_{n=1}^{10} n",
                               "\\frac{a}{b} + \\sqrt{x^2 + y^2}", "\\int_{0}^{\\infty} e^{-x^2} dx",
                               "\\begin{bmatrix} 1 & 2 \\\\ 3 & 4 \\end{bmatrix}"]
        for equation in warmupEquations {
            let mathLabel = MTMathUILabel()
            mathLabel.latex = equation
            mathLabel.sizeToFit()
        }
        print("SwiftMathTest: Rendering engine pre-warmed (main thread)")
    }
}
