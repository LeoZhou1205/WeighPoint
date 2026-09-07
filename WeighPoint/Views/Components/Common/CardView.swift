//
//  CardView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/1/25.
//


import SwiftUI

struct CardView<T1: View, T2: ShapeStyle>: View {
    var padding: CGFloat
    var content: T1
    var background: T2
    var cornerRadius: CGFloat
    init(padding: CGFloat = 16.0, cornerRadius: CGFloat = 32.0,
         shadowRadius: CGFloat = 0, background: T2 = Color(UIColor.secondarySystemGroupedBackground), @ViewBuilder content: () -> T1) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
        self.background = background
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(background)
            content
                .padding(padding)
        }
        
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
        CardView(background: .white) {
            Text("Hello")
        }

        .frame(height: 300)
        .padding()
    }
    
}
