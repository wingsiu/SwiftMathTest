//
//  LatexTokenizer.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//
import Foundation

enum LatexToken: Equatable {
    case command(String)
    case symbol(Character)
    case leftBrace
    case rightBrace
    case leftBracket
    case rightBracket
    case whitespace
    case text(String)
    case eof
}

class LatexTokenizer {
    private let input: String
    private var index: String.Index

    init(_ input: String) {
        self.input = input
        self.index = input.startIndex
    }

    func nextToken() -> LatexToken {
        guard index < input.endIndex else { return .eof }

        let c = input[index]
        if c.isWhitespace {
            advance()
            return .whitespace
        }
        if c == "\\" {
            advance()
            var cmd = ""
            while index < input.endIndex {
                let n = input[index]
                if n.isLetter {
                    cmd.append(n)
                    advance()
                } else {
                    break
                }
            }
            return cmd.isEmpty ? .symbol("\\") : .command(cmd)
        }
        if c == "{" {
            advance()
            return .leftBrace
        }
        if c == "}" {
            advance()
            return .rightBrace
        }
        if c == "[" {
            advance()
            return .leftBracket
        }
        if c == "]" {
            advance()
            return .rightBracket
        }
        if "+-*/^_=()[]|<>.,;:!?'\"".contains(c) {
            advance()
            return .symbol(c)
        }
        if c.isLetter || c.isNumber {
            var text = ""
            while index < input.endIndex {
                let n = input[index]
                if n.isLetter || n.isNumber {
                    text.append(n)
                    advance()
                } else {
                    break
                }
            }
            return .text(text)
        }
        advance()
        return .symbol(c)
    }

    private func advance() {
        index = input.index(after: index)
    }
}
