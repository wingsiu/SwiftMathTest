import SwiftUI

struct TestButtonView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("SwiftMath Testing Suite")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                NavigationLink(destination: SimpleTestView()) {
                    TestButtonView(title: "🐛 Debug Test",
                                 description: "Test SwiftMath integration")
                }
                
                NavigationLink(destination: PerformanceTestView()) {
                    TestButtonView(title: "⚡ Performance Tests",
                                 description: "Enhanced performance analysis")
                }
                
                NavigationLink(destination: DetailedAnalysisView()) {
                    TestButtonView(title: "🔬 Detailed Analysis",
                                 description: "Complete performance breakdown")
                }
                
                NavigationLink(destination: MemoryTestView()) {
                    TestButtonView(title: "💾 Memory Tests",
                                 description: "Check memory usage")
                }
                
                NavigationLink(destination: BenchmarkView()) {
                    TestButtonView(title: "📊 Comprehensive Benchmark",
                                 description: "Full test suite")
                }
                
                NavigationLink(destination: MathDisplayView()) {
                    TestButtonView(title: "🎨 Math Display Demo",
                                 description: "Visual examples")
                }
                
                Spacer()
            }
            .navigationTitle("SwiftMath Tests")
        }
    }
}

#Preview {
    ContentView()
}
