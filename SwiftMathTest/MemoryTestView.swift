//
//  MemoryTestViewController.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 28/7/2025.
//
import SwiftUI
import SwiftMath

struct MemoryTestView: View {
    @State private var memoryResults: [String] = []
    @State private var isRunning = false
    
    var body: some View {
        VStack {
            if isRunning {
                ProgressView("Running memory tests...")
                    .padding()
            } else {
                VStack(spacing: 12) {
                    Button("Run Memory Test") {
                        runMemoryTests()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Run Memory Leak Test") {
                        runMemoryLeakTest()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            
            List(memoryResults, id: \.self) { result in
                Text(result)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Memory Tests")
    }
    
    func runMemoryTests() {
        isRunning = true
        memoryResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== Memory Usage Test ===")
            results.append("")
            
            let initialMemory = getMemoryUsage()
            results.append("Initial memory: \(String(format: "%.2f", initialMemory)) MB")
            
            // Test with different numbers of equations
            let testSizes = [10, 50, 100, 500, 1000]
            let testEquation = "\\int_{0}^{\\infty} x^n e^{-x} dx = n!"
            
            for size in testSizes {
                let beforeMemory = getMemoryUsage()
                
                // Create multiple math labels
                var mathLabels: [MTMathUILabel] = []
                for _ in 0..<size {
                    autoreleasepool {
                        let mathLabel = MTMathUILabel()
                        mathLabel.latex = testEquation
                        mathLabel.fontSize = 16
                        mathLabel.sizeToFit()
                        mathLabels.append(mathLabel)
                    }
                }
                
                let afterMemory = getMemoryUsage()
                let memoryIncrease = afterMemory - beforeMemory
                let memoryPerLabel = memoryIncrease / Float(size) * 1024 // Convert to KB
                
                results.append("\(size) labels:")
                results.append("  Memory increase: \(String(format: "%.2f", memoryIncrease)) MB")
                results.append("  Per label: \(String(format: "%.1f", memoryPerLabel)) KB")
                results.append("")
                
                // Clean up
                mathLabels.removeAll()
                
                DispatchQueue.main.async {
                    self.memoryResults = results
                }
            }
            
            let finalMemory = getMemoryUsage()
            results.append("Final memory: \(String(format: "%.2f", finalMemory)) MB")
            results.append("Total increase: \(String(format: "%.2f", finalMemory - initialMemory)) MB")
            
            DispatchQueue.main.async {
                self.memoryResults = results
                self.isRunning = false
            }
        }
    }
    
    func runMemoryLeakTest() {
        isRunning = true
        memoryResults.removeAll()
        
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [String] = []
            results.append("=== Memory Leak Test ===")
            results.append("Creating and destroying 1000 math labels...")
            results.append("")
            
            let initialMemory = getMemoryUsage()
            results.append("Initial memory: \(String(format: "%.2f", initialMemory)) MB")
            
            let iterations = 1000
            let testEquation = "E = mc^2"
            
            for i in 0..<iterations {
                autoreleasepool {
                    let mathLabel = MTMathUILabel()
                    mathLabel.latex = testEquation
                    mathLabel.fontSize = 20
                    mathLabel.sizeToFit()
                    // Label goes out of scope and should be deallocated
                }
                
                if i % 200 == 0 {
                    let currentMemory = getMemoryUsage()
                    results.append("After \(i) iterations: \(String(format: "%.2f", currentMemory)) MB")
                    
                    DispatchQueue.main.async {
                        self.memoryResults = results
                    }
                }
            }
            
            // Force garbage collection
            for _ in 0..<3 {
                autoreleasepool { }
            }
            
            let finalMemory = getMemoryUsage()
            let memoryDifference = finalMemory - initialMemory
            
            results.append("")
            results.append("Final memory: \(String(format: "%.2f", finalMemory)) MB")
            results.append("Memory difference: \(String(format: "%.2f", memoryDifference)) MB")
            results.append("")
            
            if memoryDifference < 1.0 {
                results.append("✅ No significant memory leak detected")
            } else if memoryDifference < 5.0 {
                results.append("⚠️ Minor memory increase detected")
            } else {
                results.append("❌ Potential memory leak detected")
            }
            
            DispatchQueue.main.async {
                self.memoryResults = results
                self.isRunning = false
            }
        }
    }
    
    func getMemoryUsage() -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Float(info.resident_size) / (1024 * 1024) // Convert to MB
        }
        return 0
    }
}

#Preview {
    NavigationView {
        MemoryTestView()
    }
}
