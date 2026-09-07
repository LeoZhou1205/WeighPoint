//
//  WeightChangeProgressInsightCardView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/26/25.
//

import SwiftUI


struct WeightChangeProgressInsightCard: View {
    let insight: WeightChangeProgressInsight
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
                        Text("Goal: \(insight.targetWeight.formatted(.number.precision(.fractionLength(1)))) \(insight.weightUnit.rawValue)")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                        Text("Achieved: \(insight.currentWeight.formatted(.number.precision(.fractionLength(1)))) \(insight.weightUnit.rawValue)")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .frame(maxHeight: .infinity)
                    Text(insight.message)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)
        }
        
    }
}


#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        ScrollView {
            WeightChangeProgressInsightCard(insight: WeightChangeProgressInsight(priority: .high, targetWeightInKg: 75, currentWeightInKg: 80, targetStartWeightInKg: 82, weightUnit: .kilograms))
                .padding()
        }
    }
    
}
