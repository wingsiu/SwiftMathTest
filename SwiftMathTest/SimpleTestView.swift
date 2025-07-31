//
//  SimpleTestView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//

import SwiftUI
import SwiftMath

struct SimpleTestView: View {
    @State private var testResults: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("SwiftMath Debug Test")
                    .font(.title)
                    .padding()
                
                Button("Test SwiftMath Creation") {
                    testSwiftMathCreation()
                }
                .buttonStyle(.borderedProminent)
                
                // Test with explicit frame
                VStack {
                    Text("Test 1: Simple equation with explicit frame")
                    MathView("E = mc^2")
                        .frame(width: 200, height: 60)
                        .border(Color.red, width: 1)
                }
                
                // Test with different equation
                VStack {
                    Text("Test 2: Fraction")
                    MathView("\\frac{1}{2}")
                        .frame(width: 200, height: 60)
                        .border(Color.blue, width: 1)
                }
                
                // Test with square root
                VStack {
                    Text("Test 3: Square root")
                    MathView("\\sqrt{x}")
                        .frame(width: 200, height: 60)
                        .border(Color.green, width: 1)
                }
                
                // Direct UIKit test
                VStack {
                    Text("Test 4: Direct UIKit Implementation")
                    DirectMathTestView()
                        .frame(width: 200, height: 60)
                        .border(Color.orange, width: 1)
                }
                
                // Test results
                VStack(alignment: .leading) {
                    Text("Test Results:")
                        .font(.headline)
                    
                    ForEach(testResults, id: \.self) { result in
                        Text(result)
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    func testSwiftMathCreation() {
        testResults.removeAll()
        
        // Test 1: Basic creation
        let mathLabel1 = MTMathUILabel()
        testResults.append("✓ MTMathUILabel created successfully")
        
        // Test 2: Set simple equation
        mathLabel1.latex = "x + y = z"
        if mathLabel1.latex != nil {
            testResults.append("✓ Simple equation set: \(mathLabel1.latex ?? "nil")")
        } else {
            testResults.append("✗ Failed to set simple equation")
        }
        
        // Test 3: Set complex equation
        let mathLabel2 = MTMathUILabel()
        mathLabel2.latex = "\\frac{a}{b}"
        if mathLabel2.latex != nil {
            testResults.append("✓ Fraction equation set: \(mathLabel2.latex ?? "nil")")
        } else {
            testResults.append("✗ Failed to set fraction equation")
        }
        
        // Test 4: Check size after sizeToFit
        mathLabel2.sizeToFit()
        testResults.append("Size after sizeToFit: \(mathLabel2.bounds.size)")
        
        // Test 5: Font settings
        mathLabel2.fontSize = 24
        testResults.append("Font size set to: \(mathLabel2.fontSize)")
    }
}

// Direct UIKit implementation for comparison
struct DirectMathTestView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTMathUILabel {
        let mathLabel = MTMathUILabel()
        mathLabel.latex = "\\int_0^1 x dx = \\frac{1}{2}"
        mathLabel.fontSize = 18
        mathLabel.backgroundColor = UIColor.yellow.withAlphaComponent(0.2)
        mathLabel.textColor = UIColor.black
        mathLabel.textAlignment = .center
        return mathLabel
    }
    
    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.sizeToFit()
    }
}

#Preview {
    SimpleTestView()
}
