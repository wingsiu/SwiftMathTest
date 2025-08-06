//
//  MathLabelCache.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//
import SwiftMath
import CoreGraphics
import Foundation

let defaultFont = MTFontManager().xitsFont(withSize: 20)

class MathLabelCache {
    static let shared = MathLabelCache()
    
    //private var fontCache : [CGFloat: MTFont] = [:]
    private var cache: [String: MTMathUILabel] = [:]
    private let lock = NSLock()

    private init() {}

//    func font(withSize size: CGFloat) -> MTFont? {
//        if let cached = fontCache[size] {
//            return cached
//        }
//        let font = MTFontManager().xitsFont(withSize: size)
//        if let font = font {
//            fontCache[size] = font
//        }
//        return font
//    }
    
    func getOrAddLabel(latex: String, fontSize: CGFloat) -> MTMathUILabel {
        let key = cacheKey(latex: latex, fontSize: fontSize)
        lock.lock()
        defer { lock.unlock() }
        if let label = cache[key] {
            let copy = MTMathUILabel()
            copy.latex = label.latex
            copy.fontSize = label.fontSize
            copy.textColor = label.textColor
            copy.backgroundColor = .clear
            copy.sizeToFit()
            return copy
            //return label
        } else {
            let label = MTMathUILabel()
            label.latex = latex
            label.fontSize = fontSize
            label.font = defaultFont?.copy(withSize: fontSize)
//            if let font = font(withSize: fontSize) {
//                    label.font = font
//            }
            label.textColor = .label
            label.backgroundColor = .clear
            label.sizeToFit()
            cache[key] = label
            return label
        }
    }

    private func cacheKey(latex: String, fontSize: CGFloat) -> String {
        return "\(latex)|\(fontSize)"
    }
    
    /// Preload all required font sizes into the font cache
//        func preloadFonts(sizes: [CGFloat]) {
//            for size in sizes {
//                _ = font(withSize: size)
//            }
//        }
}
