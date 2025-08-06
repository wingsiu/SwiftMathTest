//
//  LatexParserTests.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 5/8/2025.
//
@testable import SwiftMathTest
import XCTest

class LatexParserTests: XCTestCase {

    func testSimpleSymbol() {
        let parser = LatexParser("x")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let symbol = seq.children.first as? LatexSymbolNode else {
            XCTFail("First child is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(symbol.value, "x")
    }

    func testFraction() {
        let parser = LatexParser("\\frac{1}{x}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let frac = seq.children.first as? LatexFracNode else {
            XCTFail("First child is not LatexFracNode")
            return
        }
        guard let num = frac.numerator as? LatexSymbolNode,
              let den = frac.denominator as? LatexSymbolNode else {
            XCTFail("Numerator or denominator is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(num.value, "1")
        XCTAssertEqual(den.value, "x")
    }

    func testSqrt() {
        let parser = LatexParser("\\sqrt{y}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let sqrt = seq.children.first as? LatexSqrtNode else {
            XCTFail("First child is not LatexSqrtNode")
            return
        }
        guard let radicand = sqrt.radicand as? LatexSymbolNode else {
            XCTFail("Radicand is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(radicand.value, "y")
    }

    func testRoot() {
        let parser = LatexParser("\\sqrt[3]{z}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let root = seq.children.first as? LatexRootNode else {
            XCTFail("First child is not LatexRootNode")
            return
        }
        guard let degree = root.degree as? LatexSymbolNode,
              let radicand = root.radicand as? LatexSymbolNode else {
            XCTFail("Degree or radicand is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(degree.value, "3")
        XCTAssertEqual(radicand.value, "z")
    }

    func testSuperscript() {
        let parser = LatexParser("x^2")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let sup = seq.children.first as? LatexSuperscriptNode else {
            XCTFail("First child is not LatexSuperscriptNode")
            return
        }
        guard let base = sup.base as? LatexSymbolNode,
              let exp = sup.exponent as? LatexSymbolNode else {
            XCTFail("Base or exponent is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(base.value, "x")
        XCTAssertEqual(exp.value, "2")
    }

    func testSubscript() {
        let parser = LatexParser("y_1")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let sub = seq.children.first as? LatexSubscriptNode else {
            XCTFail("First child is not LatexSubscriptNode")
            return
        }
        guard let base = sub.base as? LatexSymbolNode,
              let subscriptNode = sub.subscriptNode as? LatexSymbolNode else {
            XCTFail("Base or subscriptNode is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(base.value, "y")
        XCTAssertEqual(subscriptNode.value, "1")
    }

    func testSumWithLimits() {
        let parser = LatexParser("\\sum_{n=1}^{\\infty} n^2")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let sum = seq.children.first as? LatexSumNode else {
            XCTFail("First child is not LatexSumNode")
            return
        }
        XCTAssertNotNil(sum.lower)
        XCTAssertNotNil(sum.upper)
    }

    func testMatrix() {
        let parser = LatexParser("\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let matrix = seq.children.first as? LatexMatrixNode else {
            XCTFail("First child is not LatexMatrixNode")
            return
        }
        XCTAssertEqual(matrix.rows.count, 2)
        guard let row0 = matrix.rows.first,
              row0.count > 1,
              let row1 = matrix.rows.last,
              row1.count > 1 else {
            XCTFail("Matrix rows are not correct")
            return
        }
        XCTAssertEqual((row0[0] as? LatexSymbolNode)?.value, "1")
        XCTAssertEqual((row1[1] as? LatexSymbolNode)?.value, "4")
    }

    func testGreekLetter() {
        let parser = LatexParser("\\alpha")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let greek = seq.children.first as? LatexGreekNode else {
            XCTFail("First child is not LatexGreekNode")
            return
        }
        XCTAssertEqual(greek.name, "alpha")
    }

    func testColorCommand() {
        let parser = LatexParser("\\color{red}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not LatexSequenceNode")
            return
        }
        guard let color = seq.children.first as? LatexColorNode else {
            XCTFail("First child is not LatexColorNode")
            return
        }
        XCTAssertEqual(color.color, "red")
    }
    
    func testAccent() {
        let parser = LatexParser("\\hat{x}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let accent = seq.children.first as? LatexAccentNode else {
            XCTFail("First child is not LatexAccentNode")
            return
        }
        guard let base = accent.base as? LatexSymbolNode else {
            XCTFail("Accent base is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(accent.accent, "hat")
        XCTAssertEqual(base.value, "x")
    }

    func testFont() {
        let parser = LatexParser("\\mathbf{x}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let font = seq.children.first as? LatexFontNode else {
            XCTFail("First child is not LatexFontNode")
            return
        }
        guard let base = font.base as? LatexSymbolNode else {
            XCTFail("Font base is not LatexSymbolNode")
            return
        }
        XCTAssertEqual(font.style, "mathbf")
        XCTAssertEqual(base.value, "x")
    }

    func testText() {
        let parser = LatexParser("\\text{hello world}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not a LatexSequenceNode")
            return
        }
        guard let text = seq.children.first as? LatexTextNode else {
            XCTFail("First child is not LatexTextNode")
            return
        }
        XCTAssertEqual(text.text, "hello world")
    }

    

    func testTextColorCommand() {
        let parser = LatexParser("\\textcolor{blue}{hello}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not LatexSequenceNode")
            return
        }
        guard let textcolor = seq.children.first as? LatexTextColorNode else {
            XCTFail("First child is not LatexTextColorNode")
            return
        }
        XCTAssertEqual(textcolor.color, "blue")
        guard let text = textcolor.content as? LatexSequenceNode,
              let textNode = text.children.first as? LatexSymbolNode else {
            XCTFail("Content not correct type")
            return
        }
        XCTAssertEqual(textNode.value, "hello")
    }

    func testColorBoxCommand() {
        let parser = LatexParser("\\colorbox{yellow}{world}")
        let ast = parser.parse()
        guard let seq = ast as? LatexSequenceNode else {
            XCTFail("AST is not LatexSequenceNode")
            return
        }
        guard let colorbox = seq.children.first as? LatexColorBoxNode else {
            XCTFail("First child is not LatexColorBoxNode")
            return
        }
        XCTAssertEqual(colorbox.color, "yellow")
        guard let text = colorbox.content as? LatexSequenceNode,
              let textNode = text.children.first as? LatexSymbolNode else {
            XCTFail("Content not correct type")
            return
        }
        XCTAssertEqual(textNode.value, "world")
    }
}
