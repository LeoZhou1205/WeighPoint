//
//  DefaultInsightCard.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/30/25.
//

import SwiftUI

struct DefaultInsightCard: View {
    let insight: DefaultInsight
    var body: some View {
        CardView {
            CardView(padding: 32.0) {
                VStack(spacing: 32) {
                    Label {
                        Text(insight.title)
                            .font(.title)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "sparkles")
                    }

                    Text(insight.message)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.headline)
                }
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        ScrollView {
            DefaultInsightCard(insight: .init(title: "Default Insight", icon: "", message: "The message of the default insight", priority: .medium))
                .padding()
        }
    }
}
