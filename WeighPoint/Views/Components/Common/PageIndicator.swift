//
//  PageIndicator.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/31/25.
//

import SwiftUI

struct PageIndicator: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            if let scrollViewWidth = proxy.bounds(of: .scrollView(axis: .horizontal))?.width, scrollViewWidth > 0 {
                let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(width / scrollViewWidth)
                
                let progress = -minX / scrollViewWidth
                
                let activeIndex = Int(progress)
                let nextIndex = Int(progress.rounded(.awayFromZero))
                
                let indicatorProgress = progress - CGFloat(activeIndex)
                let currentPageWidth = 18 - (indicatorProgress * 18)
                let nextPageWidth = indicatorProgress * 18
                
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .frame(width: 8 + (activeIndex == index ? currentPageWidth : nextIndex == index ? nextPageWidth : 0), height: 8)
                    }
                }
                .frame(width: scrollViewWidth)
                .offset(x: -minX)
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            CardView(background: .red.gradient) {
            }
            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
            CardView(background: .green.gradient) {
            }
            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
            CardView(background: .yellow.gradient) {
            }
            .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
        }
        .overlay(alignment: .bottom) {
            PageIndicator()
        }
        .scrollTargetLayout()
        
    }
    .scrollTargetBehavior(.viewAligned)
    .contentMargins(16, for: .scrollContent)
    
    .scrollIndicators(.hidden)
    .frame(height: 400)
}
