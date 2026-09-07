//
//  BMIInsightCardView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/26/25.
//
import SwiftUI


struct BMIInsightCard: View {
    let insight: BMIInsight
    var body: some View {
        CardView(padding: 32.0) {
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
//                    Text(insight.icon)
//                        .font(.system(size: 48))
                    Text(insight.title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                VStack(spacing: 16) {
                    VStack {
                        Text(insight.displayedBMI)
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .contentTransition(.numericText())
                        Text(insight.displayedBMIRange)
                            .font(.headline)
                            .foregroundStyle(insight.bmiRange.color)
                    }
                    .frame(maxHeight: .infinity)
                    Text(insight.message)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
            }
            .padding(.bottom)
        }
    }
}


#Preview {
    ZStack {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.5, 0), .init(1, 0),
            .init(0, 0.5), .init(0.9, 0.3), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1)
        ], colors: [
            .black, .black, .black,
            .blue, .blue, .blue,
            .green, .green, .green
        ])
        .ignoresSafeArea()
        ScrollView {
            BMIInsightCard(insight: BMIInsight(priority: .high, bmi: 23.0))
                .padding()
        }
    }
    
}
