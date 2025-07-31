//
//  MathView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//
import SwiftUI
import SwiftMath

struct MathView: UIViewRepresentable {
    let equation: String
    var fontSize: CGFloat = 20
    var textColor: UIColor = .label
    var textAlignment: MTTextAlignment = .center
    var labelMode: MTMathUILabelMode = .display
    
    func makeUIView(context: Context) -> MTMathUILabel {
        print("Creating MathView for: \(equation)")
        let mathLabel = MTMathUILabel()
        mathLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // Debug background
        return mathLabel
    }
    
    func updateUIView(_ mathLabel: MTMathUILabel, context: Context) {
        print("Updating MathView with equation: \(equation)")
        
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.textColor = textColor
        mathLabel.textAlignment = textAlignment
        mathLabel.labelMode = labelMode
        
        // Debug: Print if the equation was parsed successfully
        if mathLabel.latex != "" {
            print("LaTeX set successfully: \(equation)")
        } else {
            print("Failed to set LaTeX: \(equation)")
        }
        
        // Force layout
        mathLabel.sizeToFit()
        print("MathLabel size after sizeToFit: \(mathLabel.bounds.size)")
        
        // Set a minimum frame if size is zero
        if mathLabel.bounds.size.width == 0 || mathLabel.bounds.size.height == 0 {
            mathLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
            print("Set minimum frame: \(mathLabel.frame)")
        }
    }
}

// Convenience initializers
extension MathView {
    init(_ equation: String) {
        self.equation = equation
    }
    
    init(_ equation: String, fontSize: CGFloat) {
        self.equation = equation
        self.fontSize = fontSize
    }
}
