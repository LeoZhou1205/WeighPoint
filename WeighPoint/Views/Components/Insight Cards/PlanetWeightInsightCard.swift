//
//  PlanetWeightInsightCardView.swift
//  WeighPoint
//
//  Created by Leo Zhou on 5/26/25.
//

import SwiftUI


struct PlanetWeightInsightCard: View {
    let insight: PlanetWeightInsight
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
//                .padding(.top)
//                .overlay(.leading) {
//                    <#code#>
//                }
                
                VStack(spacing: 16) {
                    VStack {
                        Text("\(insight.displayedPlanetWeight)")
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.accent)
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
            PlanetWeightInsightCard(insight: PlanetWeightInsight(priority: .high, planet: .jupiter, weightInKg: 80, weightUnit: .pounds))
                .padding()
        }
    }
}
