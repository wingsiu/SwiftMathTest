//
//  EquationListView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//

import SwiftUI
import SwiftMath

struct EquationListView: View {
    //let fontSize: CGFloat = 20
    @State private var selectedFontSize: CGFloat = 20
    @Environment(\.colorScheme) var colorScheme
    let equation: [String] = [
        "\\color{#0000FF}{z=\\frac{\\bar{x}-\\mu}{\\sigma}\\ddots23\\bar{ab}\\hat{xy^{2-a}}^7 \\vec{DE} }\\ddot{4}\\hat{.}\\dot{6} ",
        "\\mathbb{NZDQRC}\\text{testing abd 123}",
        "\\vec \\bf V_1 \\times \\vec \\bf V_2 =  \\begin{vmatrix} \\hat \\imath &\\hat \\jmath &\\hat k \\\\ \\frac{\\partial X}{\\partial u} & \\frac{\\partial Y}{\\partial u} & 0 \\\\ \\frac{\\partial X}{\\partial v} & \\frac{\\partial Y}{\\partial v} & 0 \\end{vmatrix}",
        "\\colorbox{#FFFF00}{\\sqrt{a+\\frac{3}{x^2}}}\\int_0^1\\sum_{i=0}^{n+a+b+c} \\sqrt{\\left(\\frac{\\displaystyle\\int y^3+\\frac{x}{5}-1}{\\int x^3-4\\sqrt[3]{x}+\\frac{5+\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}=\\int \\lim_{x\\to\\infty}\\cos x 😃dx\\right)}",
        "\\left| x \\right| = \\begin{cases} x & \\text{ if } x>0 \\\\ -x & \\text{ if } x<0 \\end{cases}",
        "f(x) = \\int\\limits_{-\\infty}^\\infty\\!\\hat f(\\xi)\\,e^{2 \\pi i \\xi x}\\,\\mathrm{d}\\xi",
        "\\frac{1}{n}\\sum_{i=1}^{n}x_i \\geq \\sqrt[n]{\\prod_{i=1}^{n}x_i}",
        "\\frac{1}{\\left(\\sqrt{\\phi \\sqrt{5}}-\\phi\\right) e^{\\frac25 \\pi}} = 1+\\frac{e^{-2\\pi}} {1 +\\frac{e^{-4\\pi}} {1+\\frac{e^{-6\\pi}} {1+\\frac{e^{-8\\pi}} {1+\\cdots} } } }",
        "\\sqrt[3]{a+\\frac{3}{x^2}}\\int_0^1\\frac{{\\int y}^3+\\frac{x}{5}-1}{x^4-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{3+x}{\\sqrt{c^2}+y}}}= \\int_0^1 a \\cos x 😃dx",
        "12x3^{\\int 2}+\\frac{\\int a}{b}-\\sqrt{x+y^2-\\frac{\\frac{\\frac{z}{a+b^5}}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}+\\int_0^1 \\sum aa+3a" ,
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
        "\\lim_{h \\to 0} \\frac{f(x+h) - f(x)}{h}",
        "y^3+\\frac{x}{5}-1",
        "y^3+\\color{#FFFF00}{\\frac{x}{5}}-1",
        "y^3+\\displaystyle\\int a+b dx -1",
        "y^3+\\color{#FFFF00}{\\displaystyle\\int a+b dx }-1",
        "\\frac{6+\\color{#FF0000}{\\frac{7}{\\sqrt{y}+x^5}}}{2a}-1+4r",
        "12x3^{\\int 2}+\\frac{\\int a}{b}-\\color{#00FF00}{\\sqrt[n]{x+y^2-\\frac{\\frac{z}{1-7v^2}}{\\frac{3r^3}{\\frac 1{2+\\frac xy}}}}}+\\int_0^1 \\sum aa+3a",
        "x+3\\sqrt{2a+\\frac{32}{x^2}}\\int_0^1\\sum\\frac{{\\int y}^3+ \\color{#FF0000}{3y}-1}{x-4\\sqrt[3]{x}+\\frac{\\frac{3+x}{4-y}}{\\frac{9v}{1+2+\\sqrt{3}+6y}}}=\\int \\cos x+2dx"
    ]
    
    struct EquationRow: Identifiable {
        let id: UUID = UUID()
        let latex: String
    }
    
    var equations: [EquationRow] {
        Array(repeating: equation, count: 10)
            .flatMap { $0 }
            .map { EquationRow(latex: $0) }
    }
    
    
//    var equations: [String] {
//        Array(repeating: equation, count: 1).flatMap { $0 }
//    }
    
    var body: some View {
        VStack {
            Text("Font Size: \(Int(selectedFontSize))")
                .font(.headline)
            
            Slider(value: $selectedFontSize, in: 12...32, step: 2)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)

        List(equations) { equation in
            NavigationLink {
                
                MathView(equation: equation.latex, fontSize: selectedFontSize + 4, isDark: colorScheme == .dark)
                .fixedSize()
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color.blue : Color.blue.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                
            } label: {
                SwiftMathView(mathList: convertLatexAstToMathList(LatexParser(equation.latex).parse()), fontSize: selectedFontSize)
               // MathView(equation: equation.latex, fontSize: selectedFontSize, isDark: colorScheme == .dark)
                //.frame(minHeight: 40) // adjust as needed
                .background(colorScheme == .dark ? Color.green : Color.green.opacity(0.05))
                .cornerRadius(8)
            }
            
        }

    }
}
