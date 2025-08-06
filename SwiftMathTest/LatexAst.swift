//
//  LatexAST.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 4/8/2025.
//

import Foundation

protocol LatexAstNode {}

struct LatexSymbolNode: LatexAstNode {
    let value: String
}

struct LatexGroupNode: LatexAstNode {
    let children: [LatexAstNode]
}

struct LatexFracNode: LatexAstNode {
    let numerator: LatexAstNode
    let denominator: LatexAstNode
}

struct LatexSqrtNode: LatexAstNode {
    let radicand: LatexAstNode
}

struct LatexRootNode: LatexAstNode {
    let degree: LatexAstNode
    let radicand: LatexAstNode
}

struct LatexSuperscriptNode: LatexAstNode {
    let base: LatexAstNode
    let exponent: LatexAstNode
}

struct LatexSubscriptNode: LatexAstNode {
    let base: LatexAstNode
    let subscriptNode: LatexAstNode
}

struct LatexSequenceNode: LatexAstNode {
    let children: [LatexAstNode]
}

struct LatexSumNode: LatexAstNode {
    let lower: LatexAstNode?
    let upper: LatexAstNode?
    let body: LatexAstNode
}

struct LatexProductNode: LatexAstNode {
    let lower: LatexAstNode?
    let upper: LatexAstNode?
    let body: LatexAstNode
}

struct LatexIntegralNode: LatexAstNode {
    let lower: LatexAstNode?
    let upper: LatexAstNode?
    let body: LatexAstNode
}

struct LatexLimitNode: LatexAstNode {
    let lower: LatexAstNode?
    let body: LatexAstNode
}

struct LatexTextNode: LatexAstNode {
    let text: String
}

struct LatexMatrixNode: LatexAstNode {
    let rows: [[LatexAstNode]]
}

struct LatexBracketNode: LatexAstNode {
    let left: String
    let content: LatexAstNode
    let right: String
}

struct LatexFunctionNode: LatexAstNode {
    let name: String
    let argument: LatexAstNode
}

struct LatexAccentNode: LatexAstNode {
    let accent: String
    let base: LatexAstNode
}

struct LatexFontNode: LatexAstNode {
    let style: String
    let base: LatexAstNode
}

struct LatexOperatorNode: LatexAstNode {
    let op: String
    let args: [LatexAstNode]
}

struct LatexMacroNode: LatexAstNode {
    let name: String
    let args: [LatexAstNode]
}

struct LatexEnvironmentNode: LatexAstNode {
    let envName: String
    let content: LatexAstNode
}

struct LatexRelationNode: LatexAstNode {
    let symbol: String
}

struct LatexGreekNode: LatexAstNode {
    let name: String
}

// *** NEW COLOR NODES ***
struct LatexColorNode: LatexAstNode {
    let color: String
    let content: LatexAstNode
}

struct LatexTextColorNode: LatexAstNode {
    let color: String
    let content: LatexAstNode
}

struct LatexColorBoxNode: LatexAstNode {
    let color: String
    let content: LatexAstNode
}
