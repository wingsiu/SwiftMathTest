//
//  PagedEquationList.swift
//  SwiftMathTest
//
//  Created by Alpha Ng on 3/8/2025.
//

import SwiftUI

struct PagedEquationList: View {
    @State private var page: Int = 0
    let pageSize = 20
    let equations: [String]

    var pagedEquations: [String] {
        Array(equations.prefix((page + 1) * pageSize))
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(pagedEquations, id: \.self) { equation in
                    MathView(equation)
                        .onAppear {
                            // Load next page when last item appears
                            if equation == pagedEquations.last && pagedEquations.count < equations.count {
                                page += 1
                            }
                        }
                }
            }
        }
    }
}
