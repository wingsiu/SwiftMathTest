//
//  MathView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//
import SwiftUI
import SwiftMath

struct MathView: UIViewRepresentable, Equatable {
    
    let equation: String
    var fontSize: CGFloat = 20
    var font : MTFont = MTFontManager().xitsFont(withSize: 20)!
    var textColor: UIColor = .label
    var textAlignment: MTTextAlignment = .center
    var labelMode: MTMathUILabelMode = .display
    var isDark: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.equation == rhs.equation && lhs.fontSize == rhs.fontSize && lhs.isDark == rhs.isDark}
    
    func makeUIView(context: Context) -> MTMathUILabel {
        //print("Creating MathView for: \(equation)")
        let label = MathLabelCache.shared.getOrAddLabel(latex: equation, fontSize: fontSize)
        label.textAlignment = textAlignment
        label.labelMode = labelMode
        label.backgroundColor = .clear
        label.font = font.copy(withSize: fontSize)
        return label
        
//            let mathLabel = MTMathUILabel()
//            mathLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1) // Debug background
//            let font = MTFontManager().xitsFont(withSize: fontSize)
//            mathLabel.font = font
//            mathLabel.fontSize = fontSize
//            mathLabel.latex = equation
//            return mathLabel

    }
    
    func updateUIView(_ mathLabel: MTMathUILabel, context: Context) {
        //print("Updating MathView with equation: \(equation)")
        if mathLabel.latex == equation && mathLabel.fontSize == fontSize && mathLabel.textColor == textColor { return }
        mathLabel.latex = equation
        mathLabel.fontSize = fontSize
        mathLabel.textColor = textColor
        mathLabel.backgroundColor = .clear
        mathLabel.textAlignment = textAlignment
        mathLabel.labelMode = labelMode
        
        mathLabel.font = font.copy(withSize: fontSize)
        
        // Debug: Print if the equation was parsed successfully
//        if mathLabel.latex != "" {
//            print("LaTeX set successfully: \(equation)")
//        } else {
//            print("Failed to set LaTeX: \(equation)")
//        }
        
        // Force layout
        mathLabel.sizeToFit()
//        print("MathLabel size after sizeToFit: \(mathLabel.bounds.size)")
        
        // Set a minimum frame if size is zero
        if mathLabel.bounds.size.width == 0 || mathLabel.bounds.size.height == 0 {
            mathLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
//            print("Set minimum frame: \(mathLabel.frame)")
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
