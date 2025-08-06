//
//  LatexParser.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 4/8/2025.
//

import Foundation

class LatexParser {
    private var tokenizer: LatexTokenizer
    private var lookahead: LatexToken = .eof

    // Registry for extensible command parsing
    private let commandRegistry: [String: (LatexParser) -> LatexAstNode?]

    init(_ input: String) {
        self.tokenizer = LatexTokenizer(input)
        self.lookahead = tokenizer.nextToken()
        self.commandRegistry = LatexParser.defaultRegistry
    }

    // Entry point
    func parse() -> LatexAstNode {
        return parseSequence()
    }

    private func parseSequence(until terminator: LatexToken? = nil) -> LatexSequenceNode {
        var nodes: [LatexAstNode] = []
        while lookahead != .eof, lookahead != terminator {
            if let node = parseNode() {
                nodes.append(node)
            }
        }
        return LatexSequenceNode(children: nodes)
    }

    private func parseNode() -> LatexAstNode? {
        switch lookahead {
        case .command(let name):
            advance()
            if let handler = commandRegistry[name] {
                return handler(self)
            }
            return parseCommand(name)
        case .leftBrace:
            advance()
            let group = parseSequence(until: .rightBrace)
            expect(.rightBrace)
            advance()
            return LatexGroupNode(children: group.children)
        case .leftBracket:
            advance()
            let group = parseSequence(until: .rightBracket)
            expect(.rightBracket)
            advance()
            return LatexGroupNode(children: group.children)
        case .text(let value):
            advance()
            var base: LatexAstNode = LatexSymbolNode(value: value)
            while true {
                if lookahead == .symbol("^") {
                    advance()
                    if let exp = parseNode() {
                        base = LatexSuperscriptNode(base: base, exponent: exp)
                    }
                } else if lookahead == .symbol("_") {
                    advance()
                    if let sub = parseNode() {
                        base = LatexSubscriptNode(base: base, subscriptNode: sub)
                    }
                } else {
                    break
                }
            }
            return base
        case .symbol(let sym):
            advance()
            return LatexSymbolNode(value: String(sym))
        case .whitespace:
            advance()
            return nil
        case .eof:
            return nil
        default:
            advance()
            return nil
        }
    }

    private func parseCommand(_ name: String) -> LatexAstNode? {
        return LatexSymbolNode(value: "\\" + name)
    }

    private func expect(_ token: LatexToken) {
        if lookahead != token {
            print("Parse error: Expected \(token), got \(lookahead)")
        }
    }

    private func advance() {
        lookahead = tokenizer.nextToken()
    }

    static var defaultRegistry: [String: (LatexParser) -> LatexAstNode?] {
        var registry: [String: (LatexParser) -> LatexAstNode?] = [:]

        // Accent commands
        let accentCommands = ["hat", "tilde", "bar", "vec", "dot", "ddot", "breve", "check"]
        for accent in accentCommands {
            registry[accent] = { parser in
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let baseSeq = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    let base = baseSeq.children.count == 1 ? baseSeq.children[0] : LatexGroupNode(children: baseSeq.children)
                    return LatexAccentNode(accent: accent, base: base)
                }
                return LatexAccentNode(accent: accent, base: LatexSymbolNode(value: "?"))
            }
        }

        // Font commands
        let fontCommands = ["mathbf", "mathit", "mathrm", "mathbb", "mathcal", "mathsf", "mathtt"]
        for font in fontCommands {
            registry[font] = { parser in
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let baseSeq = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    let base = baseSeq.children.count == 1 ? baseSeq.children[0] : LatexGroupNode(children: baseSeq.children)
                    return LatexFontNode(style: font, base: base)
                }
                return LatexFontNode(style: font, base: LatexSymbolNode(value: "?"))
            }
        }

        // Function-like commands with ^/_ support
        let funcCommands = ["sin", "cos", "tan", "cot", "sec", "csc", "log", "ln", "exp"]
        for funcName in funcCommands {
            registry[funcName] = { parser in
                var base: LatexAstNode = LatexSymbolNode(value: funcName)
                while true {
                    if parser.lookahead == .symbol("^") {
                        parser.advance()
                        if let exp = parser.parseNode() {
                            base = LatexSuperscriptNode(base: base, exponent: exp)
                        }
                    } else if parser.lookahead == .symbol("_") {
                        parser.advance()
                        if let sub = parser.parseNode() {
                            base = LatexSubscriptNode(base: base, subscriptNode: sub)
                        }
                    } else {
                        break
                    }
                }
                let arg: LatexAstNode
                if parser.lookahead == .leftBrace || parser.lookahead == .leftBracket {
                    arg = parser.parseNode() ?? LatexSymbolNode(value: "?")
                } else {
                    arg = parser.parseNode() ?? LatexSymbolNode(value: "?")
                }
                return LatexFunctionNode(name: funcName, argument: arg)
            }
        }

        // Fraction command
        registry["frac"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                let numSeq = parser.parseSequence(until: .rightBrace)
                parser.expect(.rightBrace)
                parser.advance()
                let numerator = numSeq.children.count == 1 ? numSeq.children[0] : LatexGroupNode(children: numSeq.children)
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let denSeq = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    let denominator = denSeq.children.count == 1 ? denSeq.children[0] : LatexGroupNode(children: denSeq.children)
                    return LatexFracNode(numerator: numerator, denominator: denominator)
                }
            }
            return LatexFracNode(numerator: LatexSymbolNode(value: "?"), denominator: LatexSymbolNode(value: "?"))
        }

        // Sqrt/Root command
        registry["sqrt"] = { parser in
            var degreeNode: LatexAstNode? = nil
            if parser.lookahead == .leftBracket {
                parser.advance()
                let degreeSeq = parser.parseSequence(until: .rightBracket)
                parser.expect(.rightBracket)
                parser.advance()
                degreeNode = degreeSeq.children.count == 1 ? degreeSeq.children[0] : LatexGroupNode(children: degreeSeq.children)
            }
            if parser.lookahead == .leftBrace {
                parser.advance()
                let radicandSeq = parser.parseSequence(until: .rightBrace)
                parser.expect(.rightBrace)
                parser.advance()
                let radicand = radicandSeq.children.count == 1 ? radicandSeq.children[0] : LatexGroupNode(children: radicandSeq.children)
                if let degree = degreeNode {
                    return LatexRootNode(degree: degree, radicand: radicand)
                } else {
                    return LatexSqrtNode(radicand: radicand)
                }
            }
            return LatexSqrtNode(radicand: LatexSymbolNode(value: "?"))
        }

        // Sum/Product/Integral/Lim commands (improved body parsing)
        registry["sum"] = { parser in
            var lower: LatexAstNode? = nil
            var upper: LatexAstNode? = nil
            if parser.lookahead == .symbol("_") {
                parser.advance()
                lower = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            if parser.lookahead == .symbol("^") {
                parser.advance()
                upper = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            let body: LatexAstNode
            if parser.lookahead == .leftBrace || parser.lookahead == .leftBracket {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            } else {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            }
            return LatexSumNode(lower: lower, upper: upper, body: body)
        }
        registry["prod"] = { parser in
            var lower: LatexAstNode? = nil
            var upper: LatexAstNode? = nil
            if parser.lookahead == .symbol("_") {
                parser.advance()
                lower = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            if parser.lookahead == .symbol("^") {
                parser.advance()
                upper = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            let body: LatexAstNode
            if parser.lookahead == .leftBrace || parser.lookahead == .leftBracket {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            } else {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            }
            return LatexProductNode(lower: lower, upper: upper, body: body)
        }
        registry["int"] = { parser in
            var lower: LatexAstNode? = nil
            var upper: LatexAstNode? = nil
            if parser.lookahead == .symbol("_") {
                parser.advance()
                lower = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            if parser.lookahead == .symbol("^") {
                parser.advance()
                upper = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            let body: LatexAstNode
            if parser.lookahead == .leftBrace || parser.lookahead == .leftBracket {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            } else {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            }
            return LatexIntegralNode(lower: lower, upper: upper, body: body)
        }
        registry["lim"] = { parser in
            var lower: LatexAstNode? = nil
            if parser.lookahead == .symbol("_") {
                parser.advance()
                lower = parser.lookahead == .leftBrace || parser.lookahead == .leftBracket
                    ? parser.parseNode()
                    : parser.parseNode()
            }
            let body: LatexAstNode
            if parser.lookahead == .leftBrace || parser.lookahead == .leftBracket {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            } else {
                body = parser.parseNode() ?? LatexSymbolNode(value: "?")
            }
            return LatexLimitNode(lower: lower, body: body)
        }

        // Matrix environments
        registry["begin"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                if case .text(let envName) = parser.lookahead {
                    let matrixEnvs = ["matrix", "pmatrix", "bmatrix", "vmatrix", "Vmatrix"]
                    if matrixEnvs.contains(envName) {
                        parser.advance()
                        parser.expect(.rightBrace)
                        parser.advance()
                        return parser.parseMatrix(environment: envName)
                    } else {
                        parser.advance()
                        parser.expect(.rightBrace)
                        parser.advance()
                        let content = parser.parseSequence(until: .command("end"))
                        parser.advance()
                        return LatexEnvironmentNode(envName: envName, content: content)
                    }
                }
            }
            return LatexSymbolNode(value: "\\begin")
        }

        // Text command
        registry["text"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                var textContent = ""
                while parser.lookahead != .rightBrace && parser.lookahead != .eof {
                    switch parser.lookahead {
                    case .text(let t):
                        textContent += t
                        parser.advance()
                    case .whitespace:
                        textContent += " "
                        parser.advance()
                    case .symbol(let s):
                        textContent += String(s)
                        parser.advance()
                    default:
                        parser.advance()
                    }
                }
                parser.expect(.rightBrace)
                parser.advance()
                return LatexTextNode(text: textContent)
            }
            return LatexTextNode(text: "")
        }

        // Improved delimiters: \left ... \right
        registry["left"] = { parser in
            if case .symbol(let l) = parser.lookahead {
                parser.advance()
                var contentNodes: [LatexAstNode] = []
                while parser.lookahead != .command("right"), parser.lookahead != .eof {
                    if let node = parser.parseNode() {
                        contentNodes.append(node)
                    }
                }
                parser.expect(.command("right"))
                parser.advance()
                if case .symbol(let r) = parser.lookahead {
                    parser.advance()
                    let content = LatexSequenceNode(children: contentNodes)
                    return LatexBracketNode(left: String(l), content: content, right: String(r))
                }
            }
            return LatexSymbolNode(value: "\\left?")
        }

        // Relations, operators, Greek letters, macros, color, etc.
        registry["leq"]    = { _ in LatexRelationNode(symbol: "≤") }
        registry["geq"]    = { _ in LatexRelationNode(symbol: "≥") }
        registry["neq"]    = { _ in LatexRelationNode(symbol: "≠") }
        registry["approx"] = { _ in LatexRelationNode(symbol: "≈") }
        registry["pm"]     = { _ in LatexOperatorNode(op: "±", args: []) }
        registry["cdot"]   = { _ in LatexOperatorNode(op: "⋅", args: []) }
        registry["times"]  = { _ in LatexOperatorNode(op: "×", args: []) }
        registry["div"]    = { _ in LatexOperatorNode(op: "÷", args: []) }
        registry["to"]     = { _ in LatexRelationNode(symbol: "→") }
        registry["infty"]  = { _ in LatexSymbolNode(value: "∞") }

        let greekLetters = [
            "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa",
            "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega"
        ]
        for greek in greekLetters {
            registry[greek] = { _ in LatexGreekNode(name: greek) }
        }

        // Macros
        registry["overset"] = { parser in
            let arg1 = parser.parseNode() ?? LatexSymbolNode(value: "?")
            let arg2 = parser.parseNode() ?? LatexSymbolNode(value: "?")
            return LatexMacroNode(name: "overset", args: [arg1, arg2])
        }
        registry["underset"] = { parser in
            let arg1 = parser.parseNode() ?? LatexSymbolNode(value: "?")
            let arg2 = parser.parseNode() ?? LatexSymbolNode(value: "?")
            return LatexMacroNode(name: "underset", args: [arg1, arg2])
        }

        // COLOR SUPPORT
        registry["color"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                var color = ""
                while parser.lookahead != .rightBrace && parser.lookahead != .eof {
                    switch parser.lookahead {
                    case .text(let t):
                        color += t
                        parser.advance()
                    case .whitespace:
                        color += " "
                        parser.advance()
                    case .symbol(let s):
                        color += String(s)
                        parser.advance()
                    default:
                        parser.advance()
                    }
                }
                parser.expect(.rightBrace)
                parser.advance()
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let content = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    return LatexColorNode(color: color, content: content)
                }
            }
            return LatexColorNode(color: "?", content: LatexSequenceNode(children: []))
        }
        registry["textcolor"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                var color = ""
                while parser.lookahead != .rightBrace && parser.lookahead != .eof {
                    switch parser.lookahead {
                    case .text(let t):
                        color += t
                        parser.advance()
                    case .whitespace:
                        color += " "
                        parser.advance()
                    case .symbol(let s):
                        color += String(s)
                        parser.advance()
                    default:
                        parser.advance()
                    }
                }
                parser.expect(.rightBrace)
                parser.advance()
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let content = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    return LatexTextColorNode(color: color, content: content)
                }
            }
            return LatexTextColorNode(color: "?", content: LatexSequenceNode(children: []))
        }
        registry["colorbox"] = { parser in
            if parser.lookahead == .leftBrace {
                parser.advance()
                var color = ""
                while parser.lookahead != .rightBrace && parser.lookahead != .eof {
                    switch parser.lookahead {
                    case .text(let t):
                        color += t
                        parser.advance()
                    case .whitespace:
                        color += " "
                        parser.advance()
                    case .symbol(let s):
                        color += String(s)
                        parser.advance()
                    default:
                        parser.advance()
                    }
                }
                parser.expect(.rightBrace)
                parser.advance()
                if parser.lookahead == .leftBrace {
                    parser.advance()
                    let content = parser.parseSequence(until: .rightBrace)
                    parser.expect(.rightBrace)
                    parser.advance()
                    return LatexColorBoxNode(color: color, content: content)
                }
            }
            return LatexColorBoxNode(color: "?", content: LatexSequenceNode(children: []))
        }
        return registry
    }

    private func parseMatrix(environment: String) -> LatexMatrixNode {
        var rows: [[LatexAstNode]] = []
        var currentRow: [LatexAstNode] = []
        while lookahead != .command("end"), lookahead != .eof {
            if lookahead == .symbol("&") {
                advance()
            } else if lookahead == .symbol("\\") {
                advance()
                if lookahead == .text("newline") || lookahead == .symbol("\\") {
                    advance()
                    rows.append(currentRow)
                    currentRow = []
                }
            } else if lookahead == .rightBrace {
                break
            } else {
                if let node = parseNode() {
                    currentRow.append(node)
                }
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        if lookahead == .command("end") {
            advance()
            if lookahead == .leftBrace {
                advance()
                if case .text(let envName) = lookahead, envName == environment {
                    advance()
                    expect(.rightBrace)
                    advance()
                }
            }
        }
        return LatexMatrixNode(rows: rows)
    }
}
