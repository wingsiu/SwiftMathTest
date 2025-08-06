//
//  MathRenderProfiler.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//
import SwiftMath
#if canImport(UIKit)
import UIKit
#endif

struct MathRenderProfiler {
    static func profileStages(latex: String, fontSize: CGFloat = 20) {
        let t0 = CFAbsoluteTimeGetCurrent()
        let mathLabel = MTMathUILabel()
        let t1 = CFAbsoluteTimeGetCurrent()
        
        mathLabel.fontSize = fontSize
        mathLabel.latex = latex
        let t2 = CFAbsoluteTimeGetCurrent()
        
        mathLabel.sizeToFit()
        let t3 = CFAbsoluteTimeGetCurrent()
        
        #if canImport(UIKit)
        // Force rasterization and drawing
        let renderer = UIGraphicsImageRenderer(size: mathLabel.bounds.size)
        _ = renderer.image { ctx in
            mathLabel.layer.render(in: ctx.cgContext)
        }
        let t4 = CFAbsoluteTimeGetCurrent()
        #endif
        
        print("=== Math Rendering Profile ===")
        print("Initialization: \((t1-t0)*1000) ms")
        print("LaTeX Parsing: \((t2-t1)*1000) ms")
        print("Layout: \((t3-t2)*1000) ms")
        #if canImport(UIKit)
        print("Rasterization: \((t4-t3)*1000) ms")
        print("Total: \((t4-t0)*1000) ms")
        #else
        print("Total: \((t3-t0)*1000) ms")
        #endif
        print("=============================")
    }
}
