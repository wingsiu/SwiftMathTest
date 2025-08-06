import SwiftMath

func convertLatexAstToMathList(_ node: LatexAstNode) -> MTMathList {
    let list = MTMathList()
    appendLatexAstToMathList(node, into: list)
    return list
}

private func appendLatexAstToMathList(_ node: LatexAstNode, into list: MTMathList) {
    switch node {
    case let seq as LatexSequenceNode:
        for child in seq.children { appendLatexAstToMathList(child, into: list) }
    case let group as LatexGroupNode:
        for child in group.children { appendLatexAstToMathList(child, into: list) }
    case let symbol as LatexSymbolNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: symbol.value) {
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: symbol.value)
            for atom in atoms.atoms { list.add(atom) }
        }
    case let greek as LatexGreekNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: greek.name) {
            list.add(atom)
        }
    case let number as LatexTextNode:
        let atoms = MTMathAtomFactory.atomList(for: number.text)
        for atom in atoms.atoms { list.add(atom) }
    case let op as LatexOperatorNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: op.op) {
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: op.op)
            for atom in atoms.atoms { list.add(atom) }
        }
    case let rel as LatexRelationNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: rel.symbol) {
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: rel.symbol)
            for atom in atoms.atoms { list.add(atom) }
        }
    case let font as LatexFontNode:
        if let styleAtom = MTMathAtomFactory.atom(forLatexSymbol: font.style) {
            list.add(styleAtom)
        }
        let sublist = convertLatexAstToMathList(font.base)
        for atom in sublist.atoms { list.add(atom) }
    case let accent as LatexAccentNode:
        if let accentAtom = MTMathAtomFactory.accent(withName: accent.accent) {
            accentAtom.innerList = convertLatexAstToMathList(accent.base)
            list.add(accentAtom)
        }
    case let frac as LatexFracNode:
        let num = convertLatexAstToMathList(frac.numerator)
        let denom = convertLatexAstToMathList(frac.denominator)
        let fracAtom = MTMathAtomFactory.fraction(withNumerator: num, denominator: denom)
        list.add(fracAtom)
    case let sqrt as LatexSqrtNode:
        // Fallback: Insert a symbol or text indicating sqrt
        //let sqrtAtoms = MTMathAtomFactory.atomList(for: "\\sqrt")
        let sqrtAtoms = MTMathAtomFactory.placeholderSquareRoot()
        //for atom in sqrtAtoms.atoms { list.add(atom) }
        let radicandList = convertLatexAstToMathList(sqrt.radicand)
        sqrtAtoms.radicand = radicandList
        //for atom in radicandList.atoms { list.add(atom) }
        list.add(sqrtAtoms)
    case let root as LatexRootNode:
        // Fallback: Insert a symbol or text indicating n-th root
        //let rootAtoms = MTMathAtomFactory.atomList(for: "\\sqrt")
        let rootAtoms = MTMathAtomFactory.placeholderSquareRoot()
        //for atom in rootAtoms.atoms { list.add(atom) }
        let degreeList = convertLatexAstToMathList(root.degree)
        //for atom in degreeList.atoms { list.add(atom) }
        let radicandList = convertLatexAstToMathList(root.radicand)
        rootAtoms.radicand = radicandList
        rootAtoms.degree = degreeList
        list.add(rootAtoms)
        //for atom in radicandList.atoms { list.add(atom) }
    case let sup as LatexSuperscriptNode:
        let baseList = convertLatexAstToMathList(sup.base)
        let expList = convertLatexAstToMathList(sup.exponent)
        for atom in baseList.atoms {
            atom.superScript = expList
            list.add(atom)
        }
    case let sub as LatexSubscriptNode:
        let baseList = convertLatexAstToMathList(sub.base)
        let subList = convertLatexAstToMathList(sub.subscriptNode)
        for atom in baseList.atoms {
            atom.subScript = subList
            list.add(atom)
        }
    case let funcNode as LatexFunctionNode:
        if let funcAtom = MTMathAtomFactory.atom(forLatexSymbol: funcNode.name) {
            list.add(funcAtom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: funcNode.name)
            for atom in atoms.atoms { list.add(atom) }
        }
        let argList = convertLatexAstToMathList(funcNode.argument)
        for atom in argList.atoms { list.add(atom) }
    case let integral as LatexIntegralNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: "int") {
            if let lower = integral.lower { atom.subScript = convertLatexAstToMathList(lower) }
            if let upper = integral.upper { atom.superScript = convertLatexAstToMathList(upper) }
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: "∫")
            for atom in atoms.atoms {
                if let lower = integral.lower { atom.subScript = convertLatexAstToMathList(lower) }
                if let upper = integral.upper { atom.superScript = convertLatexAstToMathList(upper) }
                list.add(atom)
            }
        }
        appendLatexAstToMathList(integral.body, into: list)
    case let sum as LatexSumNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: "sum") {
            if let lower = sum.lower { atom.subScript = convertLatexAstToMathList(lower) }
            if let upper = sum.upper { atom.superScript = convertLatexAstToMathList(upper) }
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: "∑")
            for atom in atoms.atoms {
                if let lower = sum.lower { atom.subScript = convertLatexAstToMathList(lower) }
                if let upper = sum.upper { atom.superScript = convertLatexAstToMathList(upper) }
                list.add(atom)
            }
        }
        appendLatexAstToMathList(sum.body, into: list)
    case let prod as LatexProductNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: "prod") {
            if let lower = prod.lower { atom.subScript = convertLatexAstToMathList(lower) }
            if let upper = prod.upper { atom.superScript = convertLatexAstToMathList(upper) }
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: "∏")
            for atom in atoms.atoms {
                if let lower = prod.lower { atom.subScript = convertLatexAstToMathList(lower) }
                if let upper = prod.upper { atom.superScript = convertLatexAstToMathList(upper) }
                list.add(atom)
            }
        }
        appendLatexAstToMathList(prod.body, into: list)
    case let lim as LatexLimitNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: "lim") {
            if let lower = lim.lower { atom.subScript = convertLatexAstToMathList(lower) }
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: "lim")
            for atom in atoms.atoms {
                if let lower = lim.lower { atom.subScript = convertLatexAstToMathList(lower) }
                list.add(atom)
            }
        }
        appendLatexAstToMathList(lim.body, into: list)
    case let env as LatexEnvironmentNode:
        if env.envName.contains("matrix") {
            if let matrixNode = env.content as? LatexMatrixNode {
                let tableAtom = convertLatexMatrixToMathTable(matrixNode)
                list.add(tableAtom)
            }
        }
    case let matrix as LatexMatrixNode:
        let tableAtom = convertLatexMatrixToMathTable(matrix)
        list.add(tableAtom)
    case let bracket as LatexBracketNode:
        if let leftAtom = MTMathAtomFactory.atom(forLatexSymbol: bracket.left) {
            list.add(leftAtom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: bracket.left)
            for atom in atoms.atoms { list.add(atom) }
        }
        let contentList = convertLatexAstToMathList(bracket.content)
        for atom in contentList.atoms { list.add(atom) }
        if let rightAtom = MTMathAtomFactory.atom(forLatexSymbol: bracket.right) {
            list.add(rightAtom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: bracket.right)
            for atom in atoms.atoms { list.add(atom) }
        }
    case let colorbox as LatexColorBoxNode:
        let innerList = convertLatexAstToMathList(colorbox.content)
        let colorAtom = MTMathAtomFactory.colorBox(withName: colorbox.color, innerList: innerList)
        list.add(colorAtom)
    case let color as LatexColorNode:
        let innerList = convertLatexAstToMathList(color.content)
        let colorAtom = MTMathAtomFactory.color(withName: color.color, innerList: innerList )
        list.add(colorAtom)
    case let textcolor as LatexTextColorNode:
        let innerList = convertLatexAstToMathList(textcolor.content)
        let colorAtom = MTMathAtomFactory.color(withName: textcolor.color, innerList: innerList)
        list.add(colorAtom)
    case let macro as LatexMacroNode:
        if let atom = MTMathAtomFactory.atom(forLatexSymbol: macro.name) {
            list.add(atom)
        } else {
            let atoms = MTMathAtomFactory.atomList(for: macro.name)
            for atom in atoms.atoms { list.add(atom) }
        }
        for arg in macro.args {
            appendLatexAstToMathList(arg, into: list)
        }
    default:
        let atoms = MTMathAtomFactory.atomList(for: "?")
        for atom in atoms.atoms { list.add(atom) }
    }
}

private func convertLatexMatrixToMathTable(_ matrix: LatexMatrixNode) -> MTMathTable {
    let table = MTMathTable(environment: "matrix")
    //table.environment = "matrix"
    for row in matrix.rows {
        let mathRow = row.map { convertLatexAstToMathList($0) }
        table.cells.append(mathRow)
    }
    if let firstRow = table.cells.first {
        table.alignments = Array(repeating: .center, count: firstRow.count)
    }
    return table
}
