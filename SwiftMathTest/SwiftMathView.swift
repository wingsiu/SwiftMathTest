//
//  SwiftMathView.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 6/8/2025.
//
/// UIViewRepresentable to wrap MTMathUILabel for use in SwiftUI.
///
import SwiftUI
import SwiftMath

struct SwiftMathView: UIViewRepresentable {
    let mathList: MTMathList
    var fontSize: CGFloat

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.fontSize = fontSize
        label.textAlignment = .center
        label.contentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        label.mathList = mathList
        return label
    }

    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
        uiView.fontSize = fontSize
        uiView.mathList = mathList
    }
}
